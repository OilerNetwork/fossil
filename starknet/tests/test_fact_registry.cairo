use fossil::library::words64_utils::Words64Trait;
use fossil::testing::proofs;
use fossil::{
    L1_headers_store::interface::IL1HeadersStoreDispatcherTrait,
    fact_registry::interface::IFactRegistryDispatcherTrait
};
use snforge_std::start_cheat_caller_address;
use super::test_utils::{setup, OWNER, STARKNET_HANDLER};

#[test]
fn prove_all_test_success_mainnet_weth() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_mainnet_weth();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    dsp.store.store_state_root(block.number, block.state_root);

    let account_proof = proofs::account::PROOF_mainnet_weth();

    let _output = dsp
        .registry
        .prove_account(
            account_proof.address, block.number, account_proof.bytes, account_proof.data
        );

    let storage_hash = dsp
        .registry
        .get_verified_account_storage_hash(account_proof.address, block.number);
    assert_eq!(storage_hash, account_proof.storage_hash);

    let code_hash = dsp
        .registry
        .get_verified_account_code_hash(account_proof.address, block.number);
    assert_eq!(code_hash, account_proof.code_hash);

    let balance = dsp.registry.get_verified_account_balance(account_proof.address, block.number);
    assert_eq!(balance, account_proof.balance);

    let nonce = dsp.registry.get_verified_account_nonce(account_proof.address, block.number);
    assert_eq!(nonce, account_proof.nonce);

    let storage_proof = proofs::storage::PROOF_mainnet_weth();

    let (proved, value, result) = dsp
        .registry
        .prove_storage(
            block.number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );

    let storage_result = dsp
        .registry
        .get_storage(block.number, account_proof.address, storage_proof.key);
    assert_eq!((proved, value), storage_result);
    assert_eq!(result, 'Proof verified successfully');
}

#[test]
fn prove_account_test_success_save_all() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    dsp.store.store_state_root(block.number, block.state_root);

    let proof = proofs::account::PROOF_1();

    let _output = dsp.registry.prove_account(proof.address, block.number, proof.bytes, proof.data);

    let storage_hash = dsp.registry.get_verified_account_storage_hash(proof.address, block.number);
    assert_eq!(storage_hash, proof.storage_hash);

    let code_hash = dsp.registry.get_verified_account_code_hash(proof.address, block.number);
    assert_eq!(code_hash, proof.code_hash);

    let balance = dsp.registry.get_verified_account_balance(proof.address, block.number);
    assert_eq!(balance, proof.balance);

    let nonce = dsp.registry.get_verified_account_nonce(proof.address, block.number);
    assert_eq!(nonce, proof.nonce);
}

#[test]
#[should_panic(expected: "FactRegistry: block state root not found")]
fn prove_account_test_fail_state_root_not_found() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();

    let proof = proofs::account::PROOF_1();

    let _output = dsp.registry.prove_account(proof.address, block.number, proof.bytes, proof.data);
}

#[test]
fn prove_storage_test_success_with_some_data() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    dsp.store.store_state_root(block.number, block.state_root);

    let account_proof = proofs::account::PROOF_1();

    let _output = dsp
        .registry
        .prove_account(
            account_proof.address, block.number, account_proof.bytes, account_proof.data
        );

    let storage_proof = proofs::storage::PROOF_2();

    let (proved, value, _) = dsp
        .registry
        .prove_storage(
            block.number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );
    let storage_result = dsp
        .registry
        .get_storage(block.number, account_proof.address, storage_proof.key);
    assert_eq!((proved, value), storage_result);
}

#[test]
#[should_panic(expected: "FactRegistry: account state root not found")]
fn prove_storage_test_fail_state_root_not_found() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    dsp.store.store_state_root(block.number, block.state_root);

    let account_proof = proofs::account::PROOF_1();

    let storage_proof = proofs::storage::PROOF_2();

    let _ = dsp
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

    assert!(result == (false, 0));
}

#[test]
fn get_storage_test_success_with_no_data() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    dsp.store.store_state_root(block.number, block.state_root);

    let account_proof = proofs::account::PROOF_1();

    let _output = dsp
        .registry
        .prove_account(
            account_proof.address, block.number, account_proof.bytes, account_proof.data
        );

    let storage_proof = proofs::storage::PROOF_1();

    let result = dsp
        .registry
        .prove_storage(
            block.number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );
    assert!(result == (true, 0, 'Empty slot'));
}

#[test]
#[should_panic(expected: "FactRegistry: account state root not found")]
fn prove_storage_test_state_root_not_found() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    let account_proof = proofs::account::PROOF_1();
    let storage_proof = proofs::storage::PROOF_1();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    dsp.store.store_state_root(block.number, block.state_root);

    let _ = dsp
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
fn get_l1_headers_store_addr_test() {
    let dsp = setup();

    assert_eq!(dsp.store.contract_address, dsp.registry.get_l1_headers_store_addr());
}

#[test]
#[should_panic(expected: "invalid children length")]
fn prove_account_test_error_invalid_children_length() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    dsp.store.store_state_root(block.number, block.state_root);

    let proof = proofs::account::PROOF_invalid_children_length();

    dsp.registry.prove_account(proof.address, block.number, proof.bytes, proof.data);
}

#[test]
#[should_panic(expected: "Root hash mismatch")]
fn prove_account_test_error_root_hash_mismatch() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_4();

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    dsp.store.store_state_root(block.number, block.state_root);

    let proof = proofs::account::PROOF_4();

    let output = dsp.registry.prove_account(proof.address, block.number, proof.bytes, proof.data);
    assert_eq!(output, (false, 'Root hash mismatch'));
}
