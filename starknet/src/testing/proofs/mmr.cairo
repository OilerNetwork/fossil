use fossil::types::{MMRProof};

pub fn proof_1() -> MMRProof {
    MMRProof {
        element_index: 191,
        element_hash: 0x799c04bffdee59cbe1f71aabb5dd6b50f2330c2343812dd30cf21bd5f96be982,
        siblings: array![
            0x648d7eea42b054baf0d9b1083bb1680013d18435de35e528989a629d14716234,
            0x7039ad4f2e886e64bd9ab58af5e9645bf4dce4f19d08bb9c7037433e61686a19,
        ]
            .span(),
        peaks: array![
            0xe9bc1501c1b36bdef0f6738950e0e626b2ffc096bea3ef9d7ccaf713cafce8ae,
            0x44f82d2fe372488a2c728d5dbc7af6edc75707ba7073d48576ac2fb5a62f7c32,
            0x0a03d84e34145339edb94dc9abd591c3d504746b69d3d3237cdaf776c89316e2,
        ]
            .span(),
        elements_count: 197,
    }
}

pub fn proof_2() -> MMRProof {
    MMRProof {
        element_index: 16,
        element_hash: 0x7701fb3ede3096fad1b6546eb3ee18a395263631f21990289807b0364a50d3f4,
        siblings: array![
            0xcbc699c48bfd4df668eb7358b610fbec7b55c265ecb7c1c7d9fffdd0796fc2bd,
            0x9378e053e0debece3135c9630b8a6ffee46cb8c8484bf88849e21e6b7e7a9dce,
            0xcd0fe8e79cbff6574bb498ddb4f57437d506e262c435b03b55f13009c9a59232,
            0x57003624be61b0b94251ee30b2ac99335378f8e18abb8ccb4a5acb3510d33df4,
            0x92f102ed54dbaa2f90feb80c59bcebe03a5d04c66c93e109b2817d3455ef26c5,
            0xe907f19ebdd15613a45343e55c55dbdece057caeee84971f9ef99178086819a8
        ]
            .span(),
        peaks: array![
            0xe9bc1501c1b36bdef0f6738950e0e626b2ffc096bea3ef9d7ccaf713cafce8ae,
            0x44f82d2fe372488a2c728d5dbc7af6edc75707ba7073d48576ac2fb5a62f7c32,
            0x0a03d84e34145339edb94dc9abd591c3d504746b69d3d3237cdaf776c89316e2,
        ]
            .span(),
        elements_count: 197,
    }
}

pub fn proof_3() -> MMRProof {
    MMRProof {
        element_index: 1,
        element_hash: 0x88e96d4537bea4d9c05d12549907b32561d3bf31f45aae734cdc119f13406cb6,
        siblings: array![0xb495a1d7e6663152ae92708da4843337b958146015a2802f4193a410044698c9,]
            .span(),
        peaks: array![
            0xcb3d065765ae4f16ff773bd378cf7ba07ef575caa282ddb6f535f10531cf1766,
            0x3d6122660cc824376f11ee842f83addc3525e2dd6756b9bcf0affa6aa88cf741,
        ]
            .span(),
        elements_count: 4,
    }
}


pub fn proof_anvil() -> MMRProof {
    MMRProof {
        element_index: 5,
        element_hash: 0xfa3c38fcffbc1b3396fe892973fadbff826a80fb25a822925073e1f756804739,
        siblings: array![
            0x87d4dd35a256ad6625d847aac59d8c1853ff48f46f5ce9854b767e1e98696859,
            0xd017ac458c2380f7032a1533c59e9bee2d6226bcaf33aa6286bbbd39be0828ee
        ]
            .span(),
        peaks: array![
            0x16893a48ef310cdee73bed41619fa909455bd4c5a04bf6cdb655dde8bf83d7ba,
            0x679cc242d6e104aa6e0056ac0327e5be83afd5b3b88d31b909c4c311d45b7e9b
        ]
            .span(),
        elements_count: 8
    }
}

pub fn block_rlp_anvil() -> Span<u8> {
    array![
        249,
        1,
        247,
        160,
        243,
        49,
        245,
        39,
        207,
        242,
        223,
        184,
        177,
        161,
        72,
        153,
        226,
        154,
        110,
        119,
        250,
        89,
        230,
        68,
        22,
        179,
        159,
        110,
        234,
        206,
        170,
        20,
        202,
        52,
        155,
        120,
        160,
        29,
        204,
        77,
        232,
        222,
        199,
        93,
        122,
        171,
        133,
        181,
        103,
        182,
        204,
        212,
        26,
        211,
        18,
        69,
        27,
        148,
        138,
        116,
        19,
        240,
        161,
        66,
        253,
        64,
        212,
        147,
        71,
        148,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        160,
        174,
        225,
        100,
        192,
        228,
        144,
        11,
        163,
        171,
        100,
        71,
        224,
        119,
        178,
        116,
        78,
        30,
        44,
        47,
        213,
        57,
        220,
        181,
        70,
        94,
        120,
        18,
        100,
        52,
        104,
        181,
        106,
        160,
        246,
        253,
        218,
        118,
        98,
        35,
        27,
        28,
        221,
        143,
        136,
        207,
        29,
        140,
        121,
        138,
        171,
        93,
        122,
        119,
        250,
        175,
        236,
        27,
        195,
        146,
        215,
        19,
        221,
        74,
        232,
        77,
        160,
        119,
        147,
        249,
        82,
        19,
        131,
        100,
        96,
        104,
        153,
        10,
        115,
        169,
        71,
        0,
        34,
        111,
        135,
        203,
        233,
        166,
        51,
        42,
        245,
        90,
        33,
        135,
        29,
        252,
        48,
        245,
        135,
        185,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        128,
        3,
        132,
        1,
        201,
        195,
        128,
        130,
        169,
        230,
        132,
        102,
        139,
        230,
        127,
        128,
        160,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        136,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0
    ]
        .span()
}


pub fn block_rlp_3() -> Span<u8> {
    array![
        249,
        2,
        17,
        160,
        212,
        229,
        103,
        64,
        248,
        118,
        174,
        248,
        192,
        16,
        184,
        106,
        64,
        213,
        245,
        103,
        69,
        161,
        24,
        208,
        144,
        106,
        52,
        230,
        154,
        236,
        140,
        13,
        177,
        203,
        143,
        163,
        160,
        29,
        204,
        77,
        232,
        222,
        199,
        93,
        122,
        171,
        133,
        181,
        103,
        182,
        204,
        212,
        26,
        211,
        18,
        69,
        27,
        148,
        138,
        116,
        19,
        240,
        161,
        66,
        253,
        64,
        212,
        147,
        71,
        148,
        5,
        165,
        110,
        45,
        82,
        200,
        23,
        22,
        24,
        131,
        245,
        12,
        68,
        28,
        50,
        40,
        207,
        229,
        77,
        159,
        160,
        214,
        126,
        77,
        69,
        3,
        67,
        4,
        100,
        37,
        174,
        66,
        113,
        71,
        67,
        83,
        133,
        122,
        184,
        96,
        219,
        192,
        161,
        221,
        230,
        75,
        65,
        181,
        205,
        58,
        83,
        43,
        243,
        160,
        86,
        232,
        31,
        23,
        27,
        204,
        85,
        166,
        255,
        131,
        69,
        230,
        146,
        192,
        248,
        110,
        91,
        72,
        224,
        27,
        153,
        108,
        173,
        192,
        1,
        98,
        47,
        181,
        227,
        99,
        180,
        33,
        160,
        86,
        232,
        31,
        23,
        27,
        204,
        85,
        166,
        255,
        131,
        69,
        230,
        146,
        192,
        248,
        110,
        91,
        72,
        224,
        27,
        153,
        108,
        173,
        192,
        1,
        98,
        47,
        181,
        227,
        99,
        180,
        33,
        185,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        133,
        3,
        255,
        128,
        0,
        0,
        1,
        130,
        19,
        136,
        128,
        132,
        85,
        186,
        66,
        36,
        153,
        71,
        101,
        116,
        104,
        47,
        118,
        49,
        46,
        48,
        46,
        48,
        47,
        108,
        105,
        110,
        117,
        120,
        47,
        103,
        111,
        49,
        46,
        52,
        46,
        50,
        160,
        150,
        155,
        144,
        13,
        226,
        123,
        106,
        198,
        166,
        119,
        66,
        54,
        93,
        214,
        95,
        85,
        160,
        82,
        108,
        65,
        253,
        24,
        225,
        177,
        111,
        26,
        18,
        21,
        194,
        230,
        111,
        89,
        136,
        83,
        155,
        212,
        151,
        159,
        239,
        30,
        196
    ]
        .span()
}
