use fossil::library::{
    words64_utils::split_u256_to_u64_array, merkle_patricia_utils::merkle_patricia_input_decode,
    rlp_utils::{extract_data, to_rlp_array}
};
use fossil::types::Words64Sequence;

const EMPTY_TRIE_ROOT_HASH: u256 =
    0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421;

pub fn verify_proof(
    path: Words64Sequence, root_hash: Words64Sequence, proof: Array<Words64Sequence>,
) -> Words64Sequence {
    // let proof_len = proof.len();
    // if proof_len == 0 {
    //     assert!(
    //         root_hash.values == split_u256_to_u64_array(EMPTY_TRIE_ROOT_HASH),
    //         "Empty proof must have empty trie root hash"
    //     );
    //     return Words64Sequence { values: array![].span(), length: 0 };
    // }

    // let mut next_hash = Words64Sequence { values: array![].span(), length: 0 };
    // let mut path_offset = 0;
    // let mut i = 0_u32;
    // while (i < proof_len) {
    //     let element_rlp = *(proof.at(i));

    //     if i == 0 {
    //         assert!(root_hash.values == element_rlp.values, "Root hash mismatch");
    //     } else {
    //         assert!(next_hash.values == element_rlp.values, "Hash mismatch")
    //     }

    //     let node = to_rlp_array(element_rlp);
    //     let node_len = node.len();
    //     if node_len == 2 {
    //         let node_element = *node.at(0);
    //         let node_path = merkle_patricia_input_decode(
    //             extract_data(element_rlp, node_element.position, node_element.length)
    //         );
    //         let path_offset
    //     }

    //     i += 1;
    // };

    Words64Sequence { values: array![].span(), len_bytes: 0 }
}

// fn extract_storage_key_value(
//     proof: Span<u64>, proof_sizes_words: Span<usize>
// ) -> (Array<u64>, Array<u64>) {
//     let len = proof.len();
//     let mut storage_keys = array![];
//     let mut storage_values = array![];

//     let offset_first = *proof_sizes_words.at(0);
//     let mut i = 0;
//     while i < offset_first {
//         storage_keys.append(*proof.at(i));
//         i += 1;
//     };

//     let offset_last = get_value_offset(proof_sizes_words, proof_sizes_words.len() - 1);
//     let mut j = offset_last;
//     while j < len {
//         storage_values.append(*proof.at(j));
//         j += 1;
//     };

//     (storage_keys, storage_values)
// }

// fn get_value_offset(proof_sizes_words: Span<usize>, element: usize) -> usize {
//     let len = proof_sizes_words.len();
//     assert!(element < len, "Element out of bounds");

//     let mut offset = 0;
//     let mut i = 0;
//     while i < element {
//         offset += *proof_sizes_words.at(i);
//         i += 1;
//     };
//     offset
// }

#[cfg(test)]
mod tests {}
