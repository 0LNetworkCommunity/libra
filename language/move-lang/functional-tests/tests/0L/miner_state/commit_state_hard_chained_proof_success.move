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
// In fixtures elsewhere this is "Alice" block 0.
fun main(sender: &signer) {
    let difficulty = 2400000;
    let challenge = x"3dfca19b9914d78ec0c3d04c486e7baa402e9aaf54ca8c39bab641b0c9829070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006578706572696d656e74616c009f240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074657374";
    // Generate solutions with cd ./verfiable-delay/ cargo run -- -l=4096 aa 100
    // the -l=4096 is important because this is the security paramater of 0L miner.
    let solution = x"0053e7419eb01e955666d49a25912dd82f4d3d627aededf01478bcef332f2d68fd6238e3cc4636af163c72be8aaf65a7093a70d74d06342115b3d29f50a6eb51f310595cc7a0e2872d4cd6ecfee18020d5cde01fe8bccb451c61bd00c0932fc64e6048e3ad7b458d6250c8881af5a58a3aa42200dcd13681883bb0019e3dfa782300ef8dc00c1f83cb7fbee581a277cf8a6c9535fd5847697325c0db526d4ff1ddf7282eac92de127fbb071f49f3abb54f0c98ea6383b3764fc0dfc1b9cba71be6cda2e927882bd56cf2985db15bfa3c9117982ef97fc415ba9805b731d313b49cb53935fb6c02c91d1a2f6ebe19ef720f1e0178fa31eecdb3e1609710ea583e28004bd6683777eee6278c773a8aa2db640deee384f1304aebd09de4837c4e76ce362e2060770790b2c6f57daa263e1638dccff310cce683c7b5d86353c8550a97ee8c91142f51f0b815d4dd9fe23fd062163427523b3c45ac947edf6189ce75bbd7d07a424a7cf925a1cf7a3f9c7a46fa6eba1ab7cbc6020b9dffbf11aa14f68f74ba50576be7374ef0173caa4f4f366255467af0ec0e73b6133c572c068db9d8c8bcb54fbb3cd5e7786480e166d6e764cf719cb134d6512995150fd5b2be7189f709cf5482379edb1907b553962909f940729d48d570240c67b298c2b64d0397437880c1df3d0331811420086eed1da3fc88a43d7baf2c3f75106b78c57bb4a393002da59a4f3e1ea4fc75cc9028451f0750d6a9aabee14334c12b58bb07280287cf3454ac3c2a42c4f0f6489a253613eb13d55f2d1f5f9fd63da3c3daf75a700f3a5775914c395413696fbd967f577ad8bd0c0b91106546594c68f9fe91161c1ec7afe7275e2dc4f7d0a286f943ec41d221a020a73d586ef4731e615f6f3276382111405af6192bab0fe8c577b368543b8232614180ba5042bda4330c1e293454bfca309e22a5d33d5a97f0c1d1c2f60ad41f07254cab13a9c4c526301afe374220c3b1cb3dcaa901373a410ee9b7fc0c05a07dd8e09c700166765430fec25b286290d39e6b65b47cab5bfce98994d844b92c164702f6493b6fe9971afa91697f83001de859c1a0220ec3ebabc9551c32e795650650592694a258e63523377025c7593676e457e604025023c2676ff4198ecffa107c8c433b0f41de1944f7d8c56d37cda3ee3f446d14d379329ecbbf09b51ba4e81803388cabee334a2bb55b1336ae5a7fb80f296e03deaeac4f373d0c509c75fc946159e88c2f9251f8d25913631f49a9b1c9f0fb2580baa3aa33d0d9c6e43460a072075c30286155bbe5bc838850697afc23bf6d048913153c34b596f821db3613ae4bcaf13c50f0c32dbbd60dc83b17376265f5792594fbcfb4cd18e9acf77d6869866585fd723e182d6e75e48ba3c53e7311c8e154e8fd864b6f13ca31748447b6a33ed6822c015e21baad76b7";
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
use 0x0::Debug;
// use 0x0::Globals;
// use 0x0::Transaction;

// SIMULATES THE SECOND PROOF OF THE MINER (block_1.json)
fun main(sender: &signer) {
    let difficulty = 2400000;

    // Generate solutions with cd ./verfiable-delay/ cargo run -- -l=4096 aa 100
    // the -l=4096 is important because this is the security paramater of 0L miner.
    let challenge = x"e1492678a5cd8f0acad2fe0d0abd83d6027c7288bba98cbd0de7bb4bf8acfc4c";

    let solution = x"000fc3a41ba7ef7270703184c029ab6e95c60f22d8f3191746354fa8fbbceb1be2af6946bcff93ec423ecc1a9711a8cdd5689c1940cee5c6a6582a9c86181b3b61d71b39cc0d81f93d5303e738a001b46ddca157b680d1379543bc0450b7aaa3ac40c5877473ce1fc332308e7c84fbc392a6590b1f952fd7afcba6dfe686da7d071bb97543ed345b451dce36975a67ebefd9df7be365398651a6a01f3928779e8595fedb160264f26b8347f7841b2801169a0a3f8e835a7b9334e4d3097a545b0873dae19f9fdf095b9ebd1910de6c9eca58c8e7924e6e0131f23801caa60b2013a6bb9a2ef729ff32ffeb065d7c11b53d57742fc782a0df8fe7f3e418d84b2b31fffcbd08c618e13ecb29417d93c22bdeae44d0c939fcc2af284e665b7da095950322b1640b591cdea7adb52efa355d7345d9c0c145dcb5bb5716683f6a8b9910563cfaa93a8bf2111ac7c012d4e97fbbef2466ce6b81f555195c93bcb76aec8785398d6cdd09ef2de2d19a03d59ab855aeb40d804d8a8e9aa6997bb0ca45eaf1e607d4c1e5e8ad32a700bef7464ddb8a81dcf9b4a3e4d1b14156b70e5175b45f2ef8aa571025494ac09b19f1a1333627a5a0a7ce9b909106d011d38e90936e9b5c6eeb06d3c8e732aad5cdd470ef516799b3d17eb9493deb5f404ff549c893387df1445809c8178fb1d4749cde4f3e1a045275a9d4690230b339bf0d7ce610e62b004e45d3450a03d389898a2bb4ef1e4aae9e80c1e893c00ea013ba0a0db4d3cebc3629d131d771fafc1b33640f1943827bb300d8f00c9cce40a8c2057d3e46b0d05f90868e852b37d10eee761dab4e2cb1bddb9ad8951dd193aa02a2cd2a56c9826f403659c38e300b5f6878e67bb902e3053c765f387c6b12d06574808f72505c305df1de68d652fffc17dd6c98abaa036ebcc6171c1944aecb96f750add1cca098c587989355d4cedf43b378f138fb4a34f3cc5d43fae27769e0f1e42df57a687a1a0b959183556fcb66d0be5b5775f93c40632f8f0e7365cbf14ce4b815611d047e77b214c3e589c80957135292edc6da406b6b88bbfa6f9ed2ff88847a5ac6ffbb34617991894dbee37e26f0f3173e9456b8ccf61dcffdd5e8c02a57ead34b0092edd7666c3b49b61e95f64d177d188a19ce527156aa0ba00b1c56a5d95569a0f1440c4727ac6bc4dc33fb3cebf2aaf658ef3881c6e7fd4a2888907d9a48dadff8b3df42df59eef3318ed1cea1fac8b61f1f68067e5ea58922cccd8ff4f28008ff5208a9631c5ad3908eb9d22d9d82054211be82654402555298b2bcc5ab8e1ba60f7eeeeae027999e6bf6ca6265cf65271e677c40a96bef0940ff30e9ee6bdffd25110c77d483935b5694bfd3006081e8daf14c6e0236f80c6f19e1c7215f276ceca7fc526359af3ace2b045afd6be7b2c7c3767124865cb4e8779764a47ef3";
    let reported_tower_height = 1;

    // return solution
    let proof = MinerState::create_proof_blob(challenge, difficulty, solution, reported_tower_height);
    MinerState::commit_state(sender, proof);

    let verified_tower_height_after = MinerState::get_miner_tower_height({{alice}});
    Debug::print(&verified_tower_height_after);

    // Transaction::assert(verified_tower_height_after == reported_tower_height, 10008001);


}
}
// check: EXECUTED
