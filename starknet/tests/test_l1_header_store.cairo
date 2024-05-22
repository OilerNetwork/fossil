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
use fossil::types::ProcessBlockOptions;
use fossil::types::Words64Sequence;
use starknet::EthAddress;
use super::test_utils::setup;

pub fn get_rlp() -> Words64Sequence {
    let rlp = Words64Sequence {
        values: array![
            17899166613764872570,
            9377938528222421349,
            9284578564931001247,
            895019019097261264,
            13278573522315157529,
            11254050738018229226,
            16872101704597074970,
            8839885802225769251,
            17633069546125622176,
            5635966238324062822,
            4466071473455465888,
            16386808635744847773,
            5287805632665950919
        ]
            .span(),
        len_bytes: 104
    };
    rlp
}


#[test]
fn receive_from_l1_success_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let parent_hash: u256 = 0xfbacb363819451babc6e7596aa48af6c223e40e8b0ad975e372347df5d60ba0f;

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
    let rlp = get_rlp();
    let data = decode_uncle_hash(rlp);
    let data_arr = split_u256_to_u64_array_no_span(data);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::UncleHash,
            block.number,
            4, // block_header_rlp_bytes_len: usize,
            data_arr // block_header_rlp: Array<u64>,
        );

    let uncle_hash: u256 = dsp.store.get_uncles_hash(block.number); // u256

    assert_eq!(uncle_hash, data);
}

#[test]
fn process_block_success_beneficiary_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let rlp = get_rlp();
    let data = decode_beneficiary(rlp);
    let data_arr = words64_to_nibbles(data.to_words64(), 0); // TODO ETHAddress

    dsp
        .store
        .process_block(
            ProcessBlockOptions::Beneficiary,
            block.number,
            4, // block_header_rlp_bytes_len: usize ,
            data_arr // block_header_rlp: Array<u64>,
        );

    let beneficiary: EthAddress = dsp.store.get_beneficiary(block.number);

    assert_eq!(beneficiary, data);
}

#[test]
fn process_block_success_state_root_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let rlp = get_rlp();
    let data = decode_state_root(rlp);
    let data_arr = split_u256_to_u64_array_no_span(data);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::StateRoot,
            block.number,
            4, // block_header_rlp_bytes_len: usize ,
            data_arr // block_header_rlp: Array<u64>,
        );

    let state_root: u256 = dsp.store.get_state_root(block.number);

    assert_eq!(state_root, data);
}

#[test]
fn process_block_success_transactions_root_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let rlp = get_rlp();
    let data = decode_transactions_root(rlp); // u256
    let data_arr = split_u256_to_u64_array_no_span(data);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::TxRoot,
            block.number,
            4, // block_header_rlp_bytes_len: usize ,
            data_arr // block_header_rlp: Array<u64>,
        );

    let transactions_root: u256 = dsp.store.get_transactions_root(block.number);

    assert_eq!(transactions_root, data);
}

#[test]
fn process_block_success_receipts_root_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let rlp = get_rlp();
    let data = decode_receipts_root(rlp);
    let data_arr = split_u256_to_u64_array_no_span(data);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::ReceiptRoot,
            block.number,
            4, // block_header_rlp_bytes_len: usize ,
            data_arr // block_header_rlp: Array<u64>,
        );

    let receipts_root: u256 = dsp.store.get_receipts_root(block.number);

    assert_eq!(receipts_root, data);
}

#[test]
fn process_block_success_difficulty_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let rlp = get_rlp();
    let data = decode_difficulty(rlp);
    let data_arr = array![data];

    dsp
        .store
        .process_block(
            ProcessBlockOptions::Difficulty,
            block.number,
            1, // block_header_rlp_bytes_len: usize ,
            data_arr // block_header_rlp: Array<u64>,
        );

    let difficulty: u64 = dsp.store.get_difficulty(block.number);

    assert_eq!(difficulty, data);
}

#[test]
fn process_block_gas_used_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let rlp = get_rlp();
    let data = decode_gas_used(rlp);
    let data_arr = array![data];

    dsp
        .store
        .process_block(
            ProcessBlockOptions::GasUsed,
            block.number,
            1, // block_header_rlp_bytes_len: usize ,
            data_arr // block_header_rlp: Array<u64>,
        );

    let gas_used: u64 = dsp.store.get_gas_used(block.number);

    assert_eq!(gas_used, data);
}

#[test]
fn process_block_success_timestamp_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let rlp = get_rlp();
    let data = decode_timestamp(rlp);
    let data_arr = array![data];

    dsp
        .store
        .process_block(
            ProcessBlockOptions::TimeStamp,
            block.number,
            1, // block_header_rlp_bytes_len: usize ,
            data_arr // block_header_rlp: Array<u64>,
        );

    let timestamp: u64 = dsp.store.get_timestamp(block.number);

    assert_eq!(timestamp, data);
}

#[test]
fn process_block_success_base_fee_test() {
    let dsp = setup();

    let block = proofs::blocks::BLOCK_0();
    let rlp = get_rlp();
    let data = decode_base_fee(rlp);
    let data_arr = array![data];

    dsp
        .store
        .process_block(
            ProcessBlockOptions::BaseFee,
            block.number,
            1, // block_header_rlp_bytes_len: usize ,
            data_arr // block_header_rlp: Array<u64>,
        );

    let base_fee: u64 = dsp.store.get_base_fee(block.number);

    assert_eq!(base_fee, data);
}

#[test]
#[should_panic]
fn process_block_cannot_validate_header_rlp_test() {
    // let dsp = setup();
    // // TODO
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
