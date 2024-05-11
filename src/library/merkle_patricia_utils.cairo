use fossil::library::words64_utils::words64_to_nibbles;
use fossil::types::Words64Sequence;

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

#[cfg(test)]
mod tests {
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
