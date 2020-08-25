address 0x0 {

module LibraBlock {
    use 0x0::Event;
    use 0x0::LibraSystem;
    use 0x0::LibraTimestamp;
    use 0x0::Signer;
    use 0x0::Transaction;
    use 0x0::Vector;
    use 0x0::Stats;
    use 0x0::ReconfigureOL;
    use 0x0::Globals;
    use 0x0::AutoPay;

    resource struct BlockMetadata {
      // Height of the current block
      height: u64,
      // TODO 0L: prefer not modifying this struct. Need to find a way to read from new_block_events.
      voters: vector<address>,
      // Handle where events with the time of new blocks are emitted
      new_block_events: Event::EventHandle<Self::NewBlockEvent>,
    }

    struct NewBlockEvent {
      round: u64,
      proposer: address,
      previous_block_votes: vector<address>,

      // On-chain time during  he block at the given height
      time_microseconds: u64,
    }

    // This can only be invoked by the Association address, and only a single time.
    // Currently, it is invoked in the genesis transaction
    public fun initialize_block_metadata(account: &signer) {
      // Only callable by the Association address
      Transaction::assert(Signer::address_of(account) == 0x0, 1);

      move_to<BlockMetadata>(
          account,
          BlockMetadata {
              height: 0,
              voters: Vector::singleton(0x0), // 0L Change TODO: 0L: (Nelaturuk) Remove this. It's a placeholder.
              new_block_events: Event::new_event_handle<Self::NewBlockEvent>(account),
          }
      );

    }

    // Set the metadata for the current block.
    // The runtime always runs this before executing the transactions in a block.
    // TODO: 1. Make this private, support other metadata
    //       2. Should the previous block votes be provided from BlockMetadata or should it come from the ValidatorSet
    //          Resource?
    public fun block_prologue(
        vm: &signer,
        round: u64,
        timestamp: u64,
        previous_block_votes: vector<address>,
        proposer: address
    ) acquires BlockMetadata {
        // Can only be invoked by LibraVM privilege.
        Transaction::assert(Signer::address_of(vm) == 0x0, 33);
        {
          let block_metadata_ref = borrow_global<BlockMetadata>(0x0);
          Stats::insert_voter_list(block_metadata_ref.height, &previous_block_votes);
        };
        AutoPay::autopay(vm, get_current_block_height());
        process_block_prologue(vm,  round, timestamp, previous_block_votes, proposer);

        // TODO(valerini): call regular reconfiguration here LibraSystem2::update_all_validator_info()

        // 0L implementation of reconfiguration.
        if ( round == Globals::get_epoch_length() )
          // TODO: We don't need to pass block height to ReconfigureOL. It should use the BlockMetadata.
          ReconfigureOL::reconfigure(vm, get_current_block_height());
    }

    // Update the BlockMetadata resource with the new blockmetada coming from the consensus.
    fun process_block_prologue(
        vm: &signer,
        round: u64,
        timestamp: u64,
        previous_block_votes: vector<address>,
        proposer: address
    ) acquires BlockMetadata {
        let block_metadata_ref = borrow_global_mut<BlockMetadata>(0x0);
        if(proposer != 0x0) Transaction::assert(LibraSystem::is_validator(proposer), 5002);
        LibraTimestamp::update_global_time(vm, proposer, timestamp);

        block_metadata_ref.height = block_metadata_ref.height + 1;
        AutoPay::update_block(block_metadata_ref.height);
        block_metadata_ref.voters = *&previous_block_votes;

        Event::emit_event<NewBlockEvent>(
          &mut block_metadata_ref.new_block_events,
          NewBlockEvent {
            round: round,
            proposer: proposer,
            previous_block_votes: previous_block_votes,
            time_microseconds: timestamp,
          }
        );
    }

    // Get the current block height
    public fun get_current_block_height(): u64 acquires BlockMetadata {
      borrow_global<BlockMetadata>(0x0).height
    }

    // Get the previous block voters
    public fun get_previous_voters(): vector<address> acquires BlockMetadata {
       let voters = *&borrow_global<BlockMetadata>(0x0).voters;
       return voters
    }
}

}
