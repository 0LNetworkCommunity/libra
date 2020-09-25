//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 10000000GAS

// Alice Submit VDF Proof
//! new-transaction
//! sender: alice
script {
use 0x0::MinerState;
// use 0x0::Debug;
use 0x0::Transaction;

// SIMULATES A MINER ONBOARDING PROOF (block_0.json)
fun main(sender: &signer) {
    let difficulty = 100;
    let challenge = x"1796824cdcc3ab205c25f260e15dc6705942d356f114089d4a46f2f3b0b15b52000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304c20746573746e65746400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050726f74657374732072616765206163726f737320746865206e6174696f6e";
    // Generate solutions with cd ./verfiable-delay/ cargo run -- -l=4096 aa 100
    // the -l=4096 is important because this is the security paramater of 0L miner.
    let solution = x"004102e5a40aa610d88964f2fb650511370811440577cd4cd643321f494accd05e10f5183cdb155b98f519e24619fd12a06bb12d9377c03998cb2f06a2b88485b2fc33704f632f518a7b821500cf5c6ee4e3748768af0ca25240f02041845e0d74975d82e6679996244d3bb41c0c36b520eea0ad11918ec44bff83a392d2e4fb7bc5c022275fc4ba242fa4c2503756a004ab262aeda9fac49b92521e2d6a96ab3b9d2fc0c3906da8ba3e87f4b249f81e9dc8cc879019bdffa716a878c9c73ea406fc60597b29f3f503cd9d293017a37cdec80b30f8bd95c6f1a67b7e1afe97a1f7fb4eed3a1e56cbf13c7f034c5373849008df4c6dafd92df0de5421b123a5839800087a8004a1a0e78ca4e0aa50760bc77e8dd00526aed9fa272541f1476ae5476bd520c72694ded1de34a672bdca451e8809d15d98910921e28ee313186e77726a428204672f66b873f35463d78570f126329c0541a5c1af1fb18b429be150fd1de9498d18717b09178a41aa15fd6fa8d7b6737d730fe87ef4ab875ec2459f8b97c604fc6f999d2c1df563e550ba247e5d7318319fcb0c22e39a3bc2d8b782d8fad912652fc151a99af0f4a28311050d77d75a1651d08d7a45676238765bab161c15648c4dd601eab92d169702f5a951b332845e87942ea48b453c177c51fa73e64d67544857f69d342ecd0ebf1e73ed57d7de1f780a9f01ceaa95b586f60ba2a300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
    let reported_tower_height = 0;

    // return solution
    let proof = MinerState::create_proof_blob(challenge, difficulty, solution, reported_tower_height);
    MinerState::commit_state(sender, proof);

    let verified_tower_height_after = MinerState::get_miner_tower_height({{alice}});
    // Debug::print(&verified_tower_height_after);
    // Debug::print(&verified_tower_height_after);

    Transaction::assert(verified_tower_height_after == reported_tower_height, 10008001);



}
}
// check: EXECUTED


//! new-transaction
//! sender: alice
script {
use 0x0::MinerState;
// use 0x0::Debug;
use 0x0::Globals;
use 0x0::Transaction;

// SIMULATES THE SECOND PROOF OF THE MINER (block_1.json)
fun main(sender: &signer) {
    let difficulty = Globals::get_difficulty();

    // Generate solutions with cd ./verfiable-delay/ cargo run -- -l=4096 aa 100
    // the -l=4096 is important because this is the security paramater of 0L miner.
    let challenge = x"65c91b90421bee9187417079142e69af67ce885a2f506aa061444cadb5064437";

    let solution = x"0020fb7ab75e252582092c9be7cb638a488bc91d97b34bd481c2d221a98596126a13ef37c580d500e01e7038f3d32978c395884dc9ffa4fc54080f21ef45f2897ca76a6568ab516db6803bfc410568c7f00237d2109447618eb387b89f540eba2b58dd64baf289a76483019d90e2c2f86d0a57710b5d48f3186a6a31de30e3effee6455e4517c853db9f039f0a0a127126a29a861e60124e01aa30593f82cdf6357189b27e25eccb180e67602aadedbe13670c9d14d5c5e5cde5c95d057ba17de6f6c00f3bccde5f8dad9edb23050a334f6f211a61fd2530e01fcea528f673bea57ec8c27b7bbf4e7c3afb2cb4410aa15fd3069af343e3947798262a90a2406a6a001cea78fe9ad6e83a4d90b8c051a6e00708601de16c726716aa3e09211312ecaa9b7d20462d5fee97451ee6199e5f8d1d609bd62a0153dbb15f0e907aff8a47a5a6b8b9670e938b05582908736acdd131c641c964b652d93a0ef44488fb5264c0b2288d0588c573d39e47e77cbb63a33e8f473257d2e4440ee6fff2992ba7cf4b39af6c8fa8b01754e6ac970c844032ff9a3d20d8db547d76ca87a9a6530c11a86a30db09db8ecacec982c1fcd5425f935b015246414a42802616f7adb0394e101f87185d9763990791bf97d18a6d8b21cd618cdd84b628eed74d134261f810a445a4af58eec4330e23f786293a0bcc0f932ca4c4bb5656a7bc361954a5d93f7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
    let reported_tower_height = 1;

    // return solution
    let proof = MinerState::create_proof_blob(challenge, difficulty, solution, reported_tower_height);
    MinerState::commit_state(sender, proof);

    let verified_tower_height_after = MinerState::get_miner_tower_height({{alice}});
    // Debug::print(&verified_tower_height_after);

    Transaction::assert(verified_tower_height_after == 1, 10008001);


}
}
// check: EXECUTED
