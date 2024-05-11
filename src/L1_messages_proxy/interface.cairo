#[starknet::interface]
pub trait IL1MessagesProxy<TState> {
    fn initialize(
        ref self: TState,
        l1_messages_sender: felt252,
        l1_headers_store_address: starknet::ContractAddress,
        owner: starknet::ContractAddress,
    );
    fn change_contract_addresses(
        ref self: TState,
        l1_messages_sender: felt252,
        l1_headers_store_address: starknet::ContractAddress
    );
    fn get_initialized(self: @TState) -> bool;
    fn get_l1_messages_sender(self: @TState) -> felt252;
    fn get_l1_headers_store_address(self: @TState) -> starknet::ContractAddress;
}
