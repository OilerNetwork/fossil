//! Contract for receiving block header hashes from L1 of the Ethereum network.

#[starknet::contract]
pub mod L1MessagesProxy {
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************
    // Core lib imports   
    use starknet::{ContractAddress, EthAddress};

    // Local imports.
    use fossil::L1_headers_store::interface::{
        IL1HeadersStoreDispatcher, IL1HeadersStoreDispatcherTrait
    };
    use fossil::L1_messages_proxy::interface::IL1MessagesProxy;
    use fossil::library::words64_utils::words64_to_u256;
    
    /// Struct to receive message (parentHash_, blockNumber_) from L1.
    #[derive(Drop, Serde)]
    struct L1Payload {
        hash_word1: felt252,
        hash_word2: felt252,
        hash_word3: felt252,
        hash_word4: felt252,
        block_number: felt252,
    }

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        initialized: bool,
        l1_messages_sender: EthAddress,
        l1_headers_store: IL1HeadersStoreDispatcher,
    }

    // *************************************************************************
    //                     L1 HANDLER FUNCTION
    // *************************************************************************
    /// Receive `message` from L1 which is deserialized as L1Payload.
    /// 
    /// # Arguments
    /// * `from_address` - The contract address on L1 to receive messages from.
    /// * `data` - The payload from L1, an array of 'parent_hash' and 'block_number'.
    ///
    /// This function verifies the sender of the L1 message, extracts the `hash_words`
    /// into a `parent_hash` array and `block_number`, and sends `parent_hash` and
    /// `block_number` to the `header_store`'s `receive_from_l1` function for processing.
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

    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    // Implementation of IL1MessagesProxy interface
    #[abi(embed_v0)]
    impl L1MessagesProxyImpl of IL1MessagesProxy<ContractState> {
        /// Initialize the contract.
        /// 
        /// # Arguments
        /// * `l1_messages_sender` - The address of the L1 solidity contract.
        /// * `l1_headers_store_address` - The address of the Header Store cairo contract.
        /// * `owner` - The owner address.
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

        /// Change contract address.
        /// 
        /// # Arguments
        /// * `l1_messages_sender` - The address of the L1 solidity contract.
        /// * `l1_headers_store_address` - The address of the header store cairo contract.
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

        /// Checks if the contract has been initialized
        ///
        /// # Returns
        /// * A boolean indicating whether the contract state has been initialized.
        fn get_initialized(self: @ContractState) -> bool {
            self.initialized.read()
        }

        /// Retrieves the sender address of L1 messages stored in the contract state.
        ///
        /// # Returns
        /// * `EthAddress` - The Ethereum address of the sender of L1 messages.
        fn get_l1_messages_sender(self: @ContractState) -> EthAddress {
            self.l1_messages_sender.read()
        }

        /// Retrieves the address of the L1 header store contract address.
        ///
        /// # Returns
        /// * `ContractAddress` - The address of the L1 header store contract.
        fn get_l1_headers_store_address(self: @ContractState) -> ContractAddress {
            self.l1_headers_store.read().contract_address
        }
    }
}
