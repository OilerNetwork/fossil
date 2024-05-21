use core::integer::u32_safe_divmod;
use fossil::library::{
    array_utils::ArrayTraitExt, words64_utils::split_u256_to_u64_array, keccak256::keccak256,
    bitshift::BitShift
};
use fossil::types::Words64Sequence;

pub fn keccak_words64(input: Words64Sequence) -> Words64Sequence {
    let mut bytes = u64_to_u8_array(input.values, input.len_bytes);
    let hash = keccak256(bytes.span());
    let values_u64 = split_u256_to_u64_array(hash);
    Words64Sequence { values: values_u64, len_bytes: 32 }
}


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
                17942923246514633984,
                1217778639264257798,
                3243279504191013180,
                14723370821652241320,
                11876781802560999291,
                11645881558321686972,
                13871344797908757793,
                2362118107784989529,
                3729048587844204394,
                127498199932513093,
                12830234107242481793,
                17092578610358934796,
                6292994657085071411,
                2813153997891533456,
                15503051937804526418,
                14693378565221983783,
                17309229813288485536,
                10024440226435918317,
                17991830461303330473,
                4612901929982347652,
                6728153008232095548,
                11530644071876706148,
                5830808610847735054,
                16199323514295596694,
                17056905241327656581,
                3287855021194173693,
                10613910810295207997,
                5021072433707118047,
                3125461990629308481,
                2930894008894207662,
                7358759186577549186,
                4980921837089693493,
                8183590806986482414,
                11990748934712803801,
                10163789206891404797,
                8803125258096371931,
                449984146355388308,
                10753009927459337991,
                6606257214577321552,
                5987708696335975542,
                6731394593750136673,
                10833255907889029430,
                12697098198135606904,
                14357847415158140774,
                675693620912083882,
                4060171207335649390,
                10959951412951310105,
                1521995407996711912,
                16257486666495912220,
                10086620457743506848,
                16638145092707550595,
                17419406976225753539,
                10089725536367957483,
                9495911683512459393,
                11593171291811983960,
                11792517165791113656,
                4895961046210392611,
                1838108385884030291,
                1342183777993664401,
                1779608552166152062,
                14590500149490734592,
                7233715467461549812,
                1602895442170187786,
                15789562821152661057,
                12911895218267247544,
                5005802232216386625,
                1278861440
            ]
                .span(),
            len_bytes: 532
        };
        let result = super::keccak_words64(input);
        assert_eq!(result.len_bytes, 32);
        assert_eq!(
            result.values,
            array![
                2325475127108968072, 11876231566175855444, 16474141678601410074, 6802953270526873938
            ]
                .span()
        );
    }
}
