//! Contract for receiving block header hashes from L1 of the Ethereum network.

#[starknet::contract]
pub mod L1MessagesProxy {
    // Local imports.
    use fossil::L1_headers_store::interface::{
        IL1HeadersStoreDispatcher, IL1HeadersStoreDispatcherTrait
    };
    use fossil::L1_messages_proxy::interface::IL1MessagesProxy;
    use fossil::library::words64_utils::words64_to_u256;
    use openzeppelin_access::ownable::OwnableComponent;
    use openzeppelin_upgrades::UpgradeableComponent;
    use openzeppelin_upgrades::interface::IUpgradeable;
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************
    // Core lib imports
    use starknet::{ContractAddress, EthAddress, ClassHash};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: upgradeableEvent);

    // Ownable Mixin
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // Upgradeable
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

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
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        l1_messages_sender: EthAddress,
        l1_headers_store: IL1HeadersStoreDispatcher,
    }

    // *************************************************************************
    //                             EVENTS
    // *************************************************************************
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        upgradeableEvent: UpgradeableComponent::Event
    }

    // *************************************************************************
    //                              CONSTRUCTOR
    // *************************************************************************
    /// Contract Constructor.
    ///
    /// # Arguments
    /// * `l1_messages_sender` - The address of the L1 solidity contract.
    /// * `owner` - The owner address.
    #[constructor]
    fn constructor(
        ref self: ContractState, l1_messages_sender: EthAddress, owner: starknet::ContractAddress
    ) {
        self.l1_messages_sender.write(l1_messages_sender);
        self.ownable.initializer(owner);
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
    fn receive_from_l1(
        ref self: ContractState, from_address: felt252, parent_hash: u256, block_number: u256
    ) {
        assert!(
            from_address == self.get_l1_messages_sender().into(),
            "L1MessagesProxy: unauthorized sender"
        );

        let block_number: u64 = block_number.try_into().expect('felt_to_u64_fail');

        let header_store = self.l1_headers_store.read();
        header_store.receive_from_l1(parent_hash, block_number);
    }

    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    // Implementation of IL1MessagesProxy interface
    #[abi(embed_v0)]
    impl L1MessagesProxyImpl of IL1MessagesProxy<ContractState> {
        /// Set the Header Store Address. (Only Owner)
        ///
        /// # Arguments
        /// * `l1_headers_store_address` - The address of the header store cairo contract.
        fn set_l1_headers_store(
            ref self: ContractState, l1_headers_store_address: starknet::ContractAddress
        ) {
            self.ownable.assert_only_owner();
            self
                .l1_headers_store
                .write(IL1HeadersStoreDispatcher { contract_address: l1_headers_store_address });
        }

        /// Change contract address. (Only Owner)
        ///
        /// # Arguments
        /// * `l1_messages_sender` - The address of the L1 solidity contract.
        /// * `l1_headers_store_address` - The address of the header store cairo contract.
        fn change_contract_addresses(
            ref self: ContractState,
            l1_messages_sender: EthAddress,
            l1_headers_store_address: starknet::ContractAddress
        ) {
            self.ownable.assert_only_owner();
            self.l1_messages_sender.write(l1_messages_sender);
            self
                .l1_headers_store
                .write(IL1HeadersStoreDispatcher { contract_address: l1_headers_store_address });
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

    #[abi(embed_v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        /// Upgrades the contract class hash to `new_class_hash`.
        /// This may only be called by the contract owner.
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.ownable.assert_only_owner();
            self.upgradeable.upgrade(new_class_hash);
        }
    }
}
