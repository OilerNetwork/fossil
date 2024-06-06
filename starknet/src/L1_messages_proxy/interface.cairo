#[starknet::interface]
pub trait IL1MessagesProxy<TState> {
    fn set_l1_headers_store(ref self: TState, l1_headers_store_address: starknet::ContractAddress);
    fn change_contract_addresses(
        ref self: TState,
        l1_messages_sender: starknet::EthAddress,
        l1_headers_store_address: starknet::ContractAddress
    );
    fn get_initialized(self: @TState) -> bool;
    fn get_l1_messages_sender(self: @TState) -> starknet::EthAddress;
    fn get_l1_headers_store_address(self: @TState) -> starknet::ContractAddress;
}
