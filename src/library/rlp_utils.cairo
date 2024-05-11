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
        next_element_pos = element.position + element.length.try_into().unwrap();
        rlp_array.append(new_element);
    };
    rlp_array
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
        return RLPItem { first_byte, position, length };
    }

    if first_byte <= 247 {
        let length = first_byte - 192;
        return RLPItem { first_byte, position: position + 1, length };
    }

    let length_of_len = first_byte - 247;
    let length = *extract_data(rlp, position + 1, length_of_len).values.at(0);
    return RLPItem {
        first_byte, position: position + 1 + length_of_len.try_into().unwrap(), length
    };
}

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
    let lastword_right_shift = last_rlp_word_len - left_shift;
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

        if i.into() == rlp_values_len - 2 {
            let value_i_add1: u128 = (*rlp_values.at(i + 1)).into();
            if lastword_right_shift < 0 {
                right_part = BitShift::shl(value_i_add1, lastword_right_shift.into() * 8);
            } else {
                right_part = BitShift::shr(value_i_add1, right_shift.into() * 8);
            }
        } else {
            if i.into() == rlp_values_len - 1 {
                right_part = 0;
            } else {
                let value_i_add1: u128 = (*rlp_values.at(i + 1)).into();
                right_part = BitShift::shr(value_i_add1, right_shift.into() * 8);
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
            left_part = BitShift::shl(value_at_end_word - 1, left_shift.into() * 8);

            if end_word == rlp_values_len - 1 {
                right_part = BitShift::shr(value_at_end_word, ((8 - remainder) * 8).into());
            } else {
                right_part = value_at_end_word;
            }

            let final_word = left_part + right_part;

            final_word_shifted =
                BitShift::shr(final_word, ((16 - remainder - left_shift) * 8).into());
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
    Words64Sequence { values: new_words.span(), len_bytes: size.try_into().unwrap() }
}

#[cfg(test)]
mod tests {
    use super::Words64Sequence;

    #[test]
    fn test_to_rlp_array() {
        let rlp = Words64Sequence { values: array![192].span(), len_bytes: 1 };
        let result = super::to_rlp_array(rlp);

        assert_eq!(result.len(), 0);
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
    fn test_extract_data() {
        let mut rlp = Words64Sequence {
            values: array![1234567890, 9876543210].span(), len_bytes: 16
        };
        let start_pos = 0;
        let size = 8;
        let result = super::extract_data(rlp, start_pos, size);
        assert_eq!(result.values, array![1234567890].span());

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
