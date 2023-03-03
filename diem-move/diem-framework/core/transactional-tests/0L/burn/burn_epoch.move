//# init --validators Alice Bob Dave CommunityA CommunityB


// Alice is a Validator
// CommunityA is a community wallet.
// We are checking that by default, CommunityA does not receive any funds from Alice's burn, because she has not opted to recycle.
// Tests that Alice burns the cost-to-exist on every epoch, 
// (is NOT sending to community index)

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Mock;

    fun main(vm: signer, _: signer) {
        let start_height = 0;
        let end_height = 100;
        Mock::mock_case_1(&vm, @Alice, start_height, end_height);
    }
}

//# run --admin-script --signers DiemRoot CommunityA
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sponsor: signer) {
      DonorDirected::init_donor_directed(&sponsor, @Alice, @Bob, @Dave, 2);
      DonorDirected::finalize_init(&sponsor);
      let list = DonorDirected::get_root_registry();
      assert!(Vector::length(&list) == 1, 7357001);
      assert!(DiemAccount::is_init_cumu_tracking(@CommunityA), 7357002);

    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Debug::print;

  fun main(vm: signer, _account: signer) {
    let bal = DiemAccount::balance<GAS>(@Alice);
    print(&bal);

    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @CommunityA, 1000000, x"", x"", &vm);

    let bal = DiemAccount::balance<GAS>(@Alice);
    print(&bal);
    assert!(bal == 9000000, 7357003);
  }
}

////////////////////////////////////////////
// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

//// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
////////////////////////////////////////////


//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Diem;
  use DiemFramework::Debug::print;

  fun main() {
    let new_cap = Diem::market_cap<GAS>();
    // no change to market cap
    // assert!(new_cap == 65000000, 7357004);
    print(&new_cap);

    // alice balance should increase because of subsidy
    let alice_old_balance = 9000000;
    let new = DiemAccount::balance<GAS>(@Alice);

    assert!(new > alice_old_balance, 7357004);
    let subsidy = new - alice_old_balance;
    print(&new);
    print(&subsidy);

    // should not change CommunityA's balance, since Alice did not opt to seend to community index.
    let bal = DiemAccount::balance<GAS>(@CommunityA);
    assert!(bal == 11000000, 7357005);

    let cap_at_start = 65000000;

    let burn = (new_cap as u64) - cap_at_start;
    print(&burn);

    // despite new minting of coins from validator reward
    // the new cap should not be greater than the old cap + subsidy, because there was a burn.
    assert!(new_cap < 331000000, 7357006);


  }
}