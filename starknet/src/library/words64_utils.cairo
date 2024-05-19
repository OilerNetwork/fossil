use core::integer::u32_safe_divmod;
use core::option::OptionTrait;
use core::traits::Into;
use fossil::library::{
    array_utils::ArrayTraitExt, bitshift::BitShift, keccak_utils::{keccak_words64, u64_to_u8_array}
};
use fossil::types::Words64Sequence;
use starknet::EthAddress;

const U64_MASK: u256 = 0xFFFFFFFFFFFFFFFF;
const U64_MASK_FELT: felt252 = 0xFFFFFFFFFFFFFFFF;

pub trait Words64Trait<T> {
    fn to_words64(self: T) -> Words64Sequence;
    fn from_words64(self: Words64Sequence) -> T;
}

impl U256Words64 of Words64Trait<u256> {
    fn to_words64(self: u256) -> Words64Sequence {
        let values = split_u256_to_u64_array(self);
        Words64Sequence { values: values, len_bytes: 32, }
    }

    fn from_words64(self: Words64Sequence) -> u256 {
        words64_to_u256(self.values)
    }
}

impl EthAddressWords64 of Words64Trait<EthAddress> {
    fn to_words64(self: EthAddress) -> Words64Sequence {
        let address_felt: felt252 = self.into();
        let l0: u64 = (BitShift::shr(address_felt.into(), 96) & U64_MASK).try_into().unwrap();
        let l1: u64 = (BitShift::shr(address_felt.into(), 32) & U64_MASK).try_into().unwrap();
        let l2: u64 = (address_felt.into() & U64_MASK).try_into().unwrap();

        keccak_words64(Words64Sequence { values: array![l0, l1, l2].span(), len_bytes: 20, })
    }

    fn from_words64(self: Words64Sequence) -> EthAddress {
        let address = words64_to_u256(self.values);
        address.into()
    }
}

pub fn words64_to_u256(input: Span<u64>) -> u256 {
    assert!(input.len() <= 4, "input length must be less than or equal to 4");
    if input.len() == 0 {
        return 0;
    }

    let l0: u256 = BitShift::shl((*input.at(0)).into(), 192_u256);
    let l1 = BitShift::shl((*input.at(1)).into(), 128);
    let l2 = BitShift::shl((*input.at(2)).into(), 64);
    let l3 = (*input.at(3)).into();

    return (BitOr::bitor(BitOr::bitor(BitOr::bitor(l0, l1), l2), l3)).into();
}


pub fn words64_to_int(input: Words64Sequence) -> u256 {
    let mut result = 0_u256;
    let bytes = u64_to_u8_array(input.values, input.len_bytes);

    let len = bytes.len();
    let mut i = 0;
    while i < len {
        let byte = *bytes.at(i);
        result = BitShift::shl(result, 8);
        result = BitOr::bitor(result, byte.into());
        i += 1;
    };

    result
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
        let word = *input.values.at(i);
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

fn words64_to_nibbles_rec(word: u64, nibbles_len: usize, mut acc: Array<u64>) -> Array<u64> {
    assert!(nibbles_len > 0, "nibbles_len must be greater than 0");
    if nibbles_len == 1 {
        acc.append(word & 0xF);
        return acc;
    }
    acc = words64_to_nibbles_rec(BitShift::shr(word, 4), nibbles_len - 1, acc);
    acc.append(word & 0xF);
    acc
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
        let input = super::Words64Sequence {
            values: array![
                16242634080300865914, 9377938528222421349, 9284578564931001247, 895019019097261264
            ]
                .span(),
            len_bytes: 32
        };
        let result = super::words64_to_nibbles(input, 0);
        assert_eq!(
            result,
            array![
                14,
                1,
                6,
                9,
                6,
                13,
                10,
                3,
                8,
                12,
                15,
                12,
                9,
                9,
                7,
                10,
                8,
                2,
                2,
                5,
                2,
                1,
                6,
                7,
                10,
                12,
                2,
                5,
                10,
                1,
                6,
                5,
                8,
                0,
                13,
                9,
                7,
                3,
                0,
                3,
                5,
                3,
                14,
                11,
                1,
                11,
                9,
                15,
                0,
                12,
                6,
                11,
                11,
                15,
                0,
                14,
                4,
                12,
                8,
                2,
                12,
                4,
                13,
                0
            ]
        );
    }
}
