use fossil::L1_headers_store::interface::IL1HeadersStoreDispatcherTrait;
use fossil::library::blockheader_rlp_extractor::{
    decode_parent_hash, decode_uncle_hash, decode_beneficiary, decode_state_root,
    decode_transactions_root, decode_receipts_root, decode_difficulty, decode_base_fee,
    decode_timestamp, decode_gas_used
};
use fossil::library::words64_utils::{
    split_u256_to_u64_array_no_span, words64_to_nibbles, Words64Trait
};
use fossil::testing::proofs;
use fossil::testing::rlp;
use fossil::types::ProcessBlockOptions;
use fossil::types::Words64Sequence;
use snforge_std::start_cheat_caller_address;
use starknet::EthAddress;
use super::test_utils::setup;


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
#[should_panic]
fn receive_from_l1_fail_wrong_caller_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let parent_hash: u256 = 0xfbacb363819451babc6e7596aa48af6c223e40e8b0ad975e372347df5d60ba0f;

    dsp.store.receive_from_l1(parent_hash, block.number);
}

#[test]
fn process_block_success_uncle_hash_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let (rlp, len) = rlp::RLP_0();
    let parent_hash_block_next: u256 =
        0x8407da492b7df20d2fe034a942a7c480c34eef978fe8b91ae98fcea4f3767125;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash_block_next, block.number + 1);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::UncleHash,
            block.number,
            len, // block_header_rlp_bytes_len: usize,
            rlp // block_header_rlp: Array<u64>,
        );

    let uncle_hash: u256 = dsp.store.get_uncles_hash(block.number); // u256
    println!("uncle_hash: {:?}", uncle_hash);
// assert_eq!(uncle_hash, data); // TODO
}

#[test]
fn process_block_success_beneficiary_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let (rlp, len) = rlp::RLP_0();
    let parent_hash_block_next: u256 =
        0x8407da492b7df20d2fe034a942a7c480c34eef978fe8b91ae98fcea4f3767125;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash_block_next, block.number + 1);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::Beneficiary,
            block.number,
            len, // block_header_rlp_bytes_len: usize ,
            rlp // block_header_rlp: Array<u64>,
        );

    let beneficiary: EthAddress = dsp.store.get_beneficiary(block.number);
    println!("beneficiary: {:?}", beneficiary);
// assert_eq!(beneficiary, data); TODO 
}

#[test]
fn process_block_success_state_root_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let (rlp, len) = rlp::RLP_0();
    let parent_hash_block_next: u256 =
        0x8407da492b7df20d2fe034a942a7c480c34eef978fe8b91ae98fcea4f3767125;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash_block_next, block.number + 1);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::StateRoot,
            block.number,
            len, // block_header_rlp_bytes_len: usize ,
            rlp // block_header_rlp: Array<u64>,
        );

    let state_root: u256 = dsp.store.get_state_root(block.number);
    println!("state root: {:?}", state_root);
//     assert_eq!(state_root, data); TODO 
}

#[test]
fn process_block_success_transactions_root_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let (rlp, len) = rlp::RLP_0();
    let parent_hash_block_next: u256 =
        0x8407da492b7df20d2fe034a942a7c480c34eef978fe8b91ae98fcea4f3767125;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash_block_next, block.number + 1);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::TxRoot,
            block.number,
            len, // block_header_rlp_bytes_len: usize ,
            rlp // block_header_rlp: Array<u64>,
        );

    let transactions_root: u256 = dsp.store.get_transactions_root(block.number);
    println!("transactions root: {:?}", transactions_root);
//     assert_eq!(transactions_root, data); TODO
}

#[test]
fn process_block_success_receipts_root_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let (rlp, len) = rlp::RLP_0();
    let parent_hash_block_next: u256 =
        0x8407da492b7df20d2fe034a942a7c480c34eef978fe8b91ae98fcea4f3767125;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash_block_next, block.number + 1);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::ReceiptRoot,
            block.number,
            len, // block_header_rlp_bytes_len: usize ,
            rlp // block_header_rlp: Array<u64>,
        );

    let receipts_root: u256 = dsp.store.get_receipts_root(block.number);
    println!("receipts root: {:?}", receipts_root);
//     assert_eq!(receipts_root, data); TODO
}

#[test]
fn process_block_success_difficulty_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let (rlp, len) = rlp::RLP_0();
    let parent_hash_block_next: u256 =
        0x8407da492b7df20d2fe034a942a7c480c34eef978fe8b91ae98fcea4f3767125;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash_block_next, block.number + 1);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::Difficulty,
            block.number,
            len, // block_header_rlp_bytes_len: usize ,
            rlp // block_header_rlp: Array<u64>,
        );

    let difficulty: u64 = dsp.store.get_difficulty(block.number);
    println!("difficulty: {:?}", difficulty);
//     assert_eq!(difficulty, data); TODO
}

#[test]
fn process_block_gas_used_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let (rlp, len) = rlp::RLP_0();
    let parent_hash_block_next: u256 =
        0x8407da492b7df20d2fe034a942a7c480c34eef978fe8b91ae98fcea4f3767125;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash_block_next, block.number + 1);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::GasUsed,
            block.number,
            len, // block_header_rlp_bytes_len: usize ,
            rlp // block_header_rlp: Array<u64>,
        );

    let gas_used: u64 = dsp.store.get_gas_used(block.number);
    println!("gas used: {:?}", gas_used);
// assert_eq!(gas_used, data); TODO
}

#[test]
fn process_block_success_timestamp_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let (rlp, len) = rlp::RLP_0();
    let parent_hash_block_next: u256 =
        0x8407da492b7df20d2fe034a942a7c480c34eef978fe8b91ae98fcea4f3767125;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash_block_next, block.number + 1);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::TimeStamp,
            block.number,
            len, // block_header_rlp_bytes_len: usize ,
            rlp // block_header_rlp: Array<u64>,
        );

    let timestamp: u64 = dsp.store.get_timestamp(block.number);
    println!("timestamp: {:?}", timestamp);
// assert_eq!(timestamp, data); TODO
}

#[test]
fn process_block_success_base_fee_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let (rlp, len) = rlp::RLP_0();
    let parent_hash_block_next: u256 =
        0x8407da492b7df20d2fe034a942a7c480c34eef978fe8b91ae98fcea4f3767125;

    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash_block_next, block.number + 1);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::BaseFee,
            block.number,
            len, // block_header_rlp_bytes_len: usize ,
            rlp // block_header_rlp: Array<u64>,
        );

    let base_fee: u64 = dsp.store.get_base_fee(block.number);
    println!("base fee: {:?}", base_fee);
// assert_eq!(base_fee, data); TODO
}

#[test]
#[should_panic]
fn process_block_cannot_validate_header_rlp_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let (rlp, len) = rlp::RLP_0();

    dsp
        .store
        .process_block(
            ProcessBlockOptions::TimeStamp,
            block.number,
            len, // block_header_rlp_bytes_len: usize ,
            rlp // block_header_rlp: Array<u64>,
        );

    assert!(false)
}

#[test]
fn process_till_block_success_test() {
    // let dsp = setup();
    // // TODO
    assert!(true)
}

#[test]
#[should_panic]
fn process_till_block_fail_wrong_block_headers_length_test() {
    // let dsp = setup();
    // // TODO
    assert!(false)
}

#[test]
#[should_panic]
fn process_till_block_fail_wrong_block_headers_test() {
    // let dsp = setup();
    // // TODO
    assert!(false)
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
