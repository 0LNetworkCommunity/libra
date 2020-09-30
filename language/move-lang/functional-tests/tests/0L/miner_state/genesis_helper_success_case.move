//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

// Prepare the state for the next test.
// Bob Submits a CORRECT VDF Proof, and that updates the state.
//! account: bob, 10000000GAS
//! new-transaction
//! sender: bob
script {
use 0x0::MinerState;
use 0x0::Transaction;
use 0x0::TestFixtures;

fun main(sender: &signer) {

    // Testing that state can be initialized, and a proof submitted as if it were genesis.
    // building block for other tests.
    MinerState::test_helper(
        sender,
        TestFixtures::easy_chal(),
        TestFixtures::easy_sol()
    );

    let height = MinerState::test_helper_get_tower_height({{bob}});
    Transaction::assert(height==0, 01);

}
}
// check: EXECUTED
