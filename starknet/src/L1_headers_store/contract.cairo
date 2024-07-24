//! This Contract receives block hashes from the L1 Message Proxy
//! Processes and Store block headers and sends them to Fact Registry.

#[starknet::contract]
pub mod L1HeaderStore {
    use core::array::ArrayTrait;
    use core::clone::Clone;
    use core::traits::Into;

    // Local imports.
    use fossil::L1_headers_store::interface::IL1HeadersStore;
    use fossil::library::blockheader_rlp_extractor::{
        decode_parent_hash, decode_uncle_hash, decode_beneficiary, decode_state_root,
        decode_transactions_root, decode_receipts_root, decode_difficulty, decode_base_fee,
        decode_timestamp, decode_gas_used
    };
    use fossil::library::keccak_utils::keccak_words64;
    use fossil::library::words64_utils::words64_to_u256;
    use fossil::types::ProcessBlockOptions;
    use fossil::types::Words64Sequence;
    use openzeppelin::access::ownable::OwnableComponent;
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************
    // Core lib imports 
    use openzeppelin::access::ownable::ownable::OwnableComponent::InternalTrait;
    use openzeppelin::upgrades::UpgradeableComponent;
    use openzeppelin::upgrades::interface::IUpgradeable;
    use starknet::{ContractAddress, EthAddress, get_caller_address, ClassHash};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: upgradeableEvent);

    // Ownable Mixin
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // Upgradeable 
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        starknet_handler_address: ContractAddress,
        l1_messages_origin: ContractAddress,
        latest_l1_block: u64,
        block_parent_hash: LegacyMap::<u64, u256>,
        block_state_root: LegacyMap::<u64, u256>,
        block_transactions_root: LegacyMap::<u64, u256>,
        block_receipts_root: LegacyMap::<u64, u256>,
        block_uncles_hash: LegacyMap::<u64, u256>,
        block_beneficiary: LegacyMap::<u64, EthAddress>,
        block_difficulty: LegacyMap::<u64, u64>,
        block_base_fee: LegacyMap::<u64, u64>,
        block_timestamp: LegacyMap::<u64, u64>,
        block_gas_used: LegacyMap::<u64, u64>,
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
    /// * `l1_messages_origin` - The address of L1 Message Proxy.
    /// * `owner` - .
    #[constructor]
    fn constructor(
        ref self: ContractState,
        l1_messages_origin: starknet::ContractAddress,
        owner: starknet::ContractAddress,
        starknet_handler_address: starknet::ContractAddress
    ) {
        self.l1_messages_origin.write(l1_messages_origin);
        self.ownable.initializer(owner);
        self.starknet_handler_address.write(starknet_handler_address);
    }

    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    // Implementation of IL1HeadersStore interface
    #[abi(embed_v0)]
    impl L1HeaderStoreImpl of IL1HeadersStore<ContractState> {
        /// Receives `block_number` and `parent_hash` from L1 Message Proxy for processing.
        /// 
        /// # Arguments
        /// * `parent_hash` - reference to the hash of the previous block's header.
        /// * `block_number` - unique identifier for each block.
        ///
        /// This function processess the `block_number` and `parent_hash`
        /// Inserts both into the `block_parent_hash` storage
        /// Updates the `latest_l1_block` storage with `block_number` if it's the latest.
        fn receive_from_l1(ref self: ContractState, parent_hash: u256, block_number: u64) {
            assert!(
                get_caller_address() == self.l1_messages_origin.read(),
                "L1HeaderStore: unauthorized caller"
            );
            self.block_parent_hash.write(block_number, parent_hash);

            if self.latest_l1_block.read() <= block_number {
                self.latest_l1_block.write(block_number);
            }
        }

        /// Change L1 Message Proxy address. (Only Owner)
        /// 
        /// # Arguments
        /// * `l1_messages_origin` - The address of L1 Message Proxy.
        fn change_l1_messages_origin(
            ref self: ContractState, l1_messages_origin: starknet::ContractAddress
        ) {
            self.ownable.assert_only_owner();
            self.l1_messages_origin.write(l1_messages_origin);
        }

        fn store_state_root(ref self: ContractState, block_number: u64, state_root: u256) {
            self.assert_only_starknet_handler();
            assert!(
                self.block_state_root.read(block_number) == 0,
                "L1HeaderStore: state root already exists"
            );
            self.block_state_root.write(block_number, state_root);
        }

        fn store_many_state_roots(
            ref self: ContractState, start_block: u64, end_block: u64, state_roots: Array<u256>
        ) {
            self.assert_only_starknet_handler();
            assert!(
                state_roots.len().into() == (end_block - start_block + 1),
                "L1HeaderStore: invalid state roots length"
            );

            let mut start = start_block;
            let mut index = 0;

            while start <= end_block {
                self.store_state_root(start, *state_roots.at(index));
                start += 1;
                index += 1;
            };
        }

        /// Retrieves the parent hash of the specified block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to retrieve the parent hash.
        ///
        /// # Returns
        /// * `u256` - The parent hash.
        fn get_parent_hash(self: @ContractState, block_number: u64) -> u256 {
            self.block_parent_hash.read(block_number)
        }

        /// Retrieves the latest L1 block number stored in the contract.
        ///
        /// # Returns
        /// * `u64` - The latest L1 block number.
        fn get_latest_l1_block(self: @ContractState) -> u64 {
            self.latest_l1_block.read()
        }

        /// Retrieves the state root of the specified block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to retrieve the state root.
        ///
        /// # Returns
        /// * `u256` - The state root.
        fn get_state_root(self: @ContractState, block_number: u64) -> u256 {
            self.block_state_root.read(block_number)
        }
    }

    #[abi(embed_v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        /// Upgrades the contract class hash to `new_class_hash`.
        /// This may only be called by the contract owner.
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.ownable.assert_only_owner();
            self.upgradeable._upgrade(new_class_hash);
        }
    }

    // *************************************************************************
    //                          INTERNAL FUNCTIONS
    // *************************************************************************
    #[generate_trait]
    impl Private of PrivateTrait {
        /// Validates the provided RLP-encoded block header `block_header_rlp` against the expected parent hash `child_block_parent_hash`.
        /// 
        /// # Arguments
        /// * `child_block_parent_hash` - The expected parent hash of the child block. The parent hash of the next block i.e The hash of block `block_number`
        /// * `block_number` - The block number of the child block.
        /// * `block_header_rlp_bytes_len` - The length of the RLP-encoded block header.
        /// * `block_header_rlp` - An array of u64 representing the RLP-encoded block header.
        ///
        /// # Returns
        /// A tuple containing:
        /// * `block_header_rlp` The RLP-encoded block header.
        /// * `block_header_rlp_bytes_len` The length of the RLP-encoded block header.
        /// 
        /// # Panics
        /// This function panics if the calculated hash from `block_header_rlp` which is `provided_rlp_hash_u256` 
        /// does not match the expected parent hash `child_block_parent_hash`.
        fn validate_provided_header_rlp(
            self: @ContractState,
            child_block_parent_hash: u256,
            block_number: u64,
            block_header_rlp_bytes_len: usize,
            block_header_rlp: Array<u64>
        ) -> (Array<u64>, usize) {
            let header_ints_sequence = Words64Sequence {
                values: block_header_rlp.span(), len_bytes: block_header_rlp_bytes_len,
            };

            let provided_rlp_hash = keccak_words64(header_ints_sequence);
            let provided_rlp_hash_u256 = words64_to_u256(provided_rlp_hash.values, provided_rlp_hash.len_bytes);

            assert!(
                child_block_parent_hash == provided_rlp_hash_u256,
                "L1HeaderStore: hashes are not equal"
            );

            (block_header_rlp, block_header_rlp_bytes_len)
        }

        fn assert_only_starknet_handler(self: @ContractState) {
            let caller = get_caller_address();
            assert(
                caller == self.starknet_handler_address.read(), 'Caller is not starknet handler'
            );
        }
    }
}
