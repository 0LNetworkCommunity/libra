//! Benchmarks

use criterion::{criterion_group, criterion_main, Criterion};
use tower::delay;
use vdf::VDFParams;
use vdf::WesolowskiVDFParams;
use vdf::VDF;

fn bench_delay(c: &mut Criterion) {
    c.bench_function("delay_100", |b| {
        b.iter(|| delay::do_delay(b"test preimage", 100, 2048))
    });

    c.bench_function("delay_preimage_100_2048", |b| {
        b.iter(|| {
            let bytes = hex::decode(ALICE_PREIMAGE).unwrap();
            delay::do_delay(bytes.as_slice(), 100, 2048)
        })
    });

    c.bench_function("delay_preimage_5m_2048", |b| {
        b.iter(|| {
            let bytes = hex::decode(ALICE_PREIMAGE).unwrap();
            delay::do_delay(bytes.as_slice(), 5_000_000, 2048)
        })
    });

    c.bench_function("delay_preimage_5m_512", |b| {
        b.iter(|| {
            let bytes = hex::decode(ALICE_PREIMAGE).unwrap();
            delay::do_delay(bytes.as_slice(), 5_000_000, 512)
        })
    });

    c.bench_function("delay_preimage_5m_256", |b| {
        b.iter(|| {
            let bytes = hex::decode(ALICE_PREIMAGE).unwrap();
            delay::do_delay(bytes.as_slice(), 5_000_000, 256)
        })
    });

    c.bench_function("verify_100_2048", |b| {
        b.iter(|| {
            let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();
            let proof_bytes = hex::decode(ALICE_PROOF_100_2048).unwrap();
            delay::verify(preimage_bytes.as_slice(), proof_bytes.as_slice(), 100, 2048)
        })
    });

    c.bench_function("verify_5m_2048", |b| {
        b.iter(|| {
            let preimage_bytes = hex::decode(PREIMAGE_5M_2048).unwrap();
            let proof_bytes = hex::decode(PROOF_5M_2048).unwrap();
            let difficulty = 5_000_000;
            let security = 2048;
            let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
            vdf.verify(preimage_bytes.as_slice(), difficulty, proof_bytes.as_slice()).unwrap();
        })
    });
    
    c.bench_function("verify_5m_512", |b| {
        b.iter(|| {
            let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();
            let proof_bytes = hex::decode(ALICE_PROOF_5M_512).unwrap();
            let difficulty = 5_000_000;
            let security = 512;
            let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
            vdf.verify(preimage_bytes.as_slice(), difficulty, proof_bytes.as_slice()).unwrap();
        })
    });



    c.bench_function("verify_5m_256", |b| {
        b.iter(|| {
            let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();
            let proof_bytes = hex::decode(ALICE_PROOF_5M_256).unwrap();
            let difficulty = 5_000_000;
            let security = 256;
            let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
            vdf.verify(preimage_bytes.as_slice(), difficulty, proof_bytes.as_slice()).unwrap();
        })
    });

    c.bench_function("prove_100_2048", |b| {
        b.iter(|| {
            let security = 2048;
            let difficulty = 100;
            let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();

            let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
            vdf.solve(preimage_bytes.as_slice(), difficulty)
                .expect("iterations should have been valiated earlier")
        })
    });
    
    c.bench_function("prove_100_1024", |b| {
        b.iter(|| {
            let security = 1024;
            let difficulty = 100;
            let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();

            let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
            vdf.solve(preimage_bytes.as_slice(), difficulty)
                .expect("iterations should have been valiated earlier")
        })
    });

    c.bench_function("prove_100_512", |b| {
        b.iter(|| {
            let security = 512;
            let difficulty = 100;
            let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();

            let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
            vdf.solve(preimage_bytes.as_slice(), difficulty)
                .expect("iterations should have been valiated earlier")
        })
    });
}

// sample size configs not documented. Found here: https://github.com/bheisler/criterion.rs/issues/407
criterion_group! {
    name = ol_benches;
    config = Criterion::default().sample_size(10);  // sampling size
    targets = bench_delay
}

criterion_main!(ol_benches);

const ALICE_PREIMAGE: &str = "87515d94a244235a1433d7117bc0cb154c613c2f4b1e67ca8d98a542ee3f59f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304c20746573746e65746400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050726f74657374732072616765206163726f737320746865206e6174696f6e";

const ALICE_PROOF_100_2048: &str = "002c4dc1276a8a58ea88fc9974c847f14866420cbc62e5712baf1ae26b6c38a393c4acba3f72d8653e4b2566c84369601bdd1de5249233f60391913b59f0b7f797f66897de17fb44a6024570d2f60e6c5c08e3156d559fbd901fad0f1343e0109a9083e661e5d7f8c1cc62e815afeee31d04af8b8f31c39a5f4636af2b468bf59a0010f48d79e7475be62e7007d71b7355944f8164e761cd9aca671a4066114e1382fbe98834fe32cf494d01f31d1b98e3ef6bffa543928810535a063c7bbf491c472263a44d9269b1cbcb0aa351f8bd894e278b5d5667cc3f26a35b9f8fd985e4424bedbb3b77bdcc678ccbb9ed92c1730dcdd3a89c1a8766cbefa75d6eeb7e5921000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";


const ALICE_PROOF_5M_512: &str = "004cceceab990902f8091d5a5f862cb572e6a849b997f8cb14e01868508693021800478c2fab72d55b5577f34890f03e9cdfe47771724327f0c112dd6a1dfaaefed30068526590a7bfbef7c0a1d6320f0ecbb2d5bdc55952bfddbf166f5a0b7ea48791003eeff4492530be6e9b6e98bc24ea8411dedff40ff918195c87c6c85b1959331b";

const ALICE_PROOF_5M_256: &str = "0008bc09e6166510a94621cc41b3751780fffc31e659e3ea5ad5996c8bea13ebe46900322198e8a6e67e983df51ce82d684310001ac44ef7cfef8e66f54eab5b9a87bff7";


const PREIMAGE_5M_2048: &str = "df6046be26c9a64ececa098a5ecbf724d91619ce64a4899087ac2098d394df59";

const PROOF_5M_2048: &str = "0061aec41fb46a2db9fd56d0112e432a55a5857df2626a80188b11228aab9a5e8ef2ee2c0838b1d623100fbf2e9516528733e8b376ec54c82a6f784ba146ea0fa004ef2d03d755ad5e41b5d09c0d073a1a507d4569505b4ad1d0ceb2bc1132e2f8a94f4ae5faa9e38f29703baf74d597e9e9f6a200a24add3d9109fe9b2aee72b6000b762eea2ec3fb9551366a0bd93bb2194f0b94c3020ed1172a7a99c3a3f7fa74f403ce9262e6bf5a6c128b52f577c2d99b38271cd23f26332be0819cad4ac5676074e203f448a1c94e443e3c83cb636c760a94a1b8cd0f4253970f9a571e62670a28b0adba42e1edfb9490ee5a5a83bcd6af50c6e35743d3b0c8bcacaf4282370014d13eb080ce34a49b2d49d4477672db2cd527e04cd0c8a6d9094f0d5e4cfe8edc21228ca12da68bbd53fca5b23fc275c82ba90197dc53f3eaf34393905ebf25a5f7e429d3c9dcdfa22c3098f2761c161d65c0eec4f57dd1b1354ccc9ae0b54f2741ac4a93dc1e80afa940dc515f25e66fc93614f51ac3bbfc64c2701161ce86fff832feb81d2e177b24315381a45c18d16ccac6d554a8871bcf859139d2ba6985ca57703b301ecce28d7922df352bdd5103295472d38840c3cf5e30d760083b39ae8cee53dfc9c5034443849f10db6425332603966fecfef38382ad7fb5d4618eb96a826fd2deeec0977c5bdeb270b09fd84eb974f87e14df1e7654217d69737f";