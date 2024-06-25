use core::array::SpanTrait;
use fossil::library::bitshift::{BitShift};
use fossil::library::keccak256;
use fossil::types::MMRProof;

pub fn verify_proof(element_value: u256, proof: MMRProof) -> Result<bool, felt252> {
    let leaf_count = mmr_size_to_leaf_count(proof.elements_count);
    let peaks_count = leaf_count_to_peaks_count(leaf_count);

    if peaks_count != proof.peaks.len() {
        return Result::Err('Invalid peaks count');
    }

    let element_index = proof.element_index;

    if element_index == 0 {
        return Result::Err('Invalid element index');
    }

    if element_index >= proof.elements_count {
        return Result::Err('Invalid element index');
    }

    let (peak_index, peak_height) = get_peak_info(proof.elements_count, element_index);

    if proof.siblings.len() != peak_height {
        return Result::Ok(false);
    }

    let mut hash = element_value;
    let mut leaf_index = element_index_to_leaf_index(element_index).unwrap();

    let sibling_len = proof.siblings.len();
    let mut i = 0;

    while i < sibling_len {
        let is_right_child = leaf_index % 2 == 1;
        leaf_index /= 2;

        if is_right_child {
            hash = keccak256::hash_2(*proof.siblings.at(i), hash);
        } else {
            hash = keccak256::hash_2(hash, *proof.siblings.at(i));
        }
        i += 1;
    };

    Result::Ok(hash == *proof.peaks.at(peak_index))
}

fn mmr_size_to_leaf_count(size: usize) -> usize {
    let mut remaining_size = size;
    let bits = bit_length(remaining_size + 1);
    let mut mountain_tips = BitShift::shl(1, bits - 1);
    let mut leaf_count = 0;

    while mountain_tips > 0 {
        let mountain_size = 2 * mountain_tips - 1;
        if mountain_size <= remaining_size {
            remaining_size -= mountain_size;
            leaf_count += mountain_tips;
        }
        mountain_tips = BitShift::shr(mountain_tips, 1);
    };
    leaf_count
}

fn leaf_count_to_peaks_count(leaf_count: usize) -> usize {
    count_ones(leaf_count)
}

fn count_ones(mut value: usize) -> usize {
    let mut ones_count = 0;
    while value > 0 {
        value = value & (value - 1);
        ones_count += 1;
    };
    ones_count
}

fn get_peak_info(mut elements_count: usize, mut element_index: usize) -> (usize, usize) {
    let mut mountain_height = bit_length(elements_count);
    let mut mountain_elements_count = BitShift::shl(1, mountain_height) - 1;
    let mut mountain_index = 0;
    let mut result = (0, 0);

    loop {
        if mountain_elements_count <= elements_count {
            if element_index <= mountain_elements_count {
                result = (mountain_index, mountain_height - 1);
                break;
            }
            elements_count -= mountain_elements_count;
            element_index -= mountain_elements_count;
            mountain_index += 1;
        }
        mountain_elements_count = BitShift::shr(mountain_elements_count, 1);
        mountain_height -= 1;
    };
    result
}

fn element_index_to_leaf_index(element_index: usize) -> Result<usize, felt252> {
    if element_index == 0 {
        panic!("Invalid element index");
    }
    elements_count_to_leaf_count(element_index - 1)
}

fn elements_count_to_leaf_count(elements_count: usize) -> Result<usize, felt252> {
    let mut leaf_count = 0;
    let mut mountain_leaf_count = BitShift::shl(1, bit_length(elements_count));
    let mut current_elements_count = elements_count;

    while mountain_leaf_count > 0 {
        let mountain_elements_count = 2 * mountain_leaf_count - 1;
        if mountain_elements_count <= current_elements_count {
            leaf_count += mountain_leaf_count;
            current_elements_count -= mountain_elements_count;
        }
        mountain_leaf_count = BitShift::shr(mountain_leaf_count, 1);
    };

    if current_elements_count > 0 {
        return Result::Err('Invalid elements count');
    } else {
        return Result::Ok(leaf_count);
    }
}

fn retrieve_peaks_hashes(peak_idxs: Span<u256>) -> Result<Array<u256>, felt252> {
    Result::Ok(array![])
}

fn find_peaks(mut elements_count: usize) -> Array<usize> {
    let mut mountain_elements_count = (BitShift::shl(1, bit_length(elements_count))) - 1;
    let mut mountain_index_shift = 0;
    let mut peaks: Array<usize> = array![];

    while mountain_elements_count > 0 {
        if mountain_elements_count <= elements_count {
            mountain_index_shift += mountain_elements_count;
            peaks.append(mountain_index_shift);
            elements_count -= mountain_elements_count;
        }
        mountain_elements_count = BitShift::shr(mountain_elements_count, 1);
    };

    if elements_count > 0 {
        return array![];
    }

    peaks
}


fn bit_length(num: usize) -> usize {
    if num == 0 {
        return 0;
    }

    let mut bit_position = 0;
    let mut curr_n = 1;
    while num >= curr_n {
        bit_position += 1;
        curr_n = BitShift::shl(curr_n, 1);
    };
    bit_position
}

pub fn extract_state_root(rlp_encoded: Span<u8>) -> u256 {
    let start_index = 90;
    let length = 32;
    let mut state_root_bytes = array![];

    let mut i = start_index;
    while i <= start_index + length {
        state_root_bytes.append(*rlp_encoded.at(i));
        i += 1;
    };

    let len = state_root_bytes.len();
    let mut j = 0;
    let mut state_root: u256 = 0;

    while j < len {
        state_root = (BitShift::shl(state_root, 8)) + (*state_root_bytes.at(j)).into();
        j += 1;
    };

    state_root
}

pub fn extract_block_number(rlp_encoded: Span<u8>) -> u64 {
    let start_index = 90;
    let length = 8;
    let mut block_number_bytes = array![];

    let mut i = start_index;
    while i <= start_index + length {
        block_number_bytes.append(*rlp_encoded.at(i));
        i += 1;
    };

    let len = state_root_bytes.len();
    let mut j = 0;
    let mut block_number: u64 = 0;

    while j < len {
        block_number = (BitShift::shl(state_root, 8)) + (*block_number_bytes.at(j)).into();
        j += 1;
    };

    block_number
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_verify_proof() {
        let proof = super::proof_1();
        let res = super::verify_proof(proof.element_hash, proof,);
        assert_eq!(res, Result::Ok(true));

        let proof = super::proof_2();
        let res = super::verify_proof(proof.element_hash, proof,);
        assert_eq!(res, Result::Ok(true));
    }

    #[test]
    fn test_extract_state_root() {
        let rlp = super::block_rlp();
        let state_root = super::extract_state_root(rlp);
        assert_eq!(state_root, 0x40c07091e16263270f3579385090fea02dd5f061ba6750228fcc082ff762fda7);
    }

    fn proof_1() -> MMRProof {
        MMRProof {
            element_index: 191,
            element_hash: 0x799c04bffdee59cbe1f71aabb5dd6b50f2330c2343812dd30cf21bd5f96be982,
            siblings: array![
                0x648d7eea42b054baf0d9b1083bb1680013d18435de35e528989a629d14716234,
                0x7039ad4f2e886e64bd9ab58af5e9645bf4dce4f19d08bb9c7037433e61686a19,
            ]
                .span(),
            peaks: array![
                0xe9bc1501c1b36bdef0f6738950e0e626b2ffc096bea3ef9d7ccaf713cafce8ae,
                0x44f82d2fe372488a2c728d5dbc7af6edc75707ba7073d48576ac2fb5a62f7c32,
                0x0a03d84e34145339edb94dc9abd591c3d504746b69d3d3237cdaf776c89316e2,
            ]
                .span(),
            elements_count: 197,
        }
    }

    fn proof_2() -> MMRProof {
        MMRProof {
            element_index: 16,
            element_hash: 0x7701fb3ede3096fad1b6546eb3ee18a395263631f21990289807b0364a50d3f4,
            siblings: array![
                0xcbc699c48bfd4df668eb7358b610fbec7b55c265ecb7c1c7d9fffdd0796fc2bd,
                0x9378e053e0debece3135c9630b8a6ffee46cb8c8484bf88849e21e6b7e7a9dce,
                0xcd0fe8e79cbff6574bb498ddb4f57437d506e262c435b03b55f13009c9a59232,
                0x57003624be61b0b94251ee30b2ac99335378f8e18abb8ccb4a5acb3510d33df4,
                0x92f102ed54dbaa2f90feb80c59bcebe03a5d04c66c93e109b2817d3455ef26c5,
                0xe907f19ebdd15613a45343e55c55dbdece057caeee84971f9ef99178086819a8
            ]
                .span(),
            peaks: array![
                0xe9bc1501c1b36bdef0f6738950e0e626b2ffc096bea3ef9d7ccaf713cafce8ae,
                0x44f82d2fe372488a2c728d5dbc7af6edc75707ba7073d48576ac2fb5a62f7c32,
                0x0a03d84e34145339edb94dc9abd591c3d504746b69d3d3237cdaf776c89316e2,
            ]
                .span(),
            elements_count: 197,
        }
    }

    fn block_rlp() -> Span<u8> {
        array![
            249,
            2,
            2,
            160,
            85,
            177,
            27,
            145,
            131,
            85,
            177,
            239,
            156,
            93,
            184,
            16,
            48,
            46,
            186,
            208,
            191,
            37,
            68,
            37,
            91,
            83,
            12,
            220,
            233,
            6,
            116,
            213,
            136,
            123,
            178,
            134,
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
            238,
            226,
            118,
            98,
            194,
            184,
            235,
            163,
            205,
            147,
            106,
            35,
            240,
            57,
            243,
            24,
            150,
            51,
            228,
            200,
            160,
            64,
            192,
            112,
            145,
            225,
            98,
            99,
            39,
            15,
            53,
            121,
            56,
            80,
            144,
            254,
            160,
            45,
            213,
            240,
            97,
            186,
            103,
            80,
            34,
            143,
            204,
            8,
            47,
            247,
            98,
            253,
            167,
            160,
            30,
            161,
            116,
            100,
            104,
            104,
            97,
            89,
            206,
            115,
            12,
            28,
            196,
            154,
            136,
            103,
            33,
            36,
            78,
            93,
            31,
            169,
            160,
            109,
            109,
            65,
            150,
            182,
            240,
            19,
            200,
            44,
            160,
            146,
            128,
            115,
            251,
            152,
            206,
            49,
            98,
            101,
            234,
            53,
            217,
            90,
            183,
            226,
            225,
            32,
            108,
            236,
            216,
            82,
            66,
            235,
            132,
            29,
            187,
            204,
            79,
            86,
            143,
            202,
            75,
            185,
            1,
            0,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            255,
            128,
            131,
            237,
            20,
            242,
            132,
            1,
            201,
            195,
            128,
            132,
            1,
            201,
            129,
            30,
            132,
            99,
            34,
            201,
            115,
            128,
            160,
            168,
            108,
            46,
            96,
            27,
            108,
            68,
            235,
            72,
            72,
            247,
            210,
            61,
            157,
            243,
            17,
            63,
            188,
            172,
            66,
            4,
            28,
            73,
            203,
            237,
            80,
            0,
            203,
            79,
            17,
            135,
            119,
            136,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            133,
            11,
            93,
            104,
            224,
            163
        ]
            .span()
    }
}
