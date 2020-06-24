// Temporary tests for non-public methods written for OL. 
// Not to be executed once code is merged with OLv3

// // Initialize ValidatorUniverse Module
// //! new-transaction
// //! sender: association
// script {
// use 0x0::ValidatorUniverse;
// fun main(account: &signer) {
//     ValidatorUniverse::initialize(account);
// }
// }
// // check: EXECUTED

// Adding new validator epoch info
//! new-transaction
//! sender: association
script{
use 0x0::ValidatorUniverse;
use 0x0::Vector;
use 0x0::Transaction;
fun main(account: &signer) {
    // Borrow validator universe for modification
    ValidatorUniverse::add_validator(0xDEADBEEF);
    ValidatorUniverse::add_validator(0xDEADBEEF);
    let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(account));
    Transaction::assert(len == 1, 1);
}
}
// check: EXECUTED

// Updating existing validator epoch info
//! new-transaction
//! sender: association
script{
use 0x0::ValidatorUniverse;
fun main() {
    // Borrow validator universe for modification
    ValidatorUniverse::add_validator(0xDEADBEEF);
    ValidatorUniverse::update_validator(0xDEADBEEF);
    ValidatorUniverse::update_validator(0xDEADDEAD);
}
}
// check: EXECUTED
