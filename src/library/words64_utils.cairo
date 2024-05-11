use core::integer::u32_safe_divmod;
use fossil::library::{array_utils::ArrayTraitExt, bitshift::BitShift};
use fossil::types::Words64Sequence;

const U64_MASK: u256 = 0xFFFFFFFFFFFFFFFF;

fn words64_to_u256(input: Span<u64>) -> u256 {
    assert!(input.len() == 4, "input length must be less than or equal to 4");

    let l0: u256 = BitShift::shl((*input.at(0)).into(), 192_u256);
    let l1 = BitShift::shl((*input.at(1)).into(), 128);
    let l2 = BitShift::shl((*input.at(2)).into(), 64);
    let l3 = (*input.at(3)).into();

    return (BitOr::bitor(BitOr::bitor(BitOr::bitor(l0, l1), l2), l3)).into();
}

pub fn split_u256_to_u64_array(value: u256) -> Span<u64> {
    let l0: u64 = (BitShift::shr(value, 192) & U64_MASK).try_into().unwrap();
    let l1: u64 = (BitShift::shr(value, 128) & U64_MASK).try_into().unwrap();
    let l2: u64 = (BitShift::shr(value, 64) & U64_MASK).try_into().unwrap();
    let l3: u64 = (value & U64_MASK).try_into().unwrap();
    return array![l0, l1, l2, l3].span();
}

pub fn words64_to_nibbles(input: Words64Sequence, skip_nibbles: usize) -> Array<u64> {
    let (_, remainder) = u32_safe_divmod(input.len_bytes * 2, 16);
    let mut acc = array![];
    let input_values_len = input.values.len();
    let mut i = 0;
    while i < input_values_len {
        let mut word = *input.values.at(i);
        let mut nibbles_len = 16;
        if i == input_values_len - 1 {
            if remainder == 0 {
                nibbles_len = 16;
            } else {
                nibbles_len = remainder;
            }
        }

        if i == 0 && skip_nibbles > 0 {
            let new_nibbles = words64_to_nibbles_rec(word, nibbles_len - skip_nibbles, array![]);
            acc.concat_span(new_nibbles.span());
        } else {
            let new_nibbles = words64_to_nibbles_rec(word, nibbles_len, array![]);
            acc.concat_span(new_nibbles.span());
        }
        i += 1;
    };
    acc
}

fn words64_to_nibbles_rec(mut word: u64, mut nibbles_len: usize, acc: Array<u64>) -> Array<u64> {
    let mut acc_cp = acc.clone();
    assert!(nibbles_len > 0, "nibbles_len must be greater than 0");
    let word = word & 0xF;
    acc_cp.append(word);
    if nibbles_len == 1 {
        return acc_cp.reverse();
    }
    words64_to_nibbles_rec(BitShift::shr(word, 4), nibbles_len - 1, acc_cp)
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_words64_to_u256() {
        let input = array![
            0xFFFFFFFFFFFFFFFF, 0xAAAAAAAAAAAAAAAA, 0xBBBBBBBBBBBBBBBB, 0xCCCCCCCCCCCCCCCC
        ];

        let result = super::words64_to_u256(input.span());

        assert_eq!(result, 0xffffffffffffffffaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbcccccccccccccccc);
    }

    #[test]
    fn test_words64_to_nibbles_rec() {
        let word = 3;
        let result = super::words64_to_nibbles_rec(word, 15, array![]);
        assert_eq!(result, array![0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3]);
    }

    #[test]
    fn test_words64_to_nibbles() {
        let input = super::Words64Sequence { values: array![3, 2, 3, 4].span(), len_bytes: 1 };
        let result = super::words64_to_nibbles(input, 0);
        assert_eq!(
            result,
            array![
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                3,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                2,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                3,
                0,
                4
            ]
        );
    }
}
