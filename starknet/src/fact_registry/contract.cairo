//! This Contract reads the state root for a specific block from the Headers Store.
//! Communicates with Ethereum to verify proof validity.

#[starknet::contract]
pub mod FactRegistry {
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************
    // Local imports.
    use fossil::L1_headers_store::interface::{
        IL1HeadersStore, IL1HeadersStoreDispatcher, IL1HeadersStoreDispatcherTrait
    };
    use fossil::fact_registry::interface::IFactRegistry;
    use fossil::library::{
        trie_proof::verify_proof, words64_utils::{Words64Trait, words64_to_int},
        rlp_utils::{to_rlp_array, extract_data, extract_element}, keccak_utils::keccak_words64
    };
    use fossil::types::{OptionsSet, Words64Sequence, RLPItem};
    // Core lib imports 
    use starknet::{ContractAddress, EthAddress, contract_address_const};
    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        initialized: bool,
        l1_headers_store: IL1HeadersStoreDispatcher,
        verified_account_storage_hash: LegacyMap::<(EthAddress, u64), u256>,
        verified_account_code_hash: LegacyMap::<(EthAddress, u64), u256>,
        verified_account_balance: LegacyMap::<(EthAddress, u64), u256>,
        verified_account_nonce: LegacyMap::<(EthAddress, u64), u64>,
    }

    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    // Implementation of IFactRegistry interface
    #[abi(embed_v0)]
    impl FactRegistry of IFactRegistry<ContractState> {
        /// Initialize the contract.
        /// 
        /// # Arguments
        /// * `l1_headers_store_addr` - The address of L1 Header Store contract.
        fn initialize(ref self: ContractState, l1_headers_store_addr: starknet::ContractAddress) {
            assert!(self.initialized.read() == false, "FactRegistry: already initialized");
            self.initialized.write(true);
            self
                .l1_headers_store
                .write(IL1HeadersStoreDispatcher { contract_address: l1_headers_store_addr });
        }

        /// Verifies the account information for a given Ethereum address  at a given block using a provided state root proof and stores the verified value.
        ///
        /// # Arguments
        /// * `option` - An enum specifying which part of the account state to verify and store.
        /// * `account` - The Ethereum address of the account to verify.
        /// * `block` - The block number at which to verify the account state.
        /// * `proof_sizes_bytes` - An array containing the sizes of the proofs in bytes.
        /// * `proofs_concat` - An array containing the concatenated proofs.
        ///
        /// # Panics
        /// - The state root for the given block is not found.
        /// - The account is not found in the proof verification.
        /// 
        /// This function takes an account address, block number, proof sizes, and concatenated proofs to verify the account state.
        /// It retrieves the state root for the given block, reconstructs the proof, and verifies it.
        /// Depending on the `option` provided, it stores the corresponding verified values (code hash, balance, nonce, storage hash)
        /// in the contract state.
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

        /// Retrieves the storage hash value at a given slot for an Ethereum account and block number given a state root proof.
        ///
        /// # Arguments
        /// * `block` - The block number at which to fetch the storage value.
        /// * `account` - The Ethereum address of the account whose storage is being queried.
        /// * `slot` - The storage slot whose value is being retrieved.
        /// * `proof_sizes_bytes` - An array of sizes for the proof elements in bytes.
        /// * `proofs_concat` - An array containing the concatenated proofs for storage verification.
        ///
        /// # Returns
        /// * `Words64Sequence` - A sequence of 64-bit words containing the storage value at the given slot, or empty if the proof is invalid.
        ///
        /// # Panics
        /// Panics if the storage hash for the given account and block is not found.
        /// 
        /// This function is responsible for retrieving the storage value at a specific slot for an Ethereum account and block number
        /// using StarkNet state root proofs. It verifies the proof and returns the storage value if the proof is valid.
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
                Option::Some(result) => result
            };
            slot_value
        }

        /// Retrieves the storage value at a given slot for an Ethereum account and block number as an unsigned 256-bit integer.
        ///
        /// # Arguments
        /// - `block`: The block number for which the storage value is to be retrieved.
        /// - `account`: The Ethereum address of the account.
        /// - `slot`: The storage slot for which the value is to be retrieved.
        /// - `proof_sizes_bytes`: An array containing the sizes (in bytes) of the individual proofs in the concatenated proof.
        /// - `proofs_concat`: An array containing the concatenated proof data.
        ///
        /// This function is a wrapper around `get_storage` that specifically returns the storage value as an unsigned 256-bit integer.
        /// It is useful when working with storage values that represent unsigned integers, such as balances or other numerical values.
        ///
        /// Returns:
        /// * `u256` - The storage value at the given slot.
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

        /// Checks if the contract state has been initialized .
        ///
        /// # Returns
        /// * `bool` - A boolean indicating whether the contract state has been initialized.
        fn get_initialized(self: @ContractState) -> bool {
            self.initialized.read()
        }

        /// Retrieves the L1 Header Store address.
        ///
        /// # Returns
        /// * `ContractAddress` - The L1 Header Store address.
        fn get_l1_headers_store_addr(self: @ContractState) -> ContractAddress {
            self.l1_headers_store.read().contract_address
        }

        /// Retrieves the verified storage hash for a given Ethereum account and block number.
        ///
        /// # Arguments
        /// * `account`: The Ethereum address of the account.
        /// * `block`: The block number for which the storage hash is to be retrieved.
        ///
        /// Returns:
        /// * `u256` - The verified storage hash for the given account and block number.
        fn get_verified_account_storage_hash(
            self: @ContractState, account: starknet::EthAddress, block: u64
        ) -> u256 {
            self.verified_account_storage_hash.read((account, block))
        }

        /// Retrieves the verified code hash for a given Ethereum account and block number.
        ///
        /// # Arguments
        /// - `account`: The Ethereum address of the account.
        /// - `block`: The block number for which the code hash is to be retrieved.
        ///
        /// Returns:
        /// * `u256` - The verified code hash for the given account and block number.
        fn get_verified_account_code_hash(
            self: @ContractState, account: starknet::EthAddress, block: u64
        ) -> u256 {
            self.verified_account_code_hash.read((account, block))
        }

        /// Retrieves the verified account balance for a given Ethereum account and block number.
        ///
        /// # Arguments
        /// - `account`: The Ethereum address of the account.
        /// - `block`: The block number for which the code hash is to be retrieved.
        ///
        /// Returns:
        /// * `u256` - The verified account balance for the given account and block number.
        fn get_verified_account_balance(
            self: @ContractState, account: starknet::EthAddress, block: u64
        ) -> u256 {
            self.verified_account_balance.read((account, block))
        }

        /// Retrieves the verified account nonce for a given Ethereum account and block number.
        ///
        /// # Arguments
        /// - `account`: The Ethereum address of the account.
        /// - `block`: The block number for which the code hash is to be retrieved.
        ///
        /// Returns:
        /// * `u256` - The verified account nonce for the given account and block number.
        fn get_verified_account_nonce(
            self: @ContractState, account: starknet::EthAddress, block: u64
        ) -> u64 {
            self.verified_account_nonce.read((account, block))
        }
    }

    // *************************************************************************
    //                          INTERNAL FUNCTIONS
    // *************************************************************************
    #[generate_trait]
    impl Private of PrivateTrait {
        /// Reconstructs a list of integer sequences from a concatenated byte sequence and an array of byte sizes.
        ///
        /// # Arguments
        /// * `sequence`: A span of 64-bit words representing the concatenated byte sequence.
        /// * `sizes_bytes`: A span of sizes (in bytes) for each integer sequence in the concatenated byte sequence.
        ///
        /// Returns:
        /// * `Array<Words64Sequence>` - The reconstructed sequences.
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

        /// Concatenates a slice of elements from a span of 64-bit words.
        ///
        /// # Argument
        /// * `elements`: A span of 64-bit words representing the concatenated byte sequence.
        /// * `start`: The starting index of the slice to extract.
        /// * `end`: The ending index (exclusive) of the slice to extract.
        ///
        /// Returns:
        /// * ` Array<u64>` - An array of words representing the extracted slice.
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

        /// Extracts a list of values from an RLP encoded list.
        ///
        /// # Arguments
        /// * `words64` - A sequence of 64-bit words representing the data.
        /// * `rlp_list` - A span of RLP items representing the list to be extracted.
        ///
        /// # Returns
        /// * ` Array<Words64Sequence>` - each values extracted from the RLP list.
        ///
        /// This function iterates through the provided `rlp_list` and extracts data from the `words64`
        /// sequence based on the position and length of each `RLPItem` in the list. The extracted
        /// data is appended to an array and returned.
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
