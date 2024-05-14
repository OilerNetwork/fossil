#[starknet::contract]
pub mod L1MessagesProxy {
    use fossil::L1_headers_store::interface::IL1HeadersStore;
    use fossil::L1_messages_proxy::interface::IL1MessagesProxy;
    use starknet::{ContractAddress, EthAddress};

    #[derive(Drop, Serde)]
    struct L1Payload {
        hash_word1: felt252,
        hash_word2: felt252,
        hash_word3: felt252,
        hash_word4: felt252,
        block_number: felt252,
    }

    #[storage]
    struct Storage {
        initialized: bool,
        l1_messages_sender: EthAddress,
        l1_headers_store_addr: ContractAddress,
    }

    #[l1_handler]
    fn receive_from_l1(ref self: ContractState, from_address: felt252, data: L1Payload) {
        assert!(
            from_address == self.get_l1_messages_sender().into(), "L1MessagesProxy: unauthorized sender"
        );
    }

    #[abi(embed_v0)]
    impl L1MessagesProxyImpl of IL1MessagesProxy<ContractState> {
        fn initialize(
            ref self: ContractState,
            l1_messages_sender: EthAddress,
            l1_headers_store_address: starknet::ContractAddress,
            owner: starknet::ContractAddress,
        ) {
            assert!(!self.get_initialized(), "L1MessagesProxy: already initialized");
            self.initialized.write(true);
            self.l1_messages_sender.write(l1_messages_sender);
            self.l1_headers_store_addr.write(l1_headers_store_address);
        }

        fn change_contract_addresses(
            ref self: ContractState,
            l1_messages_sender: EthAddress,
            l1_headers_store_address: starknet::ContractAddress
        ) {
            self.l1_messages_sender.write(l1_messages_sender);
            self.l1_headers_store_addr.write(l1_headers_store_address);
        }

        fn get_initialized(self: @ContractState) -> bool {
            self.initialized.read()
        }

        fn get_l1_messages_sender(self: @ContractState) -> EthAddress {
            self.l1_messages_sender.read()
        }

        fn get_l1_headers_store_address(self: @ContractState) -> ContractAddress {
            self.l1_headers_store_addr.read()
        }
    }
}
