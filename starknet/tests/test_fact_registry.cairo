use fossil::library::words64_utils::Words64Trait;
use fossil::testing::proofs;
use fossil::types::OptionsSet;
use fossil::{
    L1_headers_store::interface::IL1HeadersStoreDispatcherTrait,
    fact_registry::interface::IFactRegistryDispatcherTrait
};
use snforge_std::start_cheat_caller_address;
use super::test_utils::{setup, OWNER, STARKNET_HANDLER};

#[test]
fn prove_account_test_success_code_hash() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let mmr_proof = proofs::mmr::proof_anvil();
    let block_rlp = proofs::mmr::block_rlp_anvil();
    let block_number: u64 = mmr_proof.element_index.try_into().unwrap();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    let result = dsp
        .store
        .verify_mmr_inclusion(block_number, mmr_proof.element_hash, mmr_proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block_number);
    assert_eq!(state_root, block.state_root);

    let account_proof = proofs::account::PROOF_anvil();
    let result = dsp
        .registry
        .prove_account(
            OptionsSet::CodeHash,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );

    assert_eq!(result, Result::Ok(true));

    let code_hash = dsp
        .registry
        .get_verified_account_code_hash(account_proof.address, block.number);
    println!("      code_hash: {:?}", code_hash);
    println!("proof.code_hash: {:?}", account_proof.code_hash);
// assert_eq!(code_hash, proof.code_hash);
}

#[test]
fn prove_account_test_success_balance() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let mmr_proof = proofs::mmr::proof_anvil();
    let block_rlp = proofs::mmr::block_rlp_anvil();
    let block_number: u64 = mmr_proof.element_index.try_into().unwrap();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    let result = dsp
        .store
        .verify_mmr_inclusion(block_number, mmr_proof.element_hash, mmr_proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block_number);
    assert_eq!(state_root, block.state_root);

    let account_proof = proofs::account::PROOF_anvil();
    let result = dsp
        .registry
        .prove_account(
            OptionsSet::Balance,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );
    assert_eq!(result, Result::Ok(true));

    let balance = dsp.registry.get_verified_account_balance(account_proof.address, block.number);
    assert_eq!(balance, account_proof.balance);
}

#[test]
fn prove_account_test_success_nonce() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let mmr_proof = proofs::mmr::proof_anvil();
    let block_rlp = proofs::mmr::block_rlp_anvil();
    let block_number: u64 = mmr_proof.element_index.try_into().unwrap();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    let result = dsp
        .store
        .verify_mmr_inclusion(block_number, mmr_proof.element_hash, mmr_proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block_number);
    assert_eq!(state_root, block.state_root);

    let account_proof = proofs::account::PROOF_anvil();
    let result = dsp
        .registry
        .prove_account(
            OptionsSet::Nonce,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );
    assert_eq!(result, Result::Ok(true));

    let nonce = dsp.registry.get_verified_account_nonce(account_proof.address, block.number);
    assert_eq!(nonce, account_proof.nonce);
}

#[test]
fn prove_account_test_success_storage_hash() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let mmr_proof = proofs::mmr::proof_anvil();
    let block_rlp = proofs::mmr::block_rlp_anvil();
    let block_number: u64 = mmr_proof.element_index.try_into().unwrap();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    let result = dsp
        .store
        .verify_mmr_inclusion(block_number, mmr_proof.element_hash, mmr_proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block_number);
    assert_eq!(state_root, block.state_root);

    let account_proof = proofs::account::PROOF_anvil();
    let result = dsp
        .registry
        .prove_account(
            OptionsSet::StorageHash,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );
    assert_eq!(result, Result::Ok(true));

    let storage_hash = dsp
        .registry
        .get_verified_account_storage_hash(account_proof.address, block.number);
    assert_eq!(storage_hash, account_proof.storage_hash);
}

#[test]
fn prove_account_test_success_save_all() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let mmr_proof = proofs::mmr::proof_anvil();
    let block_rlp = proofs::mmr::block_rlp_anvil();
    let block_number: u64 = mmr_proof.element_index.try_into().unwrap();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    let result = dsp
        .store
        .verify_mmr_inclusion(block_number, mmr_proof.element_hash, mmr_proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block_number);
    assert_eq!(state_root, block.state_root);

    let account_proof = proofs::account::PROOF_anvil();
    let result = dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );
    assert_eq!(result, Result::Ok(true));

    let storage_hash = dsp
        .registry
        .get_verified_account_storage_hash(account_proof.address, block.number);
    assert_eq!(storage_hash, account_proof.storage_hash);

    let _code_hash = dsp
        .registry
        .get_verified_account_code_hash(account_proof.address, block.number);
    // assert_eq!(code_hash, proof.code_hash);

    let balance = dsp.registry.get_verified_account_balance(account_proof.address, block.number);
    assert_eq!(balance, account_proof.balance);

    let nonce = dsp.registry.get_verified_account_nonce(account_proof.address, block.number);
    assert_eq!(nonce, account_proof.nonce);
}

#[test]
#[should_panic(expected: "FactRegistry: block state root not found")]
fn prove_account_test_fail_state_root_not_found() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();

    let account_proof = proofs::account::PROOF_1();

    let _output = dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );
}

#[test]
fn prove_storage_test_success_with_some_data() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let mmr_proof = proofs::mmr::proof_anvil();
    let block_rlp = proofs::mmr::block_rlp_anvil();
    let block_number: u64 = mmr_proof.element_index.try_into().unwrap();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    let result = dsp
        .store
        .verify_mmr_inclusion(block_number, mmr_proof.element_hash, mmr_proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block_number);
    assert_eq!(state_root, block.state_root);

    let account_proof = proofs::account::PROOF_anvil();
    let result = dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );
    assert_eq!(result, Result::Ok(true));

    let storage_proof = proofs::storage::PROOF_anvil();

    let result = dsp
        .registry
        .prove_storage(
            block_number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );

    let storage = dsp.registry.get_storage(block.number, account_proof.address, storage_proof.key);

    assert_eq!(result.unwrap(), storage.unwrap());
}

#[test]
#[should_panic(expected: "FactRegistry: block state root not found")]
fn prove_storage_test_fail_state_root_not_found() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let account_proof = proofs::account::PROOF_anvil();
    let storage_proof = proofs::storage::PROOF_anvil();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());

    let _result = dsp
        .registry
        .prove_storage(
            block.number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );
}

#[test]
fn test_get_storage_not_verified() {
    let dsp = setup();

    let result = dsp.registry.get_storage(0, 0_u256.into(), 0);

    assert!(result == Option::None);
}

#[test]
fn get_storage_test_success_with_no_data() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let mmr_proof = proofs::mmr::proof_anvil();
    let block_rlp = proofs::mmr::block_rlp_anvil();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    let result = dsp
        .store
        .verify_mmr_inclusion(block.number, mmr_proof.element_hash, mmr_proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block.number);
    assert_eq!(state_root, block.state_root);

    let account_proof = proofs::account::PROOF_anvil();
    let result = dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );
    assert_eq!(result, Result::Ok(true));

    let storage_proof = proofs::storage::PROOF_anvil_2();

    let result = dsp
        .registry
        .prove_storage(
            block.number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );

    println!("Result 2: {:?}", result);
    println!("Result is None: {:?}", 'Result is None');
// assert!(result == Result::Err('Result is None'));
}

#[test]
#[should_panic(expected: "FactRegistry: block state root not found")]
fn prove_storage_test_state_root_not_found() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let mmr_proof = proofs::mmr::proof_anvil();
    let block_rlp = proofs::mmr::block_rlp_anvil();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    let result = dsp
        .store
        .verify_mmr_inclusion(block.number, mmr_proof.element_hash, mmr_proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block.number);
    assert_eq!(state_root, block.state_root);

    let account_proof = proofs::account::PROOF_anvil();
    let result = dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );
    assert_eq!(result, Result::Ok(true));
    let storage_proof = proofs::storage::PROOF_1();

    let _result = dsp
        .registry
        .prove_storage(
            1, account_proof.address, storage_proof.key, storage_proof.bytes, storage_proof.data
        );
}

#[test]
fn get_l1_headers_store_addr_test() {
    let dsp = setup();

    assert_eq!(dsp.store.contract_address, dsp.registry.get_l1_headers_store_addr());
}


#[test]
fn prove_account_test_error_invalid_children_length() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let mmr_proof = proofs::mmr::proof_anvil();
    let block_rlp = proofs::mmr::block_rlp_anvil();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    let result = dsp
        .store
        .verify_mmr_inclusion(block.number, mmr_proof.element_hash, mmr_proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block.number);
    assert_eq!(state_root, block.state_root);

    let account_proof = proofs::account::PROOF_invalid_children_length();
    let result = dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );
    assert_eq!(result.unwrap_err(), 'invalid children length');
}

#[test]
fn prove_account_test_error_root_hash_mismatch() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_anvil();
    let mmr_proof = proofs::mmr::proof_anvil();
    let block_rlp = proofs::mmr::block_rlp_anvil();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    let result = dsp
        .store
        .verify_mmr_inclusion(block.number, mmr_proof.element_hash, mmr_proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block.number);
    assert_eq!(state_root, block.state_root);

    let account_proof = proofs::account::PROOF_4();
    let result = dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );
    assert_eq!(result.unwrap_err(), 'Root hash mismatch');
}
