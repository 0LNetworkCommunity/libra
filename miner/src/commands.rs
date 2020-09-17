//! OlMiner Subcommands
//!
//! This is where you specify the subcommands of your application.
//!
//! The default application comes with two subcommands:
//!
//! - `start`: launches the application
//! - `version`: print application version
//!
//! See the `impl Configurable` below for how to specify the path to the
//! application's configuration file.

mod keygen;
mod start;
mod version;
mod onboard;
mod swarm_test;
mod export;

use self::{keygen::KeygenCmd, start::StartCmd, version::VersionCmd,
           onboard::OnboardCmd, swarm_test::SwarmCmd};
use crate::config::OlMinerConfig;
use abscissa_core::{
    config::Override, Command, Configurable, FrameworkError, Help, Options, Runnable,
};
use std::path::PathBuf;
use crate::commands::export::ExportCmd;

/// OlMiner Configuration Filename
pub const CONFIG_FILE: &str = "miner.toml";

/// OlMiner Subcommands
#[derive(Command, Debug, Options, Runnable)]
pub enum OlMinerCmd {
    /// The `help` subcommand
    #[options(help = "get usage information")]
    Help(Help<Self>),

    /// The `start` subcommand
    #[options(help = "start mining blocks")]
    Start(StartCmd),

    /// The `version` subcommand
    #[options(help = "display version information")]
    Version(VersionCmd),

    /// The `keygen` subcommand
    #[options(help = "generate a keypair ")]
    Keygen(KeygenCmd),

    /// The `genesis` subcommand
    #[options(help = "Onboard a new miner with a block_0.json proof")]
    Onboard(OnboardCmd),

    /// The `swarm` subcommand
    #[options(help = "test connection to a local swarm")]
    Swarm(SwarmCmd),

    /// The `export` subcommand
    #[options(help = "export states to genesis.blob")]
    Export(ExportCmd),
}

/// This trait allows you to define how application configuration is loaded.
impl Configurable<OlMinerConfig> for OlMinerCmd {
    /// Location of the configuration file
    fn config_path(&self) -> Option<PathBuf> {
        // Check if the config file exists, and if it does not, ignore it.
        // If you'd like for a missing configuration file to be a hard error
        // instead, always return `Some(CONFIG_FILE)` here.
        let filename = PathBuf::from(CONFIG_FILE);

        if filename.exists() {
            Some(filename)
        } else {
            None
        }
    }

    /// Apply changes to the config after it's been loaded, e.g. overriding
    /// values in a config file using command-line options.
    ///
    /// This can be safely deleted if you don't want to override config
    /// settings from command-line options.
    fn process_config(&self, config: OlMinerConfig) -> Result<OlMinerConfig, FrameworkError> {
        match self {
            OlMinerCmd::Start(cmd) => cmd.override_config(config),
            _ => Ok(config),
        }
    }
}
