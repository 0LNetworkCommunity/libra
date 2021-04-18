//! `pilot` subcommand

#![allow(clippy::never_loop)]
use crate::{entrypoint, node::client, node::node::Node, prelude::app_config};
use abscissa_core::{Command, Options, Runnable, status_warn, status_ok, status_err};
/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct PilotCmd {}

impl Runnable for PilotCmd {
    /// Print version message
    fn run(&self) {
        println!("PILOT");
        let args = entrypoint::get_args();
        let cfg = app_config().clone();
        let (client, wp) = client::pick_client(args.swarm_path, &cfg).expect("could not create connect a client");
        let mut node = Node::new(client, cfg.clone());
        // Start the webserver before anything else
        if Node::is_web_monitor_serving() {
          status_ok!("Web", "web monitor is serving on 3030");
        } else {
          status_warn!("web monitor is NOT serving 3030");

        }

        if node.db_files_exist() {
            status_ok!("DB", "db files exist");
        // return
        } else {
            status_err!("NO db files found, try `ol restore`");
        }

        // is DB bootstrapped
        // if node.db_bootstrapped() {
        //     println!("Database bootstrapped");
        // } else {
        //     println!("Database was NOT bootstrapped");
        // }

        // Is in validator in set?

        if node.refresh_onchain_state().is_in_validator_set() {
          status_ok!("Set","validator in set");
        } else {
          status_warn!("owner NOT in validator set");
        }
        // is node started?
        if Node::node_running() {
          status_ok!("Node","node is running")
        } else {
          status_warn!("node is NOT running");
        }
        if let Some(mode) = Node::what_node_mode() {
          status_ok!("Mode","node running in mode: {:?}", mode);
          // match mode {
            
          // }
        };

        if Node::miner_running() {
          status_ok!("Miner","miner is running")
        } else { 
          status_warn!("miner is NOT running");
        }


        // restart in validator mode

        // restart in fullnode mode

        // did the node finish sync
        if Node::cold_start_is_synced(&cfg, wp).0 {
          status_ok!("Sync","node is synced");
        } else {
          status_warn!("node is NOT Synced");
        }

        // TODO: is the node making progress

        ////////////// MINING //////////////
        // does the account exist on chain?
        if node.accounts_exist_on_chain() {
          status_ok!("Account","owner account found on chain")
        } else {
          status_warn!("owner account does NOT exist on chain.")
        }

        // start miner
        // management::start_miner()

        // are transactions being successfully submitted?
        // TODO?
    }
}
