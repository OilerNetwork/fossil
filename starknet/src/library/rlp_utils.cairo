use core::integer::u64_safe_divmod;
use fossil::library::{bitshift::BitShift, math_utils::pow};
use fossil::types::{Words64Sequence, RLPItem};
// use alexandria_math::{BitShift, fast_power::fast_power};
const TWO_POW_64_MIN_ONE: u128 = 18446744073709551615;

pub fn to_rlp_array(rlp: Words64Sequence) -> Array<RLPItem> {
    let mut rlp_array = array![];
    let element = get_element(rlp, 0);
    let payload_pos = element.position;
    let payload_len: u32 = element.length.try_into().unwrap();
    let payload_end: u32 = payload_pos + payload_len;
    let mut next_element_pos = payload_pos;

    while (next_element_pos < payload_end) {
        let new_element = get_element(rlp, next_element_pos);
        next_element_pos = new_element.position + new_element.length.try_into().unwrap();
        rlp_array.append(new_element);
    };
    rlp_array
}

pub fn extract_element(rlp: Words64Sequence, position: usize) -> Words64Sequence {
    let element = get_element(rlp, position);
    let position = element.position;
    let length = element.length;

    if length == 0 {
        return Words64Sequence { values: array![].span(), len_bytes: 0 };
    }

    extract_data(rlp, position, length)
}

fn get_element(rlp: Words64Sequence, position: usize) -> RLPItem {
    let first_byte = *extract_data(rlp, position, 1).values.at(0);

    if first_byte <= 127 {
        return RLPItem { first_byte, position, length: 1 };
    }

    if first_byte <= 183 {
        let length = first_byte - 128;
        return RLPItem { first_byte, position: position + 1, length };
    }

    if first_byte <= 191 {
        let length_of_len = first_byte - 183;
        let length = *extract_data(rlp, position + 1, length_of_len).values.at(0);
        return RLPItem {
            first_byte, position: position + 1 + length_of_len.try_into().unwrap(), length
        };
    }

    if first_byte <= 247 {
        let length = first_byte - 192;
        return RLPItem { first_byte, position: position + 1, length };
    }

    let length_of_len = first_byte - 247;
    assert!(length_of_len <= 8, "Length of length cannot exceed 8 bytes");
    let length = *extract_data(rlp, position + 1, length_of_len).values.at(0);
    return RLPItem {
        first_byte, position: position + 1 + length_of_len.try_into().unwrap(), length
    };
}

// TODO: recheck this function against cairo 0 implementation to make sure it's correct
pub fn extract_data(rlp: Words64Sequence, start: usize, size: u64) -> Words64Sequence {
    let (start_word, left_shift) = u64_safe_divmod(start.into(), 8);
    let (mut end_word, mut end_pos) = u64_safe_divmod(start.into() + size, 8);

    if end_pos == 0 {
        end_pos = 8;
        end_word -= 1;
    }

    let (full_words, remainder) = u64_safe_divmod(size, 8);

    let (_, last_rlp_word_len_tmp) = u64_safe_divmod(rlp.len_bytes.into(), 8);
    let last_rlp_word_len: u64 = if last_rlp_word_len_tmp == 0 {
        8
    } else {
        last_rlp_word_len_tmp
    };

    let right_shift = 8 - left_shift;
    let lastword_right_shift = if last_rlp_word_len >= left_shift {
        last_rlp_word_len - left_shift
    } else {
        8 - (left_shift - last_rlp_word_len)
    };
    let rlp_values = rlp.values;
    let rlp_values_len: u64 = rlp_values.len().into();

    let mut new_words = array![];
    let mut right_part: u128 = 0;
    let mut left_part: u128 = 0;

    let mut i: usize = start_word.try_into().unwrap();
    let loop_limit = (start_word + full_words).try_into().unwrap();

    while i < loop_limit {
        let value: u128 = (*rlp_values.at(i)).into();
        left_part = BitShift::shl(value, left_shift.into() * 8);

        if i == rlp_values_len.try_into().unwrap() - 2 {
            let value_i_add1: u128 = (*rlp_values.at(i + 1)).into();
            if lastword_right_shift < 0 {
                right_part =
                    BitShift::shl(
                        value_i_add1,
                        (8 - (left_shift - lastword_right_shift)).try_into().unwrap() * 8
                    );
            } else {
                right_part =
                    BitShift::shr(value_i_add1, lastword_right_shift.try_into().unwrap() * 8);
            }
        } else {
            if i == rlp_values_len.try_into().unwrap() - 1 {
                right_part = 0;
            } else {
                let value_i_add1: u128 = (*rlp_values.at(i + 1)).into();
                right_part = BitShift::shr(value_i_add1, right_shift.try_into().unwrap() * 8);
            }
        }
        let new_word: u64 = ((left_part + right_part) & TWO_POW_64_MIN_ONE).try_into().unwrap();
        new_words.append(new_word);
        i += 1;
    };

    let mut final_word_shifted = 0;
    if remainder != 0 {
        let value_at_end_word: u128 = (*rlp_values.at(end_word.try_into().unwrap())).into();
        if remainder + left_shift > 8 {
            let value_at_end_word_min_one = *rlp_values.at(end_word.try_into().unwrap() - 1);
            left_part =
                BitShift::shl(value_at_end_word_min_one.try_into().unwrap(), left_shift.into() * 8);

            if end_word == rlp_values_len - 1 {
                // right_part = BitShift::shr(value_at_end_word, ((8 - remainder) * 8).into());
                if lastword_right_shift < left_shift {
                    right_part =
                        BitShift::shl(
                            value_at_end_word, (left_shift - lastword_right_shift).into() * 8
                        );
                } else {
                    right_part =
                        BitShift::shr(
                            value_at_end_word, (lastword_right_shift - left_shift).into() * 8
                        );
                }
            } else {
                right_part = BitShift::shr(value_at_end_word, right_shift.into() * 8);
            }

            let final_word = left_part + right_part;

            final_word_shifted = BitShift::shr(final_word, ((8 - remainder) * 8).into());
            let final_word_mask: u128 = (pow(2, remainder * 8) - 1).into();
            new_words.append((final_word_shifted & final_word_mask).try_into().unwrap());
        } else {
            if end_word == rlp_values_len - 1 {
                final_word_shifted =
                    BitShift::shr(value_at_end_word, ((last_rlp_word_len - end_pos) * 8).into());
            } else {
                final_word_shifted = BitShift::shr(value_at_end_word, ((8 - end_pos) * 8).into());
            }
            let final_word_mask: u128 = (pow(2, (end_pos - left_shift) * 8) - 1).into();
            new_words.append((final_word_shifted & final_word_mask).try_into().unwrap());
        }
    }
    let res = Words64Sequence { values: new_words.span(), len_bytes: size.try_into().unwrap() };
    res
}

pub fn is_rlp_item(item: RLPItem) -> bool {
    let first_byte = item.first_byte;
    first_byte >= 192
}

#[cfg(test)]
mod tests {
    use super::Words64Sequence;

    #[test]
    fn test_to_rlp_array() {
        let rlp = Words64Sequence {
            values: array![
                17899166613764872570,
                9377938528222421349,
                9284578564931001247,
                895019019097261264,
                13278573522315157529,
                11254050738018229226,
                16872101704597074970,
                8839885802225769251,
                17633069546125622176,
                5635966238324062822,
                4466071473455465888,
                16386808635744847773,
                5287805632665950919
            ]
                .span(),
            len_bytes: 104
        };
        let result = super::to_rlp_array(rlp);

        let first_element = *result.at(0);
        assert_eq!(first_element.first_byte, 157);
        assert_eq!(first_element.position, 3);
        assert_eq!(first_element.length, 29);

        let second_element = *result.at(1);
        assert_eq!(second_element.first_byte, 184);
        assert_eq!(second_element.position, 34);
        assert_eq!(second_element.length, 70);
    }

    #[test]
    fn test_get_element() {
        let rlp = Words64Sequence { values: array![0].span(), len_bytes: 1 };
        let position = 0;
        let result = super::get_element(rlp, position);
        assert_eq!(result.first_byte, 0);
        assert_eq!(result.position, 0);
        assert_eq!(result.length, 1);

        let mut rlp = Words64Sequence { values: array![127].span(), len_bytes: 1 };
        let position = 0;
        let result = super::get_element(rlp, position);
        assert_eq!(result.first_byte, 127);
        assert_eq!(result.position, 0);
        assert_eq!(result.length, 1);

        let mut rlp = Words64Sequence { values: array![128].span(), len_bytes: 1 };
        let position = 0;
        let result = super::get_element(rlp, position);
        assert_eq!(result.first_byte, 128);
        assert_eq!(result.position, 1);
        assert_eq!(result.length, 0);

        let mut rlp = Words64Sequence { values: array![192].span(), len_bytes: 1 };
        let position = 0;
        let result = super::get_element(rlp, position);
        assert_eq!(result.first_byte, 192);
        assert_eq!(result.position, 1);
        assert_eq!(result.length, 0);

        let mut rlp = Words64Sequence { values: array![246].span(), len_bytes: 1 };
        let position = 0;
        let result = super::get_element(rlp, position);
        assert_eq!(result.first_byte, 246);
        assert_eq!(result.position, 1);
        assert_eq!(result.length, 54);
    }

    #[test]
    fn test_extract_data_specific() {
        let mut rlp = Words64Sequence {
            values: array![
                16978043373031179566,
                7407922919091180751,
                14853551893213251245,
                4906994927831835881,
                10054857540239986558,
                2856817665
            ]
                .span(),
            len_bytes: 44
        };
        let start_pos = 33;
        let size = 11;
        let result = super::extract_data(rlp, start_pos, size);
        assert_eq!(result.values, array![9946104055808884394, 4690945].span());
        assert_eq!(result.len_bytes, 11);
    }

    #[test]
    fn test_extract_data() {
        let mut rlp = Words64Sequence {
            values: array![
                17899166613764872570,
                9377938528222421349,
                9284578564931001247,
                895019019097261264,
                13278573522315157529,
                11254050738018229226,
                16872101704597074970,
                8839885802225769251,
                17633069546125622176,
                5635966238324062822,
                4466071473455465888,
                16386808635744847773,
                5287805632665950919
            ]
                .span(),
            len_bytes: 104
        };
        let start_pos = 34;
        let size = 70;
        let result = super::extract_data(rlp, start_pos, size);
        assert_eq!(result.len_bytes, 70);
        assert_eq!(
            result.values,
            array![
                17889425271775927342,
                7747611707377904165,
                13770790249671850669,
                10758299819545195701,
                4563277353913962038,
                17973550993138662906,
                12418610901666554729,
                11791013025377241442,
                16720179567303
            ]
                .span()
        );
        let mut rlp = Words64Sequence {
            values: array![1234567890, 9876543210].span(), len_bytes: 16
        };
        let start_pos = 8;
        let size = 8;
        let result = super::extract_data(rlp, start_pos, size);
        assert_eq!(result.values, array![9876543210].span());

        let mut rlp = Words64Sequence {
            values: array![1234567890, 9876543210, 1111111111].span(), len_bytes: 24
        };
        let start_pos = 4;
        let size = 12;
        let result = super::extract_data(rlp, start_pos, size);
        assert_eq!(result.values, array![5302428712241725442, 1286608618].span());

        let mut rlp = Words64Sequence {
            values: array![1234567890, 9876543210].span(), len_bytes: 24
        };
        let start_pos = 2;
        let size = 6;
        let result = super::extract_data(rlp, start_pos, size);
        assert_eq!(result.values, array![1234567890].span());

        let mut rlp = Words64Sequence {
            values: array![1234567890, 9876543210].span(), len_bytes: 24
        };
        let start_pos = 12;
        let size = 8;
        let result = super::extract_data(rlp, start_pos, size);
        assert_eq!(result.values, array![5525941937061756928].span());
    }
}
