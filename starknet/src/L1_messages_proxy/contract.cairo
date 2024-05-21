#[starknet::contract]
pub mod L1MessagesProxy {
    use fossil::L1_headers_store::interface::{
        IL1HeadersStoreDispatcher, IL1HeadersStoreDispatcherTrait
    };
    use fossil::L1_messages_proxy::interface::IL1MessagesProxy;
    use fossil::library::words64_utils::words64_to_u256;
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
        l1_headers_store: IL1HeadersStoreDispatcher,
    }

    #[l1_handler]
    fn receive_from_l1(ref self: ContractState, from_address: felt252, data: L1Payload) {
        assert!(
            from_address == self.get_l1_messages_sender().into(),
            "L1MessagesProxy: unauthorized sender"
        );
        let pararent_hash: Array<u64> = array![
            data.hash_word1.try_into().expect('felt_to_u64_fail'),
            data.hash_word2.try_into().expect('felt_to_u64_fail'),
            data.hash_word3.try_into().expect('felt_to_u64_fail'),
            data.hash_word4.try_into().expect('felt_to_u64_fail')
        ];
        let block_number: u64 = data.block_number.try_into().expect('felt_to_u64_fail');

        let header_store = self.l1_headers_store.read();
        header_store.receive_from_l1(words64_to_u256(pararent_hash.span()), block_number);
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
            self
                .l1_headers_store
                .write(IL1HeadersStoreDispatcher { contract_address: l1_headers_store_address });
        }

        fn change_contract_addresses(
            ref self: ContractState,
            l1_messages_sender: EthAddress,
            l1_headers_store_address: starknet::ContractAddress
        ) {
            self.l1_messages_sender.write(l1_messages_sender);
            self
                .l1_headers_store
                .write(IL1HeadersStoreDispatcher { contract_address: l1_headers_store_address });
        }

        fn get_initialized(self: @ContractState) -> bool {
            self.initialized.read()
        }

        fn get_l1_messages_sender(self: @ContractState) -> EthAddress {
            self.l1_messages_sender.read()
        }

        fn get_l1_headers_store_address(self: @ContractState) -> ContractAddress {
            self.l1_headers_store.read().contract_address
        }
    }
}
