// Module to test bulk validator updates function in LibraSystem.move
//! account: alice, 100000 ,0, validator
//! account: bob, 100000, 0, validator
//! account: carol, 100000, 0, validator
//! account: sha, 100000, 0, validator
//! account: ram, 100000, 0, validator


// Test to check the current validator list . Then trigger update to the list of validators, then re-run it. 
// OL:Currently will fail because current block height is less than single epoch
//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::Vector;
    use 0x0::ValidatorUniverse;
    fun main(account: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 5, 1000);
        Transaction::assert(LibraSystem::is_validator({{sha}}) == true, 98);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 98);

        //Create vector of validators and func call
        let vec = Vector::empty();
        Vector::push_back<address>(&mut vec, {{alice}});
        ValidatorUniverse::add_validator({{alice}});
        Vector::push_back<address>(&mut vec, {{bob}});
        ValidatorUniverse::add_validator({{bob}});
        Vector::push_back<address>(&mut vec, {{carol}});
        ValidatorUniverse::add_validator({{carol}});
        Transaction::assert(Vector::length<address>(&vec) == 3, 1);

        LibraSystem::bulk_update_validators(account, vec, 15, 1);

        // Check if updates are done
        Transaction::assert(LibraSystem::validator_set_size() == 3, 1000);
        Transaction::assert(LibraSystem::is_validator({{sha}}) == false, 98);
        Transaction::assert(LibraSystem::is_validator({{bob}}) == true, 98);
    }
}
// check: ABORTED