#[starknet::contract]
pub mod FactRegistry {
    use fossil::L1_headers_store::interface::{
        IL1HeadersStore, IL1HeadersStoreDispatcher, IL1HeadersStoreDispatcherTrait
    };
    use fossil::fact_registry::interface::IFactRegistry;
    use fossil::library::{
        trie_proof::verify_proof, words64_utils::{Words64Trait, words64_to_int},
        rlp_utils::{to_rlp_array, extract_data, extract_element}, keccak_utils::keccak_words64
    };
    use fossil::types::{OptionsSet, Words64Sequence, RLPItem};
    use starknet::{ContractAddress, EthAddress, contract_address_const};

    #[storage]
    struct Storage {
        initialized: bool,
        l1_headers_store: IL1HeadersStoreDispatcher,
        verified_account_storage_hash: LegacyMap::<(EthAddress, u64), u256>,
        verified_account_code_hash: LegacyMap::<(EthAddress, u64), u256>,
        verified_account_balance: LegacyMap::<(EthAddress, u64), u256>,
        verified_account_nonce: LegacyMap::<(EthAddress, u64), u64>,
    }

    #[abi(embed_v0)]
    impl FactRegistry of IFactRegistry<ContractState> {
        fn initialize(ref self: ContractState, l1_headers_store_addr: starknet::ContractAddress) {
            assert!(self.initialized.read() == false, "FactRegistry: already initialized");
            self
                .l1_headers_store
                .write(IL1HeadersStoreDispatcher { contract_address: l1_headers_store_addr });
        }

        fn prove_account(
            ref self: ContractState,
            option: OptionsSet,
            account: starknet::EthAddress,
            block: u64,
            proof_sizes_bytes: Array<usize>,
            proofs_concat: Array<u64>,
        ) {
            let state_root = self.l1_headers_store.read().get_state_root(block);
            assert!(state_root != 0, "FactRegistry: block not found");
            let proof = self
                .reconstruct_ints_sequence_list(proofs_concat.span(), proof_sizes_bytes.span());
            let result = verify_proof(account.to_words64(), state_root.to_words64(), proof.span());
            match result {
                Option::None => { panic!("FactRegistry: account not found"); },
                Option::Some(result) => {
                    let result_items = to_rlp_array(result);
                    let result_values = self.extract_list_values(result, result_items.span());
                    match option {
                        OptionsSet::CodeHash => {
                            let code_hash = *result_values.at(3);
                            self
                                .verified_account_code_hash
                                .write((account, block), code_hash.from_words64());
                        },
                        OptionsSet::Balance => {
                            let balance = *result_values.at(1);
                            self
                                .verified_account_balance
                                .write((account, block), balance.from_words64());
                        },
                        OptionsSet::Nonce => {
                            let nonce = *(*result_values.at(0)).values.at(0);
                            self.verified_account_nonce.write((account, block), nonce);
                        },
                        OptionsSet::StorageHash => {
                            let storage_hash = *result_values.at(2);
                            self
                                .verified_account_storage_hash
                                .write((account, block), storage_hash.from_words64());
                        },
                        OptionsSet::All => {
                            let nonce = *(*result_values.at(0)).values.at(0);
                            let balance = *result_values.at(1);
                            let storage_hash = *result_values.at(2);
                            let code_hash = *result_values.at(3);
                            self.verified_account_nonce.write((account, block), nonce);
                            self
                                .verified_account_balance
                                .write((account, block), balance.from_words64());
                            self
                                .verified_account_storage_hash
                                .write((account, block), storage_hash.from_words64());
                            self
                                .verified_account_code_hash
                                .write((account, block), code_hash.from_words64());
                        },
                    };
                }
            }
        }

        fn get_storage(
            ref self: ContractState,
            block: u64,
            account: starknet::EthAddress,
            slot: u256,
            proof_sizes_bytes: Array<usize>,
            proofs_concat: Array<u64>,
        ) -> Words64Sequence {
            let account_state_root = self.verified_account_storage_hash.read((account, block));
            assert!(account_state_root != 0, "FactRegistry: storage hash not found");

            let result = verify_proof(
                keccak_words64(slot.to_words64()),
                account_state_root.to_words64(),
                self
                    .reconstruct_ints_sequence_list(proofs_concat.span(), proof_sizes_bytes.span())
                    .span()
            );

            let slot_value = match result {
                Option::None => Words64Sequence { values: array![].span(), len_bytes: 0 },
                Option::Some(result) => { extract_element(result, 0) }
            };
            slot_value
        }

        fn get_storage_uint(
            ref self: ContractState,
            block: u64,
            account: starknet::EthAddress,
            slot: u256,
            proof_sizes_bytes: Array<usize>,
            proofs_concat: Array<u64>,
        ) -> u256 {
            let result = self.get_storage(block, account, slot, proof_sizes_bytes, proofs_concat);
            words64_to_int(result)
        }

        fn get_initialized(self: @ContractState) -> bool {
            self.initialized.read()
        }

        fn get_l1_headers_store_addr(self: @ContractState) -> ContractAddress {
            contract_address_const::<0>()
        }

        fn get_verified_account_storage_hash(
            self: @ContractState, account: starknet::EthAddress, block: u64
        ) -> u256 {
            self.verified_account_storage_hash.read((account, block))
        }

        fn get_verified_account_code_hash(
            self: @ContractState, account: starknet::EthAddress, block: u64
        ) -> u256 {
            self.verified_account_code_hash.read((account, block))
        }

        fn get_verified_account_balance(
            self: @ContractState, account: starknet::EthAddress, block: u64
        ) -> u256 {
            self.verified_account_balance.read((account, block))
        }

        fn get_verified_account_nonce(
            self: @ContractState, account: starknet::EthAddress, block: u64
        ) -> u64 {
            self.verified_account_nonce.read((account, block))
        }
    }

    #[generate_trait]
    impl Private of PrivateTrait {
        fn reconstruct_ints_sequence_list(
            self: @ContractState, sequence: Span<u64>, sizes_bytes: Span<usize>
        ) -> Array<Words64Sequence> {
            let bytes_len = sizes_bytes.len();
            let mut acc = array![];
            let mut offset = 0_usize;
            let mut current_index = 0;

            while (current_index < bytes_len) {
                let element_size_bytes = *sizes_bytes.at(current_index);
                let len_words = (element_size_bytes + 7) / 8;
                let current_element = self.concat_elements(sequence, offset, offset + len_words);

                acc
                    .append(
                        Words64Sequence {
                            values: current_element.span(), len_bytes: element_size_bytes
                        }
                    );
                offset += len_words;
                current_index += 1;
            };
            acc
        }

        fn concat_elements(
            self: @ContractState, elements: Span<u64>, start: usize, end: usize
        ) -> Array<u64> {
            let mut acc = array![];
            let mut i = start;

            while (i < end) {
                acc.append(*elements.at(i));
                i += 1;
            };
            acc
        }

        fn extract_list_values(
            self: @ContractState, words64: Words64Sequence, rlp_list: Span<RLPItem>
        ) -> Array<Words64Sequence> {
            let mut acc = array![];
            let list_len = rlp_list.len();
            let mut i = 0;
            while (i < list_len) {
                let current_element = *rlp_list.at(i);
                acc.append(extract_data(words64, current_element.position, current_element.length));
                i += 1;
            };
            acc
        }
    }
}
