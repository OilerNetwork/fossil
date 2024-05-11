use fossil::library::{
    words64_utils::split_u256_to_u64_array, keccak256::keccak256, bitshift::BitShift
};
use fossil::types::Words64Sequence;

fn keccak_words64(input: Words64Sequence) -> Words64Sequence {
    let mut bytes = u64_to_u8_array(input.values);
    let hash = keccak256(bytes.span());
    let values_u64 = split_u256_to_u64_array(hash);
    Words64Sequence { values: values_u64, len_bytes: 32 }
}

fn u64_to_u8_array(input: Span<u64>) -> Array<u8> {
    let mut bytes: Array<u8> = array![];
    let input_len = input.len();
    let mut i = 0;
    while i < input_len {
        let mut value = *input.at(i);
        let mut byte_array = array![];
        let mut j = 0_u32;
        while j < 8 {
            let byte = value & 0xFF;
            byte_array.append(byte.try_into().unwrap());
            value = BitShift::shr(value, 8);
            j += 1;
        };
        let mut k = 7_usize;
        while k >= 0 {
            bytes.append(*byte_array.at(k));
            if k == 0 {
                break;
            }
            k -= 1;
        };
        i += 1;
    };
    bytes
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_keccak_words64() {
        let mut input = super::Words64Sequence {
            values: array![87348, 73246, 90859, 343].span(), len_bytes: 32
        };
        let result = super::keccak_words64(input);
        assert_eq!(result.len_bytes, 32);
        assert_eq!(
            result.values,
            array![
                10883424205219630136, 789071849695081989, 7104751752738504398, 7320994210008971697
            ]
                .span()
        );
    }
}
