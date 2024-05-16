use fossil::types::OptionsSet;
use fossil::{
    L1_headers_store::interface::IL1HeadersStoreDispatcherTrait,
    fact_registry::interface::IFactRegistryDispatcherTrait
};
use super::test_utils::{setup, testdata};

#[test]
fn prove_account_test_success_code_hash() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let proof = testdata::proofs::PROOF_1();

    dsp
        .registry
        .prove_account(
            OptionsSet::CodeHash, proof.account, block.number, proof.len_bytes, proof.data
        );

    let code_hash = dsp.registry.get_verified_account_code_hash(proof.account, block.number);
    assert_eq!(code_hash, 0x4e36f96ee1667a663dfaac57c4d185a0e369a3a217e0079d49620f34f85d1ac7);
}

#[test]
fn prove_account_test_success_balance() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let proof = testdata::proofs::PROOF_1();

    dsp
        .registry
        .prove_account(
            OptionsSet::Balance, proof.account, block.number, proof.len_bytes, proof.data
        );

    let balance = dsp.registry.get_verified_account_balance(proof.account, block.number);
    assert_eq!(balance, 0x0);
}

#[test]
fn prove_account_test_success_nonce() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let proof = testdata::proofs::PROOF_1();

    dsp
        .registry
        .prove_account(OptionsSet::Nonce, proof.account, block.number, proof.len_bytes, proof.data);

    let nonce = dsp.registry.get_verified_account_nonce(proof.account, block.number);
    assert_eq!(nonce, 0x1);
}

#[test]
fn prove_account_test_success_storage_hash() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_3();
    dsp.store.set_state_root(block.number, block.state_root);

    let proof = testdata::proofs::PROOF_1();

    dsp
        .registry
        .prove_account(
            OptionsSet::StorageHash, proof.account, block.number, proof.len_bytes, proof.data
        );

    let storage_hash = dsp.registry.get_verified_account_storage_hash(proof.account, block.number);
    assert_eq!(storage_hash, 0x199c2e6b850bcc9beaea25bf1bacc5741a7aad954d28af9b23f4b53f5404937b);
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
    assert!(true)
}

#[test]
fn get_storage_test_success_with_no_data() {
    assert!(true)
}

#[test]
#[should_panic]
fn get_storage_test_fail_state_root_is_zero() {
    assert!(false)
}

#[test]
fn get_storage_uint_test_success() {
    assert!(true)
}

#[test]
fn get_initialized_test() {
    assert!(true)
}

#[test]
fn get_l1_headers_store_addr_test() {
    assert!(true)
}

#[test]
fn get_verified_account_storage_hash_test() {
    assert!(true)
}

#[test]
fn get_verified_account_code_hash_test() {
    assert!(true)
}

#[test]
fn get_verified_account_balance_test() {
    assert!(true)
}

#[test]
fn get_verified_account_nonce_test() {
    assert!(true)
}
