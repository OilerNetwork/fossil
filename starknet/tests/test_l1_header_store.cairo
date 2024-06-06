use fossil::L1_headers_store::interface::IL1HeadersStoreDispatcherTrait;
use fossil::library::words64_utils::{words64_to_nibbles, Words64Trait};
use fossil::testing::proofs;
use fossil::testing::rlp;
use fossil::types::ProcessBlockOptions;
use snforge_std::start_cheat_caller_address;
use starknet::EthAddress;
use super::test_utils::{setup, OWNER};


#[test]
fn receive_from_l1_success_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let parent_hash: u256 = 0xfbacb363819451babc6e7596aa48af6c223e40e8b0ad975e372347df5d60ba0f;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash, block.number);

    assert_eq!(dsp.store.get_parent_hash(block.number), parent_hash);
}

#[test]
fn test_store_state_root() {
    let dsp = setup();

    let state_root: u256 = 0x1e7f7;
    let block = 19882;

    start_cheat_caller_address(dsp.store.contract_address, OWNER());
    dsp.store.store_state_root(block, state_root);

    assert_eq!(dsp.store.get_state_root(block), state_root);
}

#[test]
fn test_store_many_state_root() {
    let dsp = setup();

    let state_roots: Array<u256> = array![
        0x1e7f7, 0x3e497, 0x4e7f7, 0x5e7f7, 0x6e7f7, 0x7e7f7, 0x8e7f7, 0x9e7f7, 0x10e7f7, 0x11e7f7
    ];
    let start_block = 1;
    let end_block = 10;

    start_cheat_caller_address(dsp.store.contract_address, OWNER());
    dsp.store.store_many_state_roots(start_block, end_block, state_roots);

    assert_eq!(dsp.store.get_state_root(1), 0x1e7f7);
    assert_eq!(dsp.store.get_state_root(5), 0x6e7f7);
    assert_eq!(dsp.store.get_state_root(10), 0x11e7f7);
}

#[test]
fn get_initialized_test() {
    assert!(true)
}

#[test]
fn get_parent_hash_test() {
    assert!(true)
}

#[test]
fn get_latest_l1_block_hash() {
    assert!(true)
}

#[test]
fn get_state_root_test() {
    assert!(true)
}

#[test]
fn get_transactions_root_test() {
    assert!(true)
}

#[test]
fn get_receipts_root_test() {
    assert!(true)
}

#[test]
fn get_uncles_hash_test() {
    assert!(true)
}

#[test]
fn get_beneficiary_test() {
    assert!(true)
}

#[test]
fn get_difficulty_test() {
    assert!(true)
}

#[test]
fn get_base_fee_test() {
    assert!(true)
}

#[test]
fn get_timestamp_test() {
    assert!(true)
}

#[test]
fn get_gas_used_test() {
    assert!(true)
}
