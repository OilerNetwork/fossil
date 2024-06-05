//! Library for helper functions for Words64 Type

// *************************************************************************
//                                  IMPORTS
// *************************************************************************
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
/// Implementation of `U256Words64` for `Words64Trait`.
/// `U256Words64` trait provides conversion functions between `u256` and `Words64Sequence`.
impl U256Words64 of Words64Trait<u256> {
    /// `to_words64` converts an `u256` into a `Words64Sequence` .
    fn to_words64(self: u256) -> Words64Sequence {
        let values = split_u256_to_u64_array(self);
        Words64Sequence { values: values, len_bytes: 32, }
    }

    /// `from_words64` converts a `Words64Sequence` back into an `u256`.
    fn from_words64(self: Words64Sequence) -> u256 {
        words64_to_u256(self.values)
    }
}

/// Implementation of `EthAddressWords64` for `Words64Trait`.
/// `EthAddressWords64` trait provides conversion functions between `EthAddress` and `Words64Sequence`.
impl EthAddressWords64 of Words64Trait<EthAddress> {
    /// `to_words64` converts an `EthAddress` into a `Words64Sequence` .
    fn to_words64(self: EthAddress) -> Words64Sequence {
        let address_felt: felt252 = self.into();
        let l0: u64 = (BitShift::shr(address_felt.into(), 96) & U64_MASK).try_into().unwrap();
        let l1: u64 = (BitShift::shr(address_felt.into(), 32) & U64_MASK).try_into().unwrap();
        let l2: u64 = (address_felt.into() & U64_MASK).try_into().unwrap();

        keccak_words64(Words64Sequence { values: array![l0, l1, l2].span(), len_bytes: 20, })
    }

    /// `from_words64` converts a `Words64Sequence` back into an `EthAddress`.
    /// Note: The `Words64Sequence` input to `from_words64` must have a length of 3 or less.
    fn from_words64(self: Words64Sequence) -> EthAddress {
        assert!(self.values.len() <= 3, "input length must be less than or equal to 3");
        if self.values.len() == 0 {
            return 0_u256.into();
        }

        let l0: u256 = BitShift::shl((*self.values.at(0)).into(), 96_u256);
        let l1 = BitShift::shl((*self.values.at(1)).into(), 32);
        let l2 = (*self.values.at(2)).into();

        return (BitOr::bitor(BitOr::bitor(l0, l1), l2)).into();
    }
}

/// Concatenates a `Span<u64>` into a `u256` value.
///
/// # Arguments
/// * `input` - A `Span<u64>` containing up to four 64-bit words to be converted into a `u256`.
///
/// # Returns
/// * `u256` - A value representing the combination of the input words.
///
/// # Panics
/// If the input `Span<u64>` has a length greater than 4.
/// 
/// This function takes a `Span<u64>` representing a `Words64Sequence` i.e sequence of up to four 64-bit words,
/// and combines them into a single `u256` value by using the shift and bitwise operator.
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

/// Converts a `Words64Sequence` into a `u256` value.
///
/// # Arguments
/// * `input` - A `Words64Sequence` containing the 64-bit words and the length in bytes to be converted.
///
/// # Returns
/// A `u256` value representing the combination of the input bytes.
/// 
/// This function takes a `Words64Sequence` as input, which represents a sequence of 64-bit words
/// and a length in bytes. It converts the sequence of words into an array of bytes, and then
/// combines these bytes into a single `u256` value.
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

/// Splits a `u256` value into an array of four `u64` values.
///
/// # Arguments
/// * `value` - The `u256` value to be split into four `u64` words.
///
/// # Returns
/// * `Span<u64>` - Four `u64` elements, representing the input `u256` value split into
/// four 64-bit words.
/// 
/// This function takes a `u256` value as input and splits it into four 64-bit words (elements).
/// The splitting is done by shifting the input value right by 192, 128, 64, and 0 bits, and then
/// masking the result with `U64_MASK` to extract the corresponding 64-bit word.
pub fn split_u256_to_u64_array(value: u256) -> Span<u64> {
    let l0: u64 = (BitShift::shr(value, 192) & U64_MASK).try_into().unwrap();
    let l1: u64 = (BitShift::shr(value, 128) & U64_MASK).try_into().unwrap();
    let l2: u64 = (BitShift::shr(value, 64) & U64_MASK).try_into().unwrap();
    let l3: u64 = (value & U64_MASK).try_into().unwrap();
    return array![l0, l1, l2, l3].span();
}

/// Splits a `u256` value into a span of four `u64` values.
/// This function is similar to `split_u256_to_u64_array`, but instead of returning a `Span<u64>`,
/// it returns an `Array<u64>` containing the four `u64` elements.
///
/// # Arguments
/// * `value` - The `u256` value to be split into four `u64` words.
///
/// # Returns
/// * `Array<u64>` - Four `u64` elements, representing the input `u256` value split into
/// four 64-bit words.
pub fn split_u256_to_u64_array_no_span(value: u256) -> Array<u64> {
    let l0: u64 = (BitShift::shr(value, 192) & U64_MASK).try_into().unwrap();
    let l1: u64 = (BitShift::shr(value, 128) & U64_MASK).try_into().unwrap();
    let l2: u64 = (BitShift::shr(value, 64) & U64_MASK).try_into().unwrap();
    let l3: u64 = (value & U64_MASK).try_into().unwrap();
    return array![l0, l1, l2, l3];
}

/// Converts a `Words64Sequence` into an array of nibbles (4-bit values).
///
/// # Arguments
/// * `input` - The `Words64Sequence` to be converted into an array of nibbles.
/// * `skip_nibbles` - The number of nibbles to skip from the beginning of the input sequence.
///
/// # Returns
/// * `Array<u64>` - The nibbles representing the input `Words64Sequence`.
/// 
/// The resulting nibble arrays are then concatenated into a single `Array<u64>`, representing the entire
/// `Words64Sequence` in nibble form.
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

/// Converts a 64-bit word into an array of nibbles (4-bit values) in little-endian order.
///
/// # Arguments
/// * `word` - The 64-bit word to be converted into an array of nibbles.
/// * `nibbles_len` - The number of nibbles to be extracted from the word. This value must be greater than 0.
/// * `acc` - An `Array<u64>` to accumulate the extracted nibbles. This is used for the recursive calls.
///
/// # Returns
/// * `Array<u64>` - The extracted nibbles in little-endian order.
///
/// # Panics
/// Panics ff `nibbles_len` is 0.
/// 
/// This function takes a 64-bit word (`u64`) and recursively converts it into an array of nibbles.
/// The conversion is done by repeatedly shifting the input word right by 4 bits and extracting the
/// least significant nibble (4 bits) until all nibbles have been extracted.
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
