use fossil::L1_headers_store::interface::IL1HeadersStoreDispatcherTrait;
use fossil::library::keccak256::keccak256;
use fossil::library::words64_utils::{words64_to_nibbles, Words64Trait};
use fossil::testing::proofs;
use fossil::testing::rlp;
use fossil::types::ProcessBlockOptions;
use snforge_std::start_cheat_caller_address;
use starknet::EthAddress;
use super::test_utils::{setup, OWNER, STARKNET_HANDLER};

#[test]
fn receive_from_l1_success_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let parent_hash: u256 = 0xfbacb363819451babc6e7596aa48af6c223e40e8b0ad975e372347df5d60ba0f;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash, block.number);

    assert_eq!(dsp.store.get_latest_l1_block_number(), block.number.try_into().unwrap());
    assert_eq!(dsp.store.get_latest_block_hash(), parent_hash);
}

#[test]
#[should_panic(expected: "L1HeaderStore: unauthorized caller")]
fn receive_from_l1_fail_unauthorized_sender() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let parent_hash: u256 = 0xfbacb363819451babc6e7596aa48af6c223e40e8b0ad975e372347df5d60ba0f;

    dsp.store.receive_from_l1(parent_hash, block.number);

    assert_eq!(dsp.store.get_latest_block_hash(), parent_hash);
}

#[test]
fn change_l1_messages_origin_success() {
    let dsp = setup();

    let new_origin: starknet::ContractAddress = 'NEW_L1_MESSAGES'.try_into().unwrap();
    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    dsp.store.change_l1_messages_origin(new_origin);
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn change_l1_messages_origin_fail_unauthorized_sender() {
    let dsp = setup();

    let new_origin: starknet::ContractAddress = 'NEW_L1_MESSAGES'.try_into().unwrap();

    dsp.store.change_l1_messages_origin(new_origin);
}

#[test]
fn test_set_latest_mmr_root_success() {
    let dsp = setup();

    let mmr_root = 200;

    start_cheat_caller_address(dsp.store.contract_address, STARKNET_HANDLER());
    dsp.store.set_latest_mmr_root(mmr_root);

    assert_eq!(dsp.store.get_mmr_root(), mmr_root);
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn test_set_latest_mmr_root_fail() {
    let dsp = setup();

    let mmr_root = 200;

    start_cheat_caller_address(dsp.store.contract_address, OWNER());
    dsp.store.set_latest_mmr_root(mmr_root);

    assert_eq!(dsp.store.get_mmr_root(), mmr_root);
}

#[test]
fn test_verify_mmr_inclusion() {
    let dsp = setup();

    let block_rlp = proofs::mmr::block_rlp_4();
    let proof = proofs::mmr::proof_4();

    let block_number: u64 = proof.element_index.try_into().unwrap();
    let result = dsp.store.verify_mmr_inclusion(block_number, proof.element_hash, proof, block_rlp);
    assert_eq!(result, Result::Ok(true));

    let state_root = dsp.store.get_block_state_root(block_number);
    assert_eq!(state_root, 0x2045bf4ea5561e88a4d0d9afbc316354e49fe892ac7e961a5e68f1f4b9561152);
}

#[test]
#[should_panic()]
fn test_verify_mmr_inclusion_fail() {
    let dsp = setup();

    let proof = proofs::mmr::proof_1();
    let block_rlp = proofs::mmr::block_rlp_3();
    let block_number: u64 = proof.element_index.try_into().unwrap();
    let result = dsp.store.verify_mmr_inclusion(block_number, proof.element_hash, proof, block_rlp);
    assert_eq!(result, Result::Ok(true));
}
