use fossil::types::{MMRProof, BlockRLP, Words64Sequence};
use starknet::{EthAddress, ContractAddress};

#[starknet::interface]
pub trait IL1HeadersStore<TState> {
    fn receive_from_l1(ref self: TState, parent_hash: u256, block_number: u64);
    fn change_l1_messages_origin(ref self: TState, l1_messages_origin: starknet::ContractAddress);
    fn verify_mmr_inclusion(
        ref self: TState, block_hash: u256, mmr_proof: MMRProof, encoded_block: BlockRLP
    ) -> bool;
    fn set_latest_mmr_root(ref self: TState, new_root: u256);

    fn get_latest_block_hash(self: @TState) -> u256;
    fn get_latest_l1_block_number(self: @TState) -> u64;
    fn get_mmr_root(self: @TState) -> u256;
    fn get_block_state_root(self: @TState, block_number: u64) -> u256;
}
