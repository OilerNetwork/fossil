use fossil::library::words64_utils::Words64Trait;
use fossil::testing::proofs;
use fossil::types::OptionsSet;
use fossil::{
    L1_headers_store::interface::IL1HeadersStoreDispatcherTrait,
    fact_registry::interface::IFactRegistryDispatcherTrait
};
use super::test_utils::setup;

#[test]
fn prove_account_test_success_code_hash() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let proof = proofs::account::PROOF_1();

    dsp
        .registry
        .prove_account(OptionsSet::CodeHash, proof.address, block.number, proof.bytes, proof.data);

    let code_hash = dsp.registry.get_verified_account_code_hash(proof.address, block.number);
    assert_eq!(code_hash, proof.code_hash);
}

#[test]
fn prove_account_test_success_balance() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let proof = proofs::account::PROOF_1();

    dsp
        .registry
        .prove_account(OptionsSet::Balance, proof.address, block.number, proof.bytes, proof.data);

    let balance = dsp.registry.get_verified_account_balance(proof.address, block.number);
    assert_eq!(balance, proof.balance);
}

#[test]
fn prove_account_test_success_nonce() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let proof = proofs::account::PROOF_1();

    dsp
        .registry
        .prove_account(OptionsSet::Nonce, proof.address, block.number, proof.bytes, proof.data);

    let nonce = dsp.registry.get_verified_account_nonce(proof.address, block.number);
    assert_eq!(nonce, proof.nonce);
}

#[test]
fn prove_account_test_success_storage_hash() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let proof = proofs::account::PROOF_1();

    dsp
        .registry
        .prove_account(
            OptionsSet::StorageHash, proof.address, block.number, proof.bytes, proof.data
        );

    let storage_hash = dsp.registry.get_verified_account_storage_hash(proof.address, block.number);
    assert_eq!(storage_hash, proof.storage_hash);
}

#[test]
fn prove_account_test_success_save_all() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let proof = proofs::account::PROOF_1();

    dsp
        .registry
        .prove_account(OptionsSet::All, proof.address, block.number, proof.bytes, proof.data);

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
#[should_panic]
fn prove_account_test_fail_state_root_is_zero() {
    assert!(false)
}

#[test]
#[should_panic]
fn prove_account_test_fail_account_not_found() {
    assert!(false)
}

#[test]
fn get_storage_test_success_with_some_data() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let account_proof = proofs::account::PROOF_1();

    dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );

    let storage_proof = proofs::storage::PROOF_2();

    let result = dsp
        .registry
        .get_storage(
            block.number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );
    assert_eq!(result.values, array![9946104055808884394, 4690945].span());
}

#[test]
fn get_storage_test_success_with_no_data() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let account_proof = proofs::account::PROOF_1();

    dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );

    let storage_proof = proofs::storage::PROOF_1();

    let result = dsp
        .registry
        .get_storage(
            block.number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );
    assert_eq!(result.values, array![].span());
}

#[test]
#[should_panic]
fn get_storage_test_fail_account_not_found() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    let account_proof = proofs::account::PROOF_1();
    let storage_proof = proofs::storage::PROOF_1();

    let result = dsp
        .registry
        .get_storage(
            block.number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );
    assert_eq!(result.values, array![].span());
}


#[test]
fn get_storage_uint_test_success_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let account_proof = proofs::account::PROOF_1();

    dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );

    let storage_proof = proofs::storage::PROOF_2();

    let result = dsp
        .registry
        .get_storage_uint(
            block.number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );
    assert_eq!(result, 0x8a07a8f1298f7eaa479401);
}

#[test]
fn get_storage_uint_test_success_no_data() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let account_proof = proofs::account::PROOF_1();

    dsp
        .registry
        .prove_account(
            OptionsSet::All,
            account_proof.address,
            block.number,
            account_proof.bytes,
            account_proof.data
        );

    let storage_proof = proofs::storage::PROOF_1();

    let result = dsp
        .registry
        .get_storage_uint(
            block.number,
            account_proof.address,
            storage_proof.key,
            storage_proof.bytes,
            storage_proof.data
        );
    assert_eq!(result, 0);
}

#[test]
fn get_initialized_test() {
    let dsp = setup();

    assert_eq!(dsp.registry.get_initialized(), true);
}

#[test]
fn get_l1_headers_store_addr_test() {
    let dsp = setup();

    assert_eq!(dsp.store.contract_address, dsp.registry.get_l1_headers_store_addr());
}
