use structopt::StructOpt;
use crate::{storage_helper::StorageHelper,error::Error,SingleBackend};
use libra_network_address::{NetworkAddress, RawNetworkAddress};
use libra_config::{
    config::{
        DiscoveryMethod, Identity, NetworkConfig, NodeConfig, OnDiskStorageConfig, RoleType,
        SecureBackend, WaypointConfig,
    },
    network_id::NetworkId,
};
use std::convert::TryInto;


#[derive(Debug, StructOpt)]
pub struct Config {
    #[structopt(flatten)]
    backend: SingleBackend,
    #[structopt(long)]
    validator_address: NetworkAddress,
    #[structopt(long)]
    validator_listen_address: NetworkAddress,
    #[structopt(long)]
    fullnode_address: Option<NetworkAddress>,
    #[structopt(long)]
    fullnode_listen_address: Option<NetworkAddress>,
}

impl Config {
    pub fn execute(self) -> Result<String, Error> {


        let mut config = NodeConfig::default();

        let mut network = NetworkConfig::network_with_id(NetworkId::Validator);
        network.discovery_method = DiscoveryMethod::None;
        config.validator_network = Some(network);

        let mut network = NetworkConfig::network_with_id(NetworkId::vfn_network());
        network.discovery_method = DiscoveryMethod::None;
        config.full_node_networks = vec![network];


        if let Some(network) = config.validator_network.as_mut() {
            network.listen_address = self.validator_listen_address;
            network.advertised_address = self.validator_address;
            network.identity = Identity::from_storage(
                libra_global_constants::VALIDATOR_NETWORK_KEY.into(),
                libra_global_constants::OPERATOR_ACCOUNT.into(),
                self.backend.backend.try_into().unwrap(),
            );
        }

        config.configs_ol_miner.preimage ="".to_string();
        config.configs_ol_miner.proof ="".to_string();


        Ok(toml::to_string_pretty(&config).unwrap())

        

        

    }

}
