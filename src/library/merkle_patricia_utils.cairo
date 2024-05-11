use core::integer::{u32_safe_divmod, u64_safe_divmod};
use fossil::library::{
    words64_utils::words64_to_nibbles, rlp_utils::extract_data, bitshift::BitShift
};
use fossil::types::{Words64Sequence, Words64, RLPItem};

pub fn merkle_patricia_input_decode(input: Words64Sequence) -> Array<u64> {
    let first_nibble = *words64_to_nibbles(input, 0).at(0);
    let mut skip_nibbles = 0;

    if first_nibble == 0 {
        skip_nibbles = 2;
    } else if first_nibble == 1 {
        skip_nibbles = 1;
    } else if first_nibble == 2 {
        skip_nibbles = 2;
    } else if first_nibble == 3 {
        skip_nibbles = 1;
    } else {
        panic!("Invalid first nibble");
    }

    if skip_nibbles >= input.len_bytes {
        return array![];
    }
    words64_to_nibbles(input, skip_nibbles)
}

pub fn count_shared_prefix_len(
    current_path_offset: usize, path: Words64, node_path: Words64, current_index: usize
) -> usize {
    if current_index + current_path_offset >= path.len() && current_index >= node_path.len() {
        return current_index;
    } else {
        let path_nibble = *path.at(current_index + current_path_offset);
        let node_path_nibble = *node_path.at(current_index);

        if path_nibble == node_path_nibble {
            return count_shared_prefix_len(current_path_offset, path, node_path, current_index + 1);
        } else {
            return current_index;
        }
    }
}

pub fn get_next_hash(rlp: Words64Sequence, node: RLPItem) -> Words64Sequence {
    assert!(node.length == 32, "Invalid node length");
    let res = extract_data(rlp, node.position, 32);
    assert!(res.values.len() == 4, "Invalid hash length");
    res
}

pub fn extract_nibble(input: Words64Sequence, position: usize) -> u32 {
    assert!(position < input.len_bytes * 2, "Invalid position");
    let (target_word, index) = u32_safe_divmod(position, 16);
    let mut word_size_bytes = if target_word < input.values.len() - 1 {
        8
    } else {
        8 - (input.len_bytes % 8)
    };
    word_size_bytes = if word_size_bytes == 0 {
        8
    } else {
        word_size_bytes
    };
    let res = BitShift::shr(
        *input.values.at(target_word), (4 * (word_size_bytes * 2 - 1 - index)).into()
    )
        & 0xf;
    res.try_into().unwrap()
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_get_next_hash() {
        let input = super::Words64Sequence { values: array![1, 2, 3, 4].span(), len_bytes: 4 };
        let node = super::RLPItem { first_byte: 1, position: 2, length: 32 };
        let result = super::get_next_hash(input, node);
        assert_eq!(result.values, array![65536, 131072, 196608, 262144].span());
        assert_eq!(result.len_bytes, 32);
    }

    #[test]
    fn test_extract_nibble() {
        let input = super::Words64Sequence { values: array![1, 2, 3, 4].span(), len_bytes: 4 };
        let result = super::extract_nibble(input, 0);
        assert_eq!(result, 0);
    }


    #[test]
    fn test_merkle_patricia_input_decode() {
        let input = super::Words64Sequence { values: array![1, 2, 3, 4].span(), len_bytes: 3 };
        let result = super::merkle_patricia_input_decode(input);

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
                0,
                0,
                0,
                0,
                4
            ]
        );
    }
}
