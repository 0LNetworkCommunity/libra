// Module to test bulk validator updates function in LibraSystem.move
//! account: alice, 100000 ,0, validator
//! account: bob, 100000, 0, validator
//! account: carol, 100000, 0, validator
//! account: sha, 100000, 0, validator
//! account: ram, 100000, 0, validator

// Initialize Redeem Module
//! new-transaction
//! sender: config
script {
use 0x0::Redeem;
fun main(s: &signer) {
    Redeem::initialize(s);
}
}
// check: EXECUTED

// Test to check the current validator list.
//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    fun main(_account: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 5, 1000);
        Transaction::assert(LibraSystem::is_validator({{sha}}) == true, 98);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 98);
    }
}
// check: EXECUTED

// Alice Submit VDF Proof and it is the only node in Validator Universe
//! new-transaction
//! sender: alice
script {
use 0x0::Redeem;
fun main() {

    let difficulty = 100;
    let challenge = x"aa";
    let solution = x"001eef1120c0b13b46adae770d866308a5db6fdc1f408c6b8b6a7376e9146dc94586bdf1f84d276d5f65d1b1a7cec888706b680b5e19b248871915bb4319bbe13e7a2e222d28ef9e5e95d3709b46d88424c52140e1d48c1f123f2a1341448b9239e40509a604b1c54cc6c2750ae1255287308d7b2dd5353bae649d4b1bcb65154cffe2e189ec6960d5fa88eef4aa4f1c1939ce8b4808c379562a45ffcda8c502b9558c0999a595dddc02601e837634081977be9195345fae0e858b2cf402e03844ccda24977966ca41706e84c3bf4a841c3845c7bb519547b735cb5644fb0f8a78384827a098b3c80432a4db1135e3df70ade040444d67936b949bd17b68f64fde81000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";

    let proof = Redeem::create_proof_blob(challenge, difficulty, solution);
    Redeem::begin_redeem(proof);

}
}
// check: EXECUTED


// CRUX OF TEST CASE
// Triggered reconfigure - only alice should be present in next epoch. 
// New epoch - so validator universe should be null.
//! new-transaction
//! sender: association
script {
    
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::ReconfigureOL;
    use 0x0::Redeem;
    use 0x0::Vector;

    fun main(account: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 5, 1000);
        Transaction::assert(LibraSystem::is_validator({{sha}}) == true, 98);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 98);
        
        // reconfigure call
        ReconfigureOL::reconfigure(account);
        
        // Validators in current epoch
        Transaction::assert(LibraSystem::validator_set_size() == 1, 1000);
        Transaction::assert(!LibraSystem::is_validator({{sha}}) == true, 98);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 98);

        // Check validator universe
        let validators = Redeem::query_eligible_validators(account);
        Transaction::assert(Vector::length<address>(&validators) == 0, 1);   
    }
}
// check: EXECUTED
