address 0x0 {

module Globals {
    use 0x0::Signer;
    use 0x0::Transaction;
    use 0x0::Vector;
    use 0x0::Testnet;

    // Some constants need to changed based on environment; dev, testing, prod.
    struct GlobalConstants {
      // For validator set.
      epoch_length: u64,
      max_validator_per_epoch: u64,
      // For subsidy calcs.
      subsidy_ceiling_gas: u64,
      min_node_density: u64,
      max_node_density: u64,
    }

    // Some global state needs to be accesible to every module. Using Librablock causes
    // cyclic dependency issues.
    resource struct BlockMetadataGlobal {
      // TODO: This is duplicated with LibraBlockGlobal, but that one causes a cyclic dependency issue because of stats.
      height: u64,
      round: u64,
      previous_block_votes: vector<address>,
      proposer: address,
      time_microseconds: u64,
    }
    // This can only be invoked by the Association address, and only a single time.
    // Currently, it is invoked in the genesis transaction
    public fun initialize_block_metadata(account: &signer) {
      // Only callable by the Association address
      Transaction::assert(Signer::address_of(account) == 0x0, 1);

      move_to<BlockMetadataGlobal>(
          account,
          BlockMetadataGlobal {
            height: 0,
            round: 0,
            previous_block_votes: Vector::singleton(0x0),
            proposer: 0x0,
            time_microseconds: 0,
          }
      );
    }


    ////////////////////
    //// Metadata /////
    ///////////////////
    // Get the current block height
    public fun get_current_block_height(): u64 acquires BlockMetadataGlobal {
      borrow_global<BlockMetadataGlobal>(0x0).height
    }

    // Get the previous block voters
    public fun get_previous_voters(): vector<address> acquires BlockMetadataGlobal {
       let voters = *&borrow_global<BlockMetadataGlobal>(0x0).previous_block_votes;
       return voters //vector<address>
    }

    ////////////////////
    //// Constants ////
    ///////////////////

    // Get the epoch length
    public fun get_epoch_length(): u64 {
       get_constants().epoch_length
    }

    // Get max validator per epoch
    public fun get_max_validator_per_epoch(): u64 {
       get_constants().max_validator_per_epoch
    }

    // Get max validator per epoch
    public fun get_subsidy_ceiling_gas(): u64 {
       get_constants().subsidy_ceiling_gas
    }

    // Get max validator per epoch
    public fun get_max_node_density(): u64 {
       get_constants().max_node_density
    }

    fun get_constants(): GlobalConstants  {
      if (Testnet::is_testnet()){
        return GlobalConstants {
          epoch_length: 15,
          max_validator_per_epoch: 10,
          subsidy_ceiling_gas: 296,
          min_node_density: 4,
          max_node_density: 300,
        }

      } else {
        return GlobalConstants {
          epoch_length: 2000000,
          max_validator_per_epoch: 300,
          subsidy_ceiling_gas: 2000000,
          min_node_density: 4,
          max_node_density: 300
        }
      }
    }

    // Get the current block height
    public fun update_global_metadata(vm: &signer) acquires BlockMetadataGlobal {
      Transaction::assert(Signer::address_of(vm) == 0x0, 33);
      let data = borrow_global_mut<BlockMetadataGlobal>(0x0);
      data.height = 999
    }
}

}
