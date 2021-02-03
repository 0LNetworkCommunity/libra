// Adding new validator epoch info
//! account: alice, 100000 ,0, validator
//! account: eve, 100000

//! new-transaction
//! sender: libraroot
script{
use 0x1::ValidatorUniverse;
use 0x1::Vector;
// use 0x1::TestFixtures;
// use 0x1::LibraAccount;

fun main(vm: &signer) {
    let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(vm));
    assert(len == 1, 73570);
}
}
// check: EXECUTED

//! new-transaction
//! sender: eve
script{
use 0x1::ValidatorUniverse;
// use 0x1::Vector;
use 0x1::MinerState;

fun main(eve: &signer) {
    MinerState::test_helper_mock_mining(eve, 5);
    ValidatorUniverse::add_validator(eve);
    // let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(vm));
    // assert(len == 2, 73570);
}
}
// check: EXECUTED