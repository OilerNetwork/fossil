#[starknet::contract]
pub mod L1HeaderStore {
    use core::array::ArrayTrait;
    use core::clone::Clone;
    use core::traits::Into;
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

        fn process_block(
            ref self: ContractState,
            option: ProcessBlockOptions,
            block_number: u64,
            block_header_rlp_bytes_len: usize,
            block_header_rlp: Array<u64>,
        ) {
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

        fn process_till_block(
            ref self: ContractState,
            options_set: ProcessBlockOptions,
            start_block_number: u64,
            block_header_concat: Array<usize>,
            block_header_words: Array<Array<u64>>,
        ) {
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
        // NOTE: Temporary functions for testing
        fn set_state_root(ref self: ContractState, block_number: u64, state_root: u256) {
            self.block_state_root.write(block_number, state_root);
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
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
