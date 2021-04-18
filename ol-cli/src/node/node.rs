//! `node` module

use crate::{check::items::Items, config::OlCliConfig, mgmt::management::NodeMode};
use cli::libra_client::LibraClient;
use libra_temppath::TempPath;
use libradb::LibraDB;
use std::{process::Command, str};
use sysinfo::SystemExt;
use sysinfo::{ProcessExt, ProcessStatus};

use libra_json_rpc_client::views::MinerStateResourceView;
use libra_types::{account_address::AccountAddress, account_state::AccountState};
use libra_types::{validator_info::ValidatorInfo, waypoint::Waypoint};
use storage_interface::DbReader;

use super::{account::OwnerAccountView, chain_info::ChainView, states::HostState};

/// name of key in kv store for sync
pub const SYNC_KEY: &str = "is_synced";

/// node process name:
pub const NODE_PROCESS: &str = "libra-node";

/// miner process name:
pub const MINER_PROCESS: &str = "miner";

/// Configuration used for checks we want to make on the node
pub struct Node {
    /// 0L configs
    pub conf: OlCliConfig,
    /// libraclient for connecting
    pub client: LibraClient,
    /// all items we are checking. Monitor sends these to cache.
    pub items: Items,
    /// state of the host for state machine
    pub host_state: HostState,
    /// owner account view
    pub account_info: OwnerAccountView,
    /// TODO: DO WE NEED ACOUNT INFO? Redundant?
    /// chain view
    pub chain_info: Option<ChainView>,

    /// validator view
    pub validator_info: Option<ValidatorInfo>,

    chain_state: Option<AccountState>,
    miner_state: Option<MinerStateResourceView>,
}

impl Node {
    /// Create a instance of Check
    pub fn new(client: LibraClient, conf: OlCliConfig) -> Self {
        return Self {
            client,
            conf: conf.clone(),
            host_state: HostState::init(),
            items: Items::init(),
            account_info: OwnerAccountView::new(conf.profile.account),
            chain_info: None,
            validator_info: None,
            miner_state: None,
            chain_state: None,
        };
    }

    /// refresh all checks
    pub fn refresh_checks(&mut self) -> &mut Self {
        self.items.configs_exist = self.configs_exist();
        self.items.db_restored = self.db_bootstrapped();
        self.items.node_running = Node::node_running();
        self.items.miner_running = Node::miner_running();
        self.items.account_created = self.accounts_exist_on_chain();
        let sync_tuple = self.is_synced();
        self.items.is_synced = sync_tuple.0;
        self.items.sync_delay = sync_tuple.1;
        self.items.validator_set = self.is_in_validator_set();
        self
    }

    /// Fetch chain state from the upstream node
    pub fn refresh_onchain_state(&mut self) -> &mut Self {
        self.chain_state = match self.get_account_state(AccountAddress::ZERO) {
            Ok(account_state) => Some(account_state),
            Err(_) => None,
        };
        self.miner_state = match self.client.get_miner_state(self.conf.profile.account) {
            Ok(state) => state,
            _ => None,
        };
        self
    }

    /// return tower height on chain
    pub fn tower_height_on_chain(&self) -> u64 {
        match &self.miner_state {
            Some(s) => s.verified_tower_height,
            None => 0,
        }
    }

    /// return tower height on chain
    pub fn mining_epoch_on_chain(&self) -> u64 {
        match &self.miner_state {
            Some(s) => s.latest_epoch_mining,
            None => 0,
        }
    }
    /// validator sets
    pub fn validator_set_count(&self) -> usize {
        match &self.chain_state {
            Some(s) => s.get_validator_set().unwrap().unwrap().payload().len(),
            None => 0,
        }
    }

    /// Current monitor account
    pub fn account(&self) -> Vec<u8> {
        self.conf.profile.account.to_vec()
    }

    /// Get waypoint from client
    pub fn waypoint(&mut self) -> Waypoint {
        self.client
            .get_state_proof()
            .expect("Failed to get state proof"); // refresh latest state proof
        let waypoint = self.client.waypoint();
        match waypoint {
            Some(w) => w,
            None => self
                .conf
                .get_waypoint(None)
                .expect("could not get waypoint"),
        }
    }

    /// is validator jailed
    pub fn is_jailed() -> bool {
        unimplemented!("Don't know how to implement")
    }

    /// Is current account in validator set
    pub fn is_in_validator_set(&self) -> bool {
        match &self.chain_state {
            Some(s) => {
                for v in s.get_validator_set().unwrap().unwrap().payload().iter() {
                    if v.account_address().to_vec() == self.conf.profile.account.to_vec() {
                        return true;
                    }
                }
                false
            }
            None => {
                println!("No chain state retrieved");
                false
            }
        }
    }

    /// nothing is configured yet, empty box
    pub fn configs_exist(&mut self) -> bool {
        // check to see no files are present
        let home_path = self.conf.workspace.node_home.clone();

        let c_exist = home_path.join("blocks/block_0.json").exists()
            && home_path.join("validator.node.yaml").exists()
            && home_path.join("key_store.json").exists();
        c_exist
    }

    /// the owner and operator accounts exist on chain
    pub fn accounts_exist_on_chain(&mut self) -> bool {
        let addr = self.conf.profile.account;
        // dbg!(&addr);
        let account = self.client.get_account(addr, false);
        match account {
            Ok((opt, _)) => match opt {
                Some(_) => true,
                None => false,
            },
            Err(_) => false,
        }
    }

    /// database is initialized, Please do NOT invoke this function frequently
    pub fn db_bootstrapped(&mut self) -> bool {
        let mut file = self.conf.workspace.node_home.clone();
        file.push("db/libradb"); // TODO should the name be hardcoded here?
        if file.exists() {
            // When not committing, we open the DB as secondary so the tool is usable along side a
            // running node on the same DB. Using a TempPath since it won't run for long.
            let tmpdir = TempPath::new().path().to_path_buf();
            match LibraDB::open_as_secondary(file, tmpdir) {
                Ok(db) => {
                    println!("opened db");
                    return db.get_latest_version().is_ok();
                }
                Err(_) => {}
            }
        }
        return false;
    }

    // pub fn db_state() {
    //   // from storage/backup/backup-cli/src/bin/db-backup.rs
    //     // let client = BackupServiceClient::new_with_opt(opt.client);
    //     // if let Some(db_state) = client.get_db_state().await? {
    //     //     println!("{}", db_state)
    //     // } else {
    //     //     println!("DB not bootstrapped.")
    //     // }
    // }
    /// database is initialized, Please do NOT invoke this function frequently
    pub fn db_files_exist(&mut self) -> bool {
        // check to see no files are present
        let home_path = self.conf.workspace.node_home.clone();
        let db_path = home_path.join("db/libradb");
        db_path.exists()
    }

    // /// Check if node caught up, if so mark as caught up.
    // pub fn check_sync(&mut self) -> (bool, i64) {
    //     let sync = Check::node_is_synced();
    //     // let have_ever_synced = false;
    //     // assert never synced
    //     if self.has_never_synced() && sync.0 {
    //         // mark as synced
    //         self.items.is_synced = true;
    //         self.items.write_cache();
    //     }
    //     sync
    // }

    // /// Check if node is running
    // pub fn check_node_state() -> bool {
    //   NodeHealth::check_process(NODE_PROCESS)
    // }
    /// Check if node is running
    pub fn node_running() -> bool {
        Node::check_process(NODE_PROCESS) | Node::check_systemd(NODE_PROCESS)
    }

    /// Check if miner is running
    pub fn miner_running() -> bool {
        Node::check_process(MINER_PROCESS) | Node::check_systemd(MINER_PROCESS)
    }

    fn check_process(process_str: &str) -> bool {
        let mut system = sysinfo::System::new_all();
        system.refresh_all();
        for (_, process) in system.get_processes() {
            if process.name() == process_str {
                // TODO: doesn't always catch `miner` running, see get by name below.
                return true;
            }
        }
        // try by name (yield different results), most reliable.
        let p = system.get_process_by_name(process_str);
        !p.is_empty()
    }
    /// check what mode the node is running in
    pub fn what_node_mode() -> Option<NodeMode> {
        // check systemd first
        if Node::node_running() {
            let out = Command::new("service")
                .args(&["libra-node", "status", "| grep validatorsdf"])
                .output()
                .expect("could no check systemctl");
            let text = str::from_utf8(&out.stdout.as_slice()).unwrap();
            if text.contains("validator.node.yaml") {
                return Some(NodeMode::Validator);
            }

            // check as parent process
            let mut system = sysinfo::System::new_all();
            system.refresh_all();
            let all_p = system.get_process_by_name(NODE_PROCESS);
            let process = all_p
                .into_iter()
                .filter(|i| match i.status() {
                    ProcessStatus::Run => true,
                    _ => false,
                })
                .find(|i| !i.cmd().is_empty());

            if process
                .unwrap()
                .cmd()
                .contains(&"validator.node.yaml".to_owned())
            {
                return Some(NodeMode::Validator);
            }
            if process
                .unwrap()
                .cmd()
                .contains(&"fullnode.node.yaml".to_owned())
            {
                return Some(NodeMode::Fullnode);
            }
        }
        None
    }

    /// is web monitor serving on 3030
    pub fn is_web_monitor_serving() -> bool {
        let out = Command::new("fuser")
            .args(&["3030/tcp"])
            .output()
            .expect("could no check fuser");
        out.status.code().unwrap() == 0
    }

    fn check_systemd(process_name: &str) -> bool {
        let out = Command::new("systemctl")
            .arg("is-active")
            .arg("--quiet")
            .arg(process_name)
            .output()
            .expect("could no check systemctl");
        out.status.code().unwrap() == 0 // is_active --quiet will exit 0 if the service is running normally.
    }
}
