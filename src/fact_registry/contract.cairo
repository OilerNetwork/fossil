#[starknet::contract]
mod factregistry {
    use fossil::L1_headers_store::interface::{
        IL1HeadersStore, IL1HeadersStoreDispatcher, IL1HeadersStoreDispatcherTrait
    };
    use fossil::fact_registry::interface::IFactRegistry;
    use fossil::library::trie_proof::verify_proof;
    use fossil::types::{OptionsSet, StorageSlot};
    use starknet::{ContractAddress, EthAddress, contract_address_const};

    #[storage]
    struct Storage {
        initialized: bool,
        l1_headers_store: IL1HeadersStoreDispatcher,
        verified_account_storage_hash: LegacyMap::<(EthAddress, u64), u256>,
        verified_account_code_hash: LegacyMap::<(EthAddress, u64), u256>,
        verified_account_balance: LegacyMap::<(EthAddress, u64), u256>,
        verified_account_nonce: LegacyMap::<(EthAddress, u64), felt252>,
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
            proof_sizes_bytes: Array<u16>,
            proof_sizes_words: Array<u8>,
            proofs_concat: Array<u64>,
        ) {
            let state_root = self.l1_headers_store.read().get_state_root(block);
            assert!(state_root != 0, "FactRegistry: block not found");
        // let result = verify_proof(account, state_root, proofs_concat.span());
        }

        fn get_storage(
            ref self: ContractState,
            block: u64,
            account: starknet::EthAddress,
            slot: StorageSlot,
            proof_sizes_bytes: Array<felt252>,
            proof_sizes_words: Array<felt252>,
            proofs_concat: Array<felt252>,
        ) -> (usize, Array<felt252>) {
            (0, array![])
        }

        fn get_storage_uint(
            ref self: ContractState,
            block: u64,
            account: starknet::EthAddress,
            slot: StorageSlot,
            proof_sizes_bytes: Array<felt252>,
            proof_sizes_words: Array<felt252>,
            proofs_concat: Array<felt252>,
        ) -> u256 {
            0
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
        ) -> felt252 {
            self.verified_account_nonce.read((account, block))
        }
    }
}
