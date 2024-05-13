use fossil::types::{OptionsSet, Words64Sequence};

#[starknet::interface]
pub trait IFactRegistry<TState> {
    fn initialize(ref self: TState, l1_headers_store_addr: starknet::ContractAddress);
    fn prove_account(
        ref self: TState,
        option: OptionsSet,
        account: starknet::EthAddress,
        block: u64,
        proof_sizes_bytes: Array<usize>,
        proofs_concat: Array<u64>,
    );
    fn get_storage(
        ref self: TState,
        block: u64,
        account: starknet::EthAddress,
        slot: u256,
        proof_sizes_bytes: Array<usize>,
        proofs_concat: Array<u64>,
    ) -> Words64Sequence;
    fn get_storage_uint(
        ref self: TState,
        block: u64,
        account: starknet::EthAddress,
        slot: u256,
        proof_sizes_bytes: Array<usize>,
        proofs_concat: Array<u64>,
    ) -> u256;


    fn get_initialized(self: @TState) -> bool;
    fn get_l1_headers_store_addr(self: @TState) -> starknet::ContractAddress;
    fn get_verified_account_storage_hash(
        self: @TState, account: starknet::EthAddress, block: u64
    ) -> u256;
    fn get_verified_account_code_hash(
        self: @TState, account: starknet::EthAddress, block: u64
    ) -> u256;
    fn get_verified_account_balance(
        self: @TState, account: starknet::EthAddress, block: u64
    ) -> u256;
    fn get_verified_account_nonce(self: @TState, account: starknet::EthAddress, block: u64) -> u64;
}
