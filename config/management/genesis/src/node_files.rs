// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use executor::db_bootstrapper;
use libra_config::{config::NetworkConfig, config::{DiscoveryMethod, NodeConfig}, network_id::NetworkId};
use libra_crypto::ed25519::Ed25519PublicKey;
use libra_global_constants::{
    CONSENSUS_KEY, FULLNODE_NETWORK_KEY, OPERATOR_ACCOUNT, OPERATOR_KEY, OWNER_ACCOUNT, OWNER_KEY,
    SAFETY_DATA, VALIDATOR_NETWORK_KEY, WAYPOINT,
};
use libra_management::{
    config::ConfigPath, error::Error, secure_backend::ValidatorBackend,
    storage::StorageWrapper as Storage,
};
use libra_network_address::NetworkAddress;
use libra_temppath::TempPath;
use libra_types::{
    account_address::AccountAddress, account_config, account_state::AccountState,
    on_chain_config::ValidatorSet, validator_config::ValidatorConfig, waypoint::Waypoint,
};
use libra_vm::LibraVM;
use libradb::LibraDB;
use std::{convert::TryFrom, fmt::Write, fs::File, io::Read, path::{Path, PathBuf}, str::FromStr, sync::Arc, fs};
use storage_interface::{DbReader, DbReaderWriter};
use structopt::StructOpt;

/// Prints the public information within a store
#[derive(Debug, StructOpt)]
pub struct Files {
    #[structopt(flatten)]
    config: ConfigPath,
    #[structopt(flatten)]
    backend: ValidatorBackend,
    /// If specified, compares the internal state to that of a
    /// provided genesis. Note, that a waypont might diverge from
    /// the provided genesis after execution has begun.
    #[structopt(long,)]
    data_path: Option<PathBuf>,
    #[structopt(long, verbatim_doc_comment)]
    genesis_path: Option<PathBuf>,
}

impl Files {
    pub fn execute(self) -> Result<String, Error> {
        // Get the Owner and Operator Keys
        let tbd_cfg = self
            .config
            .load()?
            .override_validator_backend(&self.backend.validator_backend)?;
        let validator_storage = tbd_cfg.validator_backend();
        // let mut buffer = String::new();
        let test = get_ed25519_key(&validator_storage,OWNER_KEY).expect("Could not extract OWNER public key");
        dbg!(&test);

        // Get node configs template
        let mut config = NodeConfig::default();
        // config.logger.level = Level::Debug;

        dbg!(&config);
        // Set network configs
        let mut network = NetworkConfig::network_with_id(NetworkId::Validator);
        dbg!(&network);
        
        // if let Some(network) = config.validator_network.as_mut() {
        //     network.listen_address = self.validator_listen_address;
        //     network.advertised_address = self.validator_address;
        //     network.identity = Identity::from_storage(
        //         libra_global_constants::VALIDATOR_NETWORK_KEY.into(),
        //         libra_global_constants::OPERATOR_ACCOUNT.into(),
        //         self.backend.backend.clone().try_into().unwrap(),
        //     );
        //     network.discovery_method = DiscoveryMethod::Gossip;

        //     // network.seed_peers_file = path.join("seed_peers.toml") ;
        // }

        // Get Upstream and Seed Peers info.
        network.discovery_method = DiscoveryMethod::Onchain;
        config.validator_network = Some(network);


        // let upstream = AuthenticationKey::ed25519(&key.public_key).derived_address();
        // config.upstream = UpstreamConfig::default();
        // config.upstream.primary_networks.push(upstream);

        // let peers = Seeds {
        //     genesis_path: path.join("genesis.blob")
        // };
        // for (acc, _network_addresses) in peers.get_seed_info().unwrap().seed_peers.iter() {
        //     if upstream != *acc{
        //     config.upstream.upstream_peers.insert(PeerNetworkId(upstream,acc.clone()));
        //     }
        // }

        // Set Consensus settings
        // config.consensus.safety_rules.backend = self.backend.backend.clone().try_into().unwrap();
        // config.consensus.round_initial_timeout_ms = 1000;

        // config.base.waypoint = WaypointConfig::FromStorage {
        //     backend: self.backend.backend.clone().try_into().unwrap(),
        // };

        // config.execution.genesis_file_location = path.join("genesis.blob");

        // Misc

        // config.storage.prune_window=Some(20_000);



        // Write file
        let output_dir: PathBuf;

        if self.data_path.is_none() {
            output_dir = PathBuf::from("/root/node_data/");
        } else {
            output_dir = self.data_path.unwrap();
        }

        // let toml = toml::to_string_pretty(&config).unwrap();

        fs::create_dir_all(&output_dir).expect("Unable to create output directory");
        config
            .save(&output_dir.join("node.configs.yaml"))
            .expect("Unable to save node configs");

        Ok("test".to_string())
        // Ok(toml::to_string_pretty(&config).unwrap())
    }
}

fn get_ed25519_key(storage: &Storage, key: &'static str) -> Result<Ed25519PublicKey, Error> {
    storage.ed25519_public_from_private(key)
}

fn get_x25519_key(storage: &Storage, buffer: &mut String, key: &'static str) {
    let value = storage
        .x25519_public_from_private(key)
        .map(|v| v.to_string())
        .unwrap_or_else(|e| e.to_string());
    writeln!(buffer, "{} - {}", key, value).unwrap();
}


fn write_assert(buffer: &mut String, name: &str, value: bool) {
    let value = if value { "match" } else { "MISMATCH" };
    writeln!(buffer, "{} - {}", name, value).unwrap();
}

fn write_break(buffer: &mut String) {
    writeln!(
        buffer,
        "====================================================================================",
    )
    .unwrap();
}

fn write_ed25519_key(storage: &Storage, buffer: &mut String, key: &'static str) {
    let value = storage
        .ed25519_public_from_private(key)
        .map(|v| v.to_string())
        .unwrap_or_else(|e| e.to_string());
    writeln!(buffer, "{} - {}", key, value).unwrap();
}
fn write_x25519_key(storage: &Storage, buffer: &mut String, key: &'static str) {
    let value = storage
        .x25519_public_from_private(key)
        .map(|v| v.to_string())
        .unwrap_or_else(|e| e.to_string());
    writeln!(buffer, "{} - {}", key, value).unwrap();
}

fn write_string(storage: &Storage, buffer: &mut String, key: &'static str) {
    let value = storage.string(key).unwrap_or_else(|e| e.to_string());
    writeln!(buffer, "{} - {}", key, value).unwrap();
}

fn write_safety_data(storage: &Storage, buffer: &mut String, key: &'static str) {
    let value = storage
        .value::<consensus_types::safety_data::SafetyData>(key)
        .map(|v| v.to_string())
        .unwrap_or_else(|e| e.to_string());
    writeln!(buffer, "{} - {}", key, value).unwrap();
}

fn write_waypoint(storage: &Storage, buffer: &mut String, key: &'static str) {
    let value = storage
        .string(key)
        .map(|value| {
            if value.is_empty() {
                "empty".into()
            } else {
                Waypoint::from_str(&value)
                    .map(|c| c.to_string())
                    .unwrap_or_else(|_| "Invalid waypoint".into())
            }
        })
        .unwrap_or_else(|e| e.to_string());

    writeln!(buffer, "{} - {}", key, value).unwrap();
}

fn compare_genesis(
    storage: Storage,
    buffer: &mut String,
    genesis_path: &PathBuf,
) -> Result<(), Error> {
    // Compute genesis and waypoint and compare to given waypoint
    let db_path = TempPath::new();
    let (db_rw, expected_waypoint) = compute_genesis(genesis_path, db_path.path())?;

    let actual_waypoint = storage.waypoint(WAYPOINT)?;
    write_assert(buffer, WAYPOINT, actual_waypoint == expected_waypoint);

    // Fetch on-chain validator config and compare on-chain keys to local keys
    let validator_account = storage.account_address(OWNER_ACCOUNT)?;
    let validator_config = validator_config(validator_account, db_rw.reader.clone())?;

    let actual_consensus_key = storage.ed25519_public_from_private(CONSENSUS_KEY)?;
    let expected_consensus_key = &validator_config.consensus_public_key;
    write_assert(
        buffer,
        CONSENSUS_KEY,
        &actual_consensus_key == expected_consensus_key,
    );

    let actual_validator_key = storage.x25519_public_from_private(VALIDATOR_NETWORK_KEY)?;
    let actual_fullnode_key = storage.x25519_public_from_private(FULLNODE_NETWORK_KEY)?;
    let encryptor = storage.encryptor();

    let expected_validator_key = encryptor
        .decrypt(
            &validator_config.validator_network_addresses,
            validator_account,
        )
        .ok()
        .and_then(|addrs| {
            addrs
                .get(0)
                .and_then(|addr: &NetworkAddress| addr.find_noise_proto())
        });
    write_assert(
        buffer,
        VALIDATOR_NETWORK_KEY,
        Some(actual_validator_key) == expected_validator_key,
    );

    let expected_fullnode_key = validator_config.fullnode_network_addresses().ok().and_then(
        |addrs: Vec<NetworkAddress>| addrs.get(0).and_then(|addr| addr.find_noise_proto()),
    );
    write_assert(
        buffer,
        FULLNODE_NETWORK_KEY,
        Some(actual_fullnode_key) == expected_fullnode_key,
    );

    Ok(())
}

/// Compute the ledger given a genesis writeset transaction and return access to that ledger and
/// the waypoint for that state.
fn compute_genesis(
    genesis_path: &PathBuf,
    db_path: &Path,
) -> Result<(DbReaderWriter, Waypoint), Error> {
    let libradb =
        LibraDB::open(db_path, false, None).map_err(|e| Error::UnexpectedError(e.to_string()))?;
    let db_rw = DbReaderWriter::new(libradb);

    let mut file = File::open(genesis_path)
        .map_err(|e| Error::UnexpectedError(format!("Unable to open genesis file: {}", e)))?;
    let mut buffer = vec![];
    file.read_to_end(&mut buffer)
        .map_err(|e| Error::UnexpectedError(format!("Unable to read genesis: {}", e)))?;
    let genesis = lcs::from_bytes(&buffer)
        .map_err(|e| Error::UnexpectedError(format!("Unable to parse genesis: {}", e)))?;

    let waypoint = db_bootstrapper::generate_waypoint::<LibraVM>(&db_rw, &genesis)
        .map_err(|e| Error::UnexpectedError(e.to_string()))?;
    db_bootstrapper::maybe_bootstrap::<LibraVM>(&db_rw, &genesis, waypoint)
        .map_err(|e| Error::UnexpectedError(format!("Unable to commit genesis: {}", e)))?;

    Ok((db_rw, waypoint))
}

/// Read from the ledger the validator config from the validator set for the specified account
fn validator_config(
    validator_account: AccountAddress,
    reader: Arc<dyn DbReader>,
) -> Result<ValidatorConfig, Error> {
    let blob = reader
        .get_latest_account_state(account_config::validator_set_address())
        .map_err(|e| {
            Error::UnexpectedError(format!("ValidatorSet Account issue {}", e.to_string()))
        })?
        .ok_or_else(|| Error::UnexpectedError("ValidatorSet Account not found".into()))?;
    let account_state = AccountState::try_from(&blob)
        .map_err(|e| Error::UnexpectedError(format!("Failed to parse blob: {}", e)))?;
    let validator_set: ValidatorSet = account_state
        .get_validator_set()
        .map_err(|e| Error::UnexpectedError(format!("ValidatorSet issue {}", e.to_string())))?
        .ok_or_else(|| Error::UnexpectedError("ValidatorSet does not exist".into()))?;
    let info = validator_set
        .payload()
        .iter()
        .find(|vi| vi.account_address() == &validator_account)
        .ok_or_else(|| {
            Error::UnexpectedError(format!(
                "Unable to find Validator account {:?}",
                &validator_account
            ))
        })?;
    Ok(info.config().clone())
}
