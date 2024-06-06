//! Library for function to decoding RLP Block Header.

// *************************************************************************
//                                  IMPORTS
// *************************************************************************
use fossil::library::rlp_utils::{extract_data, to_rlp_array};
use fossil::library::words64_utils::Words64Trait;
use fossil::types::Words64Sequence;
use starknet::EthAddress;

// *************************************************************************
//                                  CONSTANTS
// *************************************************************************
const PARENT_HASH_START: usize = 4;
const UNCLE_HASH_START: usize = 4 + 32 + 1;
const BENEFICIARY_START: usize = 4 + 32 + 1 + 32 + 1;
const STATE_ROOT_START: usize = 4 + 32 + 1 + 32 + 1 + 20 + 1;
const TRANSACTIONS_ROOT_START: usize = 4 + 32 + 1 + 32 + 1 + 20 + 1 + 32 + 1;
const RECEIPTS_ROOT_START: usize = 4 + 32 + 1 + 32 + 1 + 20 + 1 + 32 + 1 + 32 + 1;

/// Constants for decoding specific fields from RLP-encoded block headers.
/// 
/// # Constants
/// * `DIFFICULTY` - The index for the difficulty field in the RLP-encoded block header.
/// * `BLOCK_NUMBER` - The index for the block number field in the RLP-encoded block header.
/// * `GAS_LIMIT` - The index for the gas limit field in the block RLP-encoded header.
/// * `GAS_USED` - The index for the gas used field in the block RLP-encoded header.
/// * `TIMESTAMP` - The index for the timestamp field in the block RLP-encoded header.
/// * `EXTRA_DATA` - The index for the extra data field in the RLP-encoded block header.
/// * `MIX_HASH` - The index for the mix hash field in the RLP-encoded block header.
/// * `NONCE` - The index for the nonce field in the RLP-encoded block header.
/// * `BASE_FEE` - The index for the base fee field in the RLP-encoded block header.
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

/// Extracts the parent hash from a given RLP-encoded block header.
/// 
/// This function extracts the parent hash from the RLP-encoded block header sequence
/// starting at a predefined offset and converts it from a sequence of 64-bit words
/// into a `u256` value.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u256`- The parent hash extracted from the block header.
pub fn decode_parent_hash(block_rlp: Words64Sequence) -> u256 {
    extract_data(block_rlp, PARENT_HASH_START, 32).from_words64()
}

/// Extracts the uncle hash from a given RLP-encoded block header.
/// 
/// This function extracts the uncle hash from the RLP-encoded block header sequence
/// starting at a predefined offset and converts it from a sequence of 64-bit words
/// into a `u256` value.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u256`- The uncle hash extracted from the block header.
pub fn decode_uncle_hash(block_rlp: Words64Sequence) -> u256 {
    extract_data(block_rlp, UNCLE_HASH_START, 32).from_words64()
}

/// Extracts the beneficiary from a given RLP-encoded block header.
/// 
/// This function extracts the beneficiary from the RLP-encoded block header sequence
/// starting at a predefined offset and converts it from a sequence of 64-bit words
/// into a `u256` value.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u256`- The beneficiary extracted from the block header.
pub fn decode_beneficiary(block_rlp: Words64Sequence) -> EthAddress {
    extract_data(block_rlp, BENEFICIARY_START, 24).from_words64()
}

/// Extracts the state root from a given RLP-encoded block header.
/// 
/// This function extracts the beneficiary from the RLP-encoded block header sequence
/// starting at a predefined offset and converts it from a sequence of 64-bit words
/// into a `u256` value.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u256`- The state root extracted from the block header.
pub fn decode_state_root(block_rlp: Words64Sequence) -> u256 {
    extract_data(block_rlp, STATE_ROOT_START, 32).from_words64()
}

/// Extracts the transaction root from a given RLP-encoded block header.
/// 
/// This function extracts the transaction root from the RLP-encoded block header sequence
/// starting at a predefined offset and converts it from a sequence of 64-bit words
/// into a `u256` value.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u256`- The transaction root extracted from the block header.
pub fn decode_transactions_root(block_rlp: Words64Sequence) -> u256 {
    extract_data(block_rlp, TRANSACTIONS_ROOT_START, 32).from_words64()
}

/// Extracts the beneficiary from a given RLP-encoded block header.
/// 
/// This function extracts the beneficiary from the RLP-encoded block header sequence
/// starting at a predefined offset and converts it from a sequence of 64-bit words
/// into a `u256` value.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u256`- The beneficiary extracted from the block header.
pub fn decode_receipts_root(block_rlp: Words64Sequence) -> u256 {
    extract_data(block_rlp, RECEIPTS_ROOT_START, 32).from_words64()
}


/// Extracts the difficulty from a given RLP-encoded block header.
/// 
/// This function extracts the difficulty value from the RLP-encoded block header sequence.
/// It asserts that the block RLP contains enough elements to access the difficulty value
/// and then extracts and returns the difficulty as a `u64`.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// A `u64` representing the difficulty extracted from the block header.
///
/// # Panics
/// This function will panic if the RLP-encoded block header does not contain
/// enough elements to access the difficulty value.
pub fn decode_difficulty(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::DIFFICULTY, "Block RLP is too short");
    let data = *rlp_items.at(decoder::DIFFICULTY);
    let difficulty_rlp_element = extract_data(block_rlp, data.position, data.length);
    *difficulty_rlp_element.values.at(0)
}

/// Extracts the block number from a given RLP-encoded block header.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u64` - The block number extracted from the block header.
///
/// # Panics
/// This function will panic if the RLP-encoded block header does not contain
/// enough elements to access the block number value.
pub fn decode_block_number(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::BLOCK_NUMBER, "Block RLP is too short"); // I'm not sure tha
    let data = *rlp_items.at(decoder::BLOCK_NUMBER);
    let block_number_rlp_element = extract_data(block_rlp, data.position, data.length);
    *block_number_rlp_element.values.at(0)
}

/// Extracts the gas limit from a given RLP-encoded block header.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u64` - The gas limit extracted from the block header.
///
/// # Panics
/// This function will panic if the RLP-encoded block header does not contain
/// enough elements to access the gas limit value.
pub fn decode_gas_limit(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::GAS_LIMIT, "Block RLP is too short");
    let data = *rlp_items.at(decoder::GAS_LIMIT);
    let gas_limit_rlp_element = extract_data(block_rlp, data.position, data.length);
    *gas_limit_rlp_element.values.at(0)
}

/// Extracts the gas used from a given RLP-encoded block header.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u64` - The gas used extracted from the block header.
///
/// # Panics
/// This function will panic if the RLP-encoded block header does not contain
/// enough elements to access the gas used value.
pub fn decode_gas_used(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::GAS_USED, "Block RLP is too short");
    let data = *rlp_items.at(decoder::GAS_USED);
    let gas_used_rlp_element = extract_data(block_rlp, data.position, data.length);
    *gas_used_rlp_element.values.at(0)
}

/// Extracts the timestamp from a given RLP-encoded block header.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u64` - The timestamp extracted from the block header.
///
/// # Panics
/// This function will panic if the RLP-encoded block header does not contain
/// enough elements to access the timestamp value.
pub fn decode_timestamp(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::TIMESTAMP, "Block RLP is too short");
    let data = *rlp_items.at(decoder::TIMESTAMP);
    let timestamp_rlp_element = extract_data(block_rlp, data.position, data.length);
    *timestamp_rlp_element.values.at(0)
}

/// Extracts the base fee from a given RLP-encoded block header.
/// 
/// # Arguments
/// * `block_rlp` - A `Words64Sequence` containing the RLP-encoded block header data.
///
/// # Returns
/// * `u64` - The base fee extracted from the block header.
///
/// # Panics
/// This function will panic if the RLP-encoded block header does not contain
/// enough elements to access the base fee value.
pub fn decode_base_fee(block_rlp: Words64Sequence) -> u64 {
    let rlp_items = to_rlp_array(block_rlp);
    assert!(rlp_items.len() > decoder::BASE_FEE, "Block RLP is too short");
    let data = *rlp_items.at(decoder::BASE_FEE);
    let base_fee_rlp_element = extract_data(block_rlp, data.position, data.length);
    *base_fee_rlp_element.values.at(0)
}
