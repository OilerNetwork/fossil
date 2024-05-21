use fossil::types::ProcessBlockOptions;
use starknet::{EthAddress, ContractAddress};

#[starknet::interface]
pub trait IL1HeadersStore<TState> {
    fn initialize(ref self: TState, l1_messages_origin: ContractAddress);
    fn receive_from_l1(ref self: TState, parent_hash: u256, block_number: u64);
    fn process_block(
        ref self: TState,
        option: ProcessBlockOptions,
        block_number: u64,
        block_header_rlp_bytes_len: usize,
        block_header_rlp: Array<u64>,
    );
    fn process_till_block(
        ref self: TState,
        options_set: ProcessBlockOptions,
        start_block_number: u64,
        block_header_concat: Array<usize>,
        block_header_words: Array<Array<u64>>,
    );
    fn get_initialized(self: @TState, block_number: u64) -> bool;
    fn get_parent_hash(self: @TState, block_number: u64) -> u256;
    fn get_latest_l1_block(self: @TState) -> u64;
    fn get_state_root(self: @TState, block_number: u64) -> u256;
    fn get_transactions_root(self: @TState, block_number: u64) -> u256;
    fn get_receipts_root(self: @TState, block_number: u64) -> u256;
    fn get_uncles_hash(self: @TState, block_number: u64) -> u256;
    fn get_beneficiary(self: @TState, block_number: u64) -> EthAddress;
    fn get_difficulty(self: @TState, block_number: u64) -> u64;
    fn get_base_fee(self: @TState, block_number: u64) -> u64;
    fn get_timestamp(self: @TState, block_number: u64) -> u64;
    fn get_gas_used(self: @TState, block_number: u64) -> u64;

    // NOTE: Temporary functions for testing
    fn set_state_root(ref self: TState, block_number: u64, state_root: u256);
}
