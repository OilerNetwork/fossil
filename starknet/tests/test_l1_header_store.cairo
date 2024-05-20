use fossil::L1_headers_store::interface::IL1HeadersStoreDispatcherTrait;
use fossil::types::OptionsSet;
use super::test_utils::setup;


#[test]
fn receive_from_l1_success_test() {
    let dsp = setup();

    dsp.L1_headers_store.receive_from_l1(

    );



    assert!(true)
}

#[test]
#[should_panic]
fn receive_from_l1_fail_wrong_caller_test() {
    let dsp = setup();
    
    dsp.store.receive_from_l1(

    );
    
    assert!(false)
}

#[test]
fn process_block_success_uncle_hash_test() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_0;

    dsp.store.process_block(
        OptionsSet::UncleHash,
        block.number,
        // block_header_rlp_bytes_len: usize TODO,
        // block_header_rlp: Array<u64>,
    );

    let uncle_hash = dsp.store.get_uncles_hash(block.number);

    assert_eq!(uncle_hash, 0x1234); 
}

#[test]
fn process_block_success_beneficiary_test() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_0;

    dsp.store.process_block(
        OptionsSet::Beneficiary,
        block.number,
        // block_header_rlp_bytes_len: usize TODO,
        // block_header_rlp: Array<u64>,
    );

    let beneficiary = dsp.store.get_beneficiary(block.number);

    assert_eq!(beneficiary, 0x1234);
}

#[test]
fn process_block_success_state_root_test() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_0;

    dsp.store.process_block(
        OptionsSet::StateRoot,
        block.number,
        // block_header_rlp_bytes_len: usize TODO,
        // block_header_rlp: Array<u64>,
    );

    let state_root = dsp.store.get_state_root(block.number);

    assert_eq!(state_root, 0x1234);
}

#[test]
fn process_block_success_transactions_root_test() {
    let dsp = setup();
    
    let block = testdata::blocks::BLOCK_0;

    dsp.store.process_block(
        OptionsSet::TxRoot,
        block.number,
        // block_header_rlp_bytes_len: usize TODO,
        // block_header_rlp: Array<u64>,
    );

    let transactions_root = dsp.store.get_transactions_root(block.number);

    assert_eq!(transactions_root, 0x1234);
}

#[test]
fn process_block_success_receipts_root_test() {
    let dsp = setup();
    
    let block = testdata::blocks::BLOCK_0;

    dsp.store.process_block(
        OptionsSet::ReceiptRoot,
        block.number,
        // block_header_rlp_bytes_len: usize TODO,
        // block_header_rlp: Array<u64>,
    );

    let receipts_root = dsp.store.get_receipts_root(block.number);

    assert_eq!(receipts_root, 0x1234);
}

#[test]
fn process_block_success_difficulty_test() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_0;

    dsp.store.process_block(
        OptionsSet::Difficulty,
        block.number,
        // block_header_rlp_bytes_len: usize TODO,
        // block_header_rlp: Array<u64>,
    );

    let difficulty = dsp.store.get_difficulty(block.number);

    assert_eq!(difficulty, 0x1234);
}

#[test]
fn process_block_gas_used_test() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_0;

    dsp.store.process_block(
        OptionsSet::GasUsed,
        block.number,
        // block_header_rlp_bytes_len: usize TODO,
        // block_header_rlp: Array<u64>,
    );

    let gas_used = dsp.store.get_gas_used(block.number);

    assert_eq!(gas_used, 0x1234);
}

#[test]
fn process_block_success_timestamp_test() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_0;

    dsp.store.process_block(
        OptionsSet::TimeStamp,
        block.number,
        // block_header_rlp_bytes_len: usize TODO,
        // block_header_rlp: Array<u64>,
    );

    let timestamp = dsp.store.get_timestamp(block.number);

    assert_eq!(timestamp, 0x1234);
}

#[test]
fn process_block_success_base_fee_test() {
    let dsp = setup();

    let block = testdata::blocks::BLOCK_0;

    dsp.store.process_block(
        OptionsSet::BaseFee,
        block.number,
        // block_header_rlp_bytes_len: usize TODO,
        // block_header_rlp: Array<u64>,
    );

    let base_fee = dsp.store.get_base_fee(block.number);

    assert_eq!(base_fee, 0x1234);
}

#[test]
#[should_panic]
fn process_block_cannot_validate_header_rlp_test() {
    let dsp = setup();
    
    assert!(false)
}

#[test]
fn process_till_block_success_test() {
    let dsp = setup();
    
    assert!(true)
}

#[test]
#[should_panic]
fn process_till_block_fail_wrong_block_headers_length_test() {
    let dsp = setup();
    
    assert!(false)
}

#[test]
#[should_panic]
fn process_till_block_fail_wrong_block_headers_test() {
    let dsp = setup();
    
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
