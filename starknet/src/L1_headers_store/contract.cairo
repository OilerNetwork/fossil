//! This Contract receives block hashes from the L1 Message Proxy
//! Processes and Store block headers and sends them to Fact Registry.

#[starknet::contract]
pub mod L1HeaderStore {
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************
    // Core lib imports 
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
        initialized: bool,
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
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    // Implementation of IL1HeadersStore interface
    #[abi(embed_v0)]
    impl L1HeaderStoreImpl of IL1HeadersStore<ContractState> {
        /// Initialize the contract.
        /// 
        /// # Arguments
        /// * `l1_messages_origin` - The address of L1 Message Proxy.
        fn initialize(
            ref self: ContractState,
            l1_messages_origin: starknet::ContractAddress,
            admin: starknet::ContractAddress
        ) {
            assert!(self.initialized.read() == false, "L1HeaderStore: already initialized");
            self.initialized.write(true);
            self.l1_messages_origin.write(l1_messages_origin);
            self.ownable.initializer(admin);
        }

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

        /// Processes a block by validating its RLP-encoded header `block_header_rlp` and save the relevant fields into the contract storage.
        /// 
        /// # Arguments
        /// * `option` - An Enum `option` which specifies which field of the block header to decode and store.
        /// * `block_number` - The block number of the child block.
        /// * `block_header_rlp_bytes_len` - The length of the RLP-encoded block header.
        /// * `block_header_rlp` - The RLP-encoded block header.
        /// 
        /// This function validates the `block_header_rlp` provided,
        /// decodes and stores each field in the block header
        /// starting with the `parent_hash` and fields specified in the `ProcessBlockOptions` Enum
        ///
        /// # Processing Options
        /// The `ProcessBlockOptions` enum specifies the field to be decoded and stored:
        /// * `UncleHash`: Decodes and stores the uncle hash.
        /// * `Beneficiary`: Decodes and stores the beneficiary address.
        /// * `StateRoot`: Decodes and stores the state root.
        /// * `TxRoot`: Decodes and stores the transactions root.
        /// * `ReceiptRoot`: Decodes and stores the receipts root.
        /// * `Difficulty`: Decodes and stores the difficulty.
        /// * `GasUsed`: Decodes and stores the gas used.
        /// * `TimeStamp`: Decodes and stores the timestamp.
        /// * `BaseFee`: Decodes and stores the base fee.
        /// 
        /// # Panics
        /// This function panics if the provided block header is invalid or if any of the decoding operations fail.
        fn process_block(
            ref self: ContractState,
            option: ProcessBlockOptions,
            block_number: u64,
            block_header_rlp_bytes_len: usize,
            block_header_rlp: Array<u64>,
        ) {
            self.ownable.assert_only_owner();
            let child_block_parent_hash = self.get_parent_hash(block_number + 1);

            let (block_header_rlp, _) = self
                .validate_provided_header_rlp(
                    child_block_parent_hash,
                    block_number,
                    block_header_rlp_bytes_len,
                    block_header_rlp
                );

            let block_rlp = Words64Sequence {
                values: block_header_rlp.span(), len_bytes: block_header_rlp_bytes_len,
            };
            let parent_hash = decode_parent_hash(block_rlp);
            self.block_parent_hash.write(block_number, parent_hash);

            match option {
                ProcessBlockOptions::UncleHash => {
                    let field_value = decode_uncle_hash(block_rlp);
                    self.block_uncles_hash.write(block_number, field_value);
                },
                ProcessBlockOptions::Beneficiary => {
                    let field_value = decode_beneficiary(block_rlp);
                    self.block_beneficiary.write(block_number, field_value);
                },
                ProcessBlockOptions::StateRoot => {
                    let field_value = decode_state_root(block_rlp);
                    self.block_state_root.write(block_number, field_value);
                },
                ProcessBlockOptions::TxRoot => {
                    let field_value = decode_transactions_root(block_rlp);
                    self.block_transactions_root.write(block_number, field_value);
                },
                ProcessBlockOptions::ReceiptRoot => {
                    let field_value = decode_receipts_root(block_rlp);
                    self.block_receipts_root.write(block_number, field_value);
                },
                ProcessBlockOptions::Difficulty => {
                    let field_value = decode_difficulty(block_rlp);
                    self.block_difficulty.write(block_number, field_value);
                },
                ProcessBlockOptions::GasUsed => {
                    let field_value = decode_gas_used(block_rlp);
                    self.block_gas_used.write(block_number, field_value);
                },
                ProcessBlockOptions::TimeStamp => {
                    let field_value = decode_timestamp(block_rlp);
                    self.block_timestamp.write(block_number, field_value);
                },
                ProcessBlockOptions::BaseFee => {
                    let field_value = decode_base_fee(block_rlp);
                    self.block_base_fee.write(block_number, field_value);
                },
                _ => {}
            }
        }


        /// Processes a sequence of blocks by validating their RLP-encoded block headers `block_header_words` and updating the contract state.
        ///
        /// # Arguments
        /// * `options_set` - An Enum `option` which specifies which field of the block header to decode and store for the last block in the sequence.
        /// * `start_block_number` - The block number from which to start processing.
        /// * `block_header_concat` - An array of sizes representing the lengths of each block's RLP-encoded header.
        /// * `block_header_words` - An array of RLP-encoded block headers.
        ///
        /// # Panics
        /// Panics if the lengths of `block_header_concat` and `block_header_words` do not match, or if any of the provided block headers are invalid.
        /// 
        /// This function iterates through a series of blocks starting from `start_block_number`, 
        /// validates each block's RLP-encoded header, and updates the contract state accordingly. 
        /// For the final block in the sequence, additional processing is done based on the provided `options_set`.
        fn process_till_block(
            ref self: ContractState,
            options_set: ProcessBlockOptions,
            start_block_number: u64,
            block_header_concat: Array<usize>,
            block_header_words: Array<Array<u64>>,
        ) {
            self.ownable.assert_only_owner();
            assert!(
                block_header_concat.len() == block_header_words.len(),
                "L1HeaderStore: block_header_bytes and block_header_words must have the same length"
            );
            let mut parent_hash = self.get_parent_hash(start_block_number + 1);

            let mut current_index: u32 = 0;
            let mut save_block_number = start_block_number + current_index.into();
            while current_index < block_header_words
                .len() {
                    let (block_header_rlp_bytes, len) = self
                        .validate_provided_header_rlp(
                            parent_hash,
                            save_block_number,
                            block_header_concat.at(current_index).clone(),
                            block_header_words.at(current_index).clone(),
                        );

                    current_index += 1;
                    save_block_number += 1;
                    parent_hash = self.get_parent_hash(save_block_number + 1);

                    if current_index == block_header_words.len() {
                        // Process the last block based on options and header data
                        self
                            .process_block(
                                options_set, save_block_number - 1, len, block_header_rlp_bytes,
                            );
                    }
                };

            self.block_parent_hash.write(save_block_number, parent_hash);
        }

        /// Checks if the contract state has been initialized for a specific block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number to check.
        ///
        /// # Returns
        /// * A boolean indicating whether the contract state has been initialized.
        fn get_initialized(self: @ContractState, block_number: u64) -> bool {
            self.initialized.read()
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

        /// Retrieves the transactions root of the specified block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to retrieve the transactions root.
        ///
        /// # Returns
        /// * `u256` - The transactions root.
        fn get_transactions_root(self: @ContractState, block_number: u64) -> u256 {
            self.block_transactions_root.read(block_number)
        }

        /// Retrieves the receipts root of the specified block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to retrieve the receipts root.
        ///
        /// # Returns
        /// * `u256` - The receipts root.
        fn get_receipts_root(self: @ContractState, block_number: u64) -> u256 {
            self.block_receipts_root.read(block_number)
        }

        /// Retrieves the uncles hash of the specified block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to retrieve the uncles hash.
        ///
        /// # Returns
        /// * `u256` - The uncles hash.
        fn get_uncles_hash(self: @ContractState, block_number: u64) -> u256 {
            self.block_uncles_hash.read(block_number)
        }

        /// Retrieves the beneficiary address of the specified block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to retrieve the beneficiary address.
        ///
        /// # Returns
        /// * `starknet::EthAddress` - The beneficiary address .
        fn get_beneficiary(self: @ContractState, block_number: u64) -> starknet::EthAddress {
            self.block_beneficiary.read(block_number)
        }

        /// Retrieves the block difficulty of the specified block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to retrieve the block difficulty.
        ///
        /// # Returns
        /// * `u64` - The block difficulty.
        fn get_difficulty(self: @ContractState, block_number: u64) -> u64 {
            self.block_difficulty.read(block_number)
        }

        /// Retrieves the base fee of the specified block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to retrieve the base fee.
        ///
        /// # Returns
        /// * `u64` - The base fee.
        fn get_base_fee(self: @ContractState, block_number: u64) -> u64 {
            self.block_base_fee.read(block_number)
        }

        /// Retrieves the timestamp of the specified block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to retrieve the timestamp.
        ///
        /// # Returns
        /// * `u64` - The timestamp .
        fn get_timestamp(self: @ContractState, block_number: u64) -> u64 {
            self.block_timestamp.read(block_number)
        }

        /// Retrieves the gas used of the specified block number.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to retrieve the gas used.
        ///
        /// # Returns
        /// * `u64` - The gas used.
        fn get_gas_used(self: @ContractState, block_number: u64) -> u64 {
            self.block_gas_used.read(block_number)
        }

        /// Sets the state root for the specified block number.
        ///
        /// This is a temporary function intended for testing purposes.
        ///
        /// # Arguments
        /// * `block_number` - The block number for which to set the state root.
        /// * `state_root` - The state root to set.
        // NOTE: Temporary functions for testing
        fn set_state_root(ref self: ContractState, block_number: u64, state_root: u256) {
            self.block_state_root.write(block_number, state_root);
        }
    }

    #[external(v0)]
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
            let provided_rlp_hash_u256 = words64_to_u256(provided_rlp_hash.values);

            assert!(
                child_block_parent_hash == provided_rlp_hash_u256,
                "L1HeaderStore: hashes are not equal"
            );

            (block_header_rlp, block_header_rlp_bytes_len)
        }
    }
}
