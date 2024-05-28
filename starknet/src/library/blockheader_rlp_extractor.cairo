use fossil::library::rlp_utils::{extract_data, to_rlp_array};
use fossil::library::words64_utils::Words64Trait;
use fossil::types::Words64Sequence;
use starknet::EthAddress;

const PARENT_HASH_START: usize = 4;
const UNCLE_HASH_START: usize = 4 + 32 + 1;
const BENEFICIARY_START: usize = 4 + 32 + 1 + 32 + 1;
const STATE_ROOT_START: usize = 4 + 32 + 1 + 32 + 1 + 20 + 1;
const TRANSACTIONS_ROOT_START: usize = 4 + 32 + 1 + 32 + 1 + 20 + 1 + 32 + 1;
const RECEIPTS_ROOT_START: usize = 4 + 32 + 1 + 32 + 1 + 20 + 1 + 32 + 1 + 32 + 1;

mod decoder {
    pub const DIFFICULTY: usize = 7;
    pub const BLOCK_NUMBER: usize = 8;
    pub const GAS_LIMIT: usize = 9;
    pub const GAS_USED: usize = 10;
    pub const TIMESTAMP: usize = 11;
    pub const EXTRA_DATA: usize = 12;
    pub const MIX_HASH: usize = 13;
    pub const NONCE: usize = 14;
    pub const BASE_FEE: usize = 15;
}

pub fn decode_parent_hash(block_rlp: Words64Sequence) -> u256 {
    extract_data(block_rlp, PARENT_HASH_START, 32).from_words64()
}

pub fn decode_uncle_hash(block_rlp: Words64Sequence) -> u256 {
    extract_data(block_rlp, UNCLE_HASH_START, 32).from_words64()
}

pub fn decode_beneficiary(block_rlp: Words64Sequence) -> EthAddress {
    extract_data(block_rlp, BENEFICIARY_START, 32).from_words64()
}

pub fn decode_state_root(block_rlp: Words64Sequence) -> u256 {
    extract_data(block_rlp, STATE_ROOT_START, 32).from_words64()
}

pub fn decode_transactions_root(block_rlp: Words64Sequence) -> u256 {
    extract_data(block_rlp, TRANSACTIONS_ROOT_START, 32).from_words64()
}

pub fn decode_receipts_root(block_rlp: Words64Sequence) -> u256 {
    extract_data(block_rlp, RECEIPTS_ROOT_START, 32).from_words64()
}

pub fn decode_difficulty(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::DIFFICULTY, "Block RLP is too short");
    let data = *rlp_items.at(decoder::DIFFICULTY);
    let difficulty_rlp_element = extract_data(
        block_rlp, data.position, data.length
    );
    *difficulty_rlp_element.values.at(0)
}

pub fn decode_block_number(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::BLOCK_NUMBER, "Block RLP is too short"); // I'm not sure tha
    let data = *rlp_items.at(decoder::BLOCK_NUMBER);
    let block_number_rlp_element = extract_data(
        block_rlp, data.position, data.length
    );
    *block_number_rlp_element.values.at(0)
}

pub fn decode_gas_limit(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::GAS_LIMIT, "Block RLP is too short");
    let data = *rlp_items.at(decoder::GAS_LIMIT);
    let gas_limit_rlp_element = extract_data(
        block_rlp, data.position, data.length
    );
    *gas_limit_rlp_element.values.at(0)
}

pub fn decode_gas_used(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::GAS_USED, "Block RLP is too short");
    let data = *rlp_items.at(decoder::GAS_USED);
    let gas_used_rlp_element = extract_data(
        block_rlp, data.position, data.length
    );
    *gas_used_rlp_element.values.at(0)
}

pub fn decode_timestamp(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::TIMESTAMP, "Block RLP is too short");
    let data = *rlp_items.at(decoder::TIMESTAMP);
    let timestamp_rlp_element = extract_data(
        block_rlp, data.position, data.length
    );
    *timestamp_rlp_element.values.at(0)
}

pub fn decode_base_fee(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::BASE_FEE, "Block RLP is too short");
    let data = *rlp_items.at(decoder::BASE_FEE);
    let base_fee_rlp_element = extract_data(
        block_rlp, data.position, data.length
    );
    *base_fee_rlp_element.values.at(0)
}
