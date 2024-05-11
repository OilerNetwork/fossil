#[starknet::contract]
mod L1HeaderStore {
    use fossil::L1_headers_store::interface::IL1HeadersStore;
    use fossil::library::array_utils::SpanTraitExt;
    use fossil::types::ProcessBlockOptions;
    use starknet::{ContractAddress, EthAddress, get_caller_address};

    #[storage]
    struct Storage {
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

    #[abi(embed_v0)]
    impl L1HeaderStoreImpl of IL1HeadersStore<ContractState> {
        fn initialize(ref self: ContractState, l1_messages_origin: starknet::ContractAddress) {
            assert!(self.initialized.read() == false, "L1HeaderStore: already initialized");
            self.initialized.write(true);
            self.l1_messages_origin.write(l1_messages_origin);
        }

        fn receive_from_l1(
            ref self: ContractState,
            contract_address: starknet::ContractAddress,
            parent_hash: u256,
            block_number: u64
        ) {
            assert!(
                get_caller_address() == self.l1_messages_origin.read(),
                "L1HeaderStore: unauthorized caller"
            );
            self.block_parent_hash.write(block_number, parent_hash);

            if self.latest_l1_block.read() <= block_number {
                self.latest_l1_block.write(block_number);
            }
        }

        fn process_block(
            ref self: ContractState,
            option: ProcessBlockOptions,
            block_number: u64,
            block_header_rlp_bytes_len: usize,
            block_header_bytes: Array<usize>,
            block_header_rlp: Array<u64>,
        ) {}

        fn process_till_block(
            ref self: ContractState,
            start_block_number: u64,
            block_header_bytes: Array<usize>,
            block_header_words: Array<u64>,
            block_header_concat: Array<u64>,
        ) {}
        fn get_initialized(self: @ContractState, block_number: u64) -> bool {
            self.initialized.read()
        }

        fn get_parent_hash(self: @ContractState, block_number: u64) -> u256 {
            self.block_parent_hash.read(block_number)
        }

        fn get_latest_l1_block(self: @ContractState) -> u64 {
            self.latest_l1_block.read()
        }

        fn get_state_root(self: @ContractState, block_number: u64) -> u256 {
            self.block_state_root.read(block_number)
        }
        fn get_transactions_root(self: @ContractState, block_number: u64) -> u256 {
            self.block_transactions_root.read(block_number)
        }
        fn get_receipts_root(self: @ContractState, block_number: u64) -> u256 {
            self.block_receipts_root.read(block_number)
        }

        fn get_uncles_hash(self: @ContractState, block_number: u64) -> u256 {
            self.block_uncles_hash.read(block_number)
        }
        fn get_beneficiary(self: @ContractState, block_number: u64) -> starknet::EthAddress {
            self.block_beneficiary.read(block_number)
        }
        fn get_difficulty(self: @ContractState, block_number: u64) -> u64 {
            self.block_difficulty.read(block_number)
        }
        fn get_base_fee(self: @ContractState, block_number: u64) -> u64 {
            self.block_base_fee.read(block_number)
        }
        fn get_timestamp(self: @ContractState, block_number: u64) -> u64 {
            self.block_timestamp.read(block_number)
        }
        fn get_gas_used(self: @ContractState, block_number: u64) -> u64 {
            self.block_gas_used.read(block_number)
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn validate_provided_header_rlp(
            self: @ContractState,
            child_block_parent_hash: u256,
            block_number: u64,
            block_header_rlp_bytes_len: usize,
            block_header_rlp: Span<u64>
        ) {}
    }
}
