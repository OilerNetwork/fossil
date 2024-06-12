//! Library for Keccak Util.

// *************************************************************************
//                                  IMPORTS
// *************************************************************************
use core::integer::u32_safe_divmod;
use fossil::library::{
    array_utils::ArrayTraitExt, words64_utils::split_u256_to_u64_array, keccak256::keccak256,
    bitshift::BitShift
};
use fossil::types::Words64Sequence;

/// Computes the Keccak-256 hash of a given `Words64Sequence`.
///
/// # Arguments
/// * `input` - A `Words64Sequence`.
///
/// # Returns
/// * `Words64Sequence`: The resulting Keccak-256 hash represented as a sequence of 64-bit words,
///   with a length of 32 bytes.
/// 
/// This function takes an input `Words64Sequence`, converts it to a byte array,
/// computes the Keccak-256 hash of the byte array, and returns the hash as a new `Words64Sequence`.
pub fn keccak_words64(input: Words64Sequence) -> Words64Sequence {
    let mut bytes = u64_to_u8_array(input.values, input.len_bytes);
    let hash = keccak256(bytes.span());
    let values_u64 = split_u256_to_u64_array(hash);
    Words64Sequence { values: values_u64, len_bytes: 32 }
}

/// Converts a span of 64-bit unsigned integers to an array of u8 with a length specified by the `len_bytes` parameter.
///
/// # Arguments
/// * `input` - The span of 64-bit unsigned integers to convert.
/// * `len_bytes` - The desired length of the output byte array.
///
/// # Returns
/// * `Array<u8>` - The resulting byte array in big-endian order.
pub fn u64_to_u8_array(input: Span<u64>, len_bytes: usize) -> Array<u8> {
    let mut bytes: Array<u8> = array![];
    let (full_words, remainder) = u32_safe_divmod(len_bytes, 8);

    let mut i = 0;
    while (i < full_words) {
        let value = *input.at(i);
        let input_bytes = u64_to_big_endian_bytes(value, 8);
        let len = input_bytes.len();
        let mut j = 0;
        while (j < len) {
            bytes.append(*input_bytes.at(j));
            j += 1;
        };
        i += 1;
    };

    if remainder > 0 {
        let value = *input.at(full_words);
        let input_bytes = u64_to_big_endian_bytes(value, remainder);
        let len = input_bytes.len();
        let mut j = 0;
        while (j < len) {
            bytes.append(*input_bytes.at(j));
            j += 1;
        };
    }

    bytes
}

/// Converts a 64-bit unsigned integer into big-endian byte slice.
///
/// # Arguments
/// * `num` - A 64-bit unsigned integer to be converted.
/// * `len` - The length of the output byte array.
///
/// # Returns
/// * `Array<u8>` - The resulting byte array.
fn u64_to_big_endian_bytes(num: u64, len: u32) -> Array<u8> {
    let mut out = array![];

    let mut i = 0_u32;
    while (i < len) {
        let byte: u8 = (BitShift::shr(num, ((len - 1 - i) * 8).into()) & 0xFF).try_into().unwrap();
        out.append(byte);
        i += 1;
    };

    out
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_u64_to_big_endian_bytes() {
        let res = super::u64_to_big_endian_bytes(17942923244738002036, 8);
        assert_eq!(res, array![249, 2, 17, 160, 26, 181, 60, 116]);
    }

    #[test]
    fn test_u64_to_u8_array() {
        let input = array![
            17942923244738002036, 14091505668525627713, 127595607468770955, 14464723023390202793,
        ];
        let res = super::u64_to_u8_array(input.span(), 32);
        let expected = array![
            249,
            2,
            17,
            160,
            26,
            181,
            60,
            116,
            195,
            143,
            21,
            190,
            218,
            223,
            153,
            65,
            1,
            197,
            79,
            135,
            106,
            19,
            134,
            139,
            200,
            189,
            4,
            243,
            207,
            150,
            91,
            169
        ];
        assert_eq!(res, expected);
    }

    #[test]
    fn test_keccak_words64_real_value() {
        let mut input = super::Words64Sequence {
            values: array![
                17942959528274807177,
                1927228973485429901,
                7049293366348895562,
                10219141188940931770,
                9092674350772767821,
                16780068465932993973,
                7473385843023090245,
                1987365566732607810,
                18248819419131450658,
                2490734077656317405,
                4079348538115738699,
                12674712715010592696,
                16728002970975567629,
                6153289390977925556,
                15478637057967092601,
                6841524877519110547,
                11303780052394131703,
                9658397580205812468,
                16696463006537925186,
                14796554910305534520,
                10841705015525537919,
                8834250584765753791,
                12233725178181605666,
                4699644005166153984,
                1198472417113103216,
                14558070035248615943,
                3007158258583810838,
                1184309401937316256,
                1816081965892305507,
                13608877286246744,
                1379660904984192184,
                7394143424311992704,
                10451366035201494282,
                7747247225283818736,
                7032661491677272449,
                1244086496675417458,
                685960360037892418,
                342882754345856770,
                734272282351928320,
                14273633264521990230,
                6931607543949629794,
                8668589058259289908,
                4828712653188305672,
                342837910978956386,
                3405761294366695427,
                7331944335937637572,
                433088975884517410,
                2391878720375620608,
                6126107169448530529,
                298005185128041036,
                3296673902291912724,
                423080283626086419,
                43030492320891138,
                2912791179518061892,
                16041955120314324036,
                720747724045224993,
                9260527979627906049,
                14538605325294518404,
                7324188847303189857,
                8531350836325477476,
                3346018837559785325,
                9695600228656099426,
                12703997634894948524,
                9739605974250163504,
                7654252154571980800,
                34051,
                16379068552914563754,
                11871800999391405236,
                16349200285595367774,
                9762000321071382634,
                14810382113852882944
            ]
                .span(),
            len_bytes: 565
        };
        let result = super::keccak_words64(input);

        assert_eq!(result.len_bytes, 32);
    // println!("{:?}", words64_to_int(result));
    // assert_eq!(
    //     result.values,
    //     array![
    //         2325475127108968072, 11876231566175855444, 16474141678601410074, 6802953270526873938
    //     ]
    //         .span()
    // );
    }

    #[test]
    fn test_keccak_rlp_bytes() {
        let rlp = array![
            249,
            2,
            5,
            160,
            142,
            43,
            107,
            168,
            212,
            64,
            48,
            116,
            87,
            128,
            127,
            233,
            187,
            225,
            211,
            239,
            51,
            10,
            177,
            33,
            119,
            22,
            111,
            105,
            248,
            212,
            247,
            24,
            110,
            57,
            109,
            231,
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
            62,
            206,
            240,
            141,
            14,
            45,
            173,
            128,
            56,
            71,
            224,
            82,
            36,
            155,
            180,
            248,
            191,
            242,
            213,
            187,
            160,
            64,
            53,
            246,
            0,
            186,
            24,
            69,
            62,
            14,
            69,
            6,
            185,
            128,
            24,
            4,
            36,
            200,
            241,
            133,
            60,
            197,
            223,
            254,
            160,
            190,
            62,
            150,
            9,
            147,
            183,
            248,
            40,
            160,
            17,
            62,
            127,
            58,
            191,
            224,
            211,
            7,
            160,
            169,
            69,
            195,
            69,
            47,
            174,
            126,
            52,
            23,
            109,
            36,
            50,
            213,
            245,
            155,
            236,
            211,
            178,
            202,
            42,
            58,
            202,
            191,
            160,
            137,
            181,
            196,
            106,
            221,
            42,
            214,
            124,
            184,
            21,
            250,
            197,
            132,
            117,
            222,
            103,
            231,
            237,
            21,
            87,
            71,
            127,
            152,
            13,
            55,
            96,
            91,
            93,
            117,
            245,
            239,
            199,
            185,
            1,
            0,
            92,
            167,
            65,
            135,
            229,
            83,
            21,
            47,
            25,
            212,
            50,
            246,
            244,
            32,
            186,
            55,
            9,
            86,
            1,
            135,
            145,
            208,
            76,
            226,
            1,
            61,
            98,
            69,
            252,
            201,
            245,
            129,
            130,
            63,
            109,
            88,
            228,
            4,
            183,
            224,
            213,
            69,
            218,
            251,
            59,
            173,
            1,
            16,
            10,
            231,
            133,
            230,
            75,
            180,
            233,
            81,
            109,
            67,
            133,
            226,
            18,
            166,
            104,
            218,
            88,
            104,
            81,
            32,
            176,
            2,
            179,
            62,
            202,
            226,
            218,
            31,
            176,
            136,
            119,
            228,
            25,
            60,
            156,
            71,
            14,
            108,
            51,
            9,
            82,
            78,
            125,
            123,
            144,
            127,
            5,
            227,
            190,
            25,
            195,
            64,
            187,
            2,
            159,
            162,
            197,
            150,
            252,
            1,
            66,
            48,
            190,
            192,
            210,
            51,
            221,
            233,
            249,
            91,
            166,
            231,
            131,
            69,
            115,
            250,
            162,
            45,
            79,
            170,
            217,
            229,
            161,
            127,
            158,
            208,
            80,
            152,
            179,
            209,
            211,
            81,
            9,
            130,
            184,
            63,
            83,
            68,
            204,
            149,
            109,
            97,
            181,
            61,
            191,
            117,
            9,
            249,
            45,
            90,
            59,
            178,
            183,
            222,
            94,
            104,
            34,
            33,
            58,
            51,
            34,
            181,
            111,
            180,
            152,
            6,
            183,
            160,
            52,
            30,
            78,
            16,
            0,
            182,
            48,
            35,
            31,
            115,
            150,
            132,
            220,
            191,
            255,
            29,
            91,
            64,
            22,
            238,
            117,
            171,
            76,
            74,
            41,
            210,
            159,
            247,
            199,
            107,
            29,
            228,
            127,
            77,
            243,
            8,
            101,
            139,
            74,
            82,
            210,
            98,
            40,
            214,
            56,
            212,
            236,
            96,
            2,
            48,
            170,
            146,
            61,
            98,
            27,
            104,
            248,
            167,
            23,
            68,
            67,
            172,
            192,
            32,
            197,
            161,
            202,
            48,
            127,
            240,
            129,
            248,
            27,
            200,
            205,
            190,
            234,
            5,
            26,
            125,
            135,
            27,
            129,
            193,
            190,
            5,
            178,
            24,
            131,
            197,
            212,
            135,
            131,
            229,
            83,
            245,
            131,
            229,
            74,
            24,
            132,
            97,
            11,
            218,
            156,
            132,
            118,
            105,
            114,
            49,
            160,
            6,
            159,
            71,
            128,
            213,
            122,
            170,
            116,
            174,
            118,
            140,
            41,
            72,
            175,
            175,
            159,
            92,
            3,
            210,
            110,
            89,
            204,
            201,
            253,
            147,
            9,
            42,
            248,
            164,
            139,
            237,
            92,
            136,
            163,
            222,
            109,
            29,
            81,
            234,
            143,
            125
        ];
        let result = super::keccak256(rlp.span());
        assert_eq!(result, 0x3de6bb3849a138e6ab0b83a3a00dc7433f1e83f7fd488e4bba78f2fe2631a633);
    }
}
