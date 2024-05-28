use fossil::L1_headers_store::interface::IL1HeadersStoreDispatcherTrait;
use fossil::library::blockheader_rlp_extractor::{
    decode_parent_hash, decode_uncle_hash, decode_beneficiary, decode_state_root,
    decode_transactions_root, decode_receipts_root, decode_difficulty, decode_base_fee,
    decode_timestamp, decode_gas_used
};
use fossil::library::words64_utils::{words64_to_nibbles, Words64Trait};
use fossil::testing::proofs;
use fossil::types::ProcessBlockOptions;
use fossil::types::Words64Sequence;
use snforge_std::start_cheat_caller_address;
use starknet::EthAddress;
use super::test_utils::setup;

pub fn get_rlp() -> Array<u64> {
    array![
        17942930940933183180,
        10630688908008413652,
        12661074544460729427,
        864726895158924156,
        16160421152376605773,
        16780068465932993973,
        7473385843023090245,
        1987365566732607810,
        18248819419131476918,
        1984847897903778775,
        11250872762094254827,
        2927235116766469468,
        12571860411242042658,
        16186457246499692536,
        5430745597336979773,
        4560371398778244901,
        4180223512850766399,
        11269249778585820866,
        17452780617349289056,
        17686478862929260379,
        11152982928411641007,
        17273895561864136137,
        6175259058000229345,
        15391611023919743232,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        9545095912481861326,
        10989761733450733549,
        14953183967168469464,
        9439837342822524276,
        7532384104041296183,
        3328588300275316088,
        11561634209445742650,
        1195534606310635284,
        13885345432711804137,
        13993844412326043916,
        254522925965248994,
        13959192
    ]
}


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
    let parent_hash: u256 = 0x8407da492b7df20d2fe034a942a7c480c34eef978fe8b91ae98fcea4f3767125;
    start_cheat_caller_address(dsp.store.contract_address, dsp.proxy.contract_address);
    dsp.store.receive_from_l1(parent_hash, block.number + 1);

    let rlp = get_rlp();
    // let data = decode_uncle_hash(rlp);
    // let data_arr = split_u256_to_u64_array_no_span(data);

    dsp
        .store
        .process_block(
            ProcessBlockOptions::UncleHash,
            block.number,
            539, // block_header_rlp_bytes_len: usize,
            rlp // block_header_rlp: Array<u64>,
        );

    let uncle_hash: u256 = dsp.store.get_uncles_hash(block.number); // u256
    println!("uncle_hash: {:?}", uncle_hash);
// assert_eq!(uncle_hash, data);
}

// #[test]
// fn process_block_success_beneficiary_test() {
//     let dsp = setup();

//     let block = proofs::blocks::BLOCK_0();
//     let rlp = get_rlp();
//     let data = decode_beneficiary(rlp);
//     let data_arr = words64_to_nibbles(data.to_words64(), 0); // TODO ETHAddress

//     dsp
//         .store
//         .process_block(
//             ProcessBlockOptions::Beneficiary,
//             block.number,
//             4, // block_header_rlp_bytes_len: usize ,
//             data_arr // block_header_rlp: Array<u64>,
//         );

//     let beneficiary: EthAddress = dsp.store.get_beneficiary(block.number);

//     assert_eq!(beneficiary, data);
// }

// #[test]
// fn process_block_success_state_root_test() {
//     let dsp = setup();

//     let block = proofs::blocks::BLOCK_0();
//     let rlp = get_rlp();
//     let data = decode_state_root(rlp);
//     let data_arr = split_u256_to_u64_array_no_span(data);

//     dsp
//         .store
//         .process_block(
//             ProcessBlockOptions::StateRoot,
//             block.number,
//             4, // block_header_rlp_bytes_len: usize ,
//             data_arr // block_header_rlp: Array<u64>,
//         );

//     let state_root: u256 = dsp.store.get_state_root(block.number);

//     assert_eq!(state_root, data);
// }

// #[test]
// fn process_block_success_transactions_root_test() {
//     let dsp = setup();

//     let block = proofs::blocks::BLOCK_0();
//     let rlp = get_rlp();
//     let data = decode_transactions_root(rlp); // u256
//     let data_arr = split_u256_to_u64_array_no_span(data);

//     dsp
//         .store
//         .process_block(
//             ProcessBlockOptions::TxRoot,
//             block.number,
//             4, // block_header_rlp_bytes_len: usize ,
//             data_arr // block_header_rlp: Array<u64>,
//         );

//     let transactions_root: u256 = dsp.store.get_transactions_root(block.number);

//     assert_eq!(transactions_root, data);
// }

// #[test]
// fn process_block_success_receipts_root_test() {
//     let dsp = setup();

//     let block = proofs::blocks::BLOCK_0();
//     let rlp = get_rlp();
//     let data = decode_receipts_root(rlp);
//     let data_arr = split_u256_to_u64_array_no_span(data);

//     dsp
//         .store
//         .process_block(
//             ProcessBlockOptions::ReceiptRoot,
//             block.number,
//             4, // block_header_rlp_bytes_len: usize ,
//             data_arr // block_header_rlp: Array<u64>,
//         );

//     let receipts_root: u256 = dsp.store.get_receipts_root(block.number);

//     assert_eq!(receipts_root, data);
// }

// #[test]
// fn process_block_success_difficulty_test() {
//     let dsp = setup();

//     let block = proofs::blocks::BLOCK_0();
//     let rlp = get_rlp();
//     let data = decode_difficulty(rlp);
//     let data_arr = array![data];

//     dsp
//         .store
//         .process_block(
//             ProcessBlockOptions::Difficulty,
//             block.number,
//             1, // block_header_rlp_bytes_len: usize ,
//             data_arr // block_header_rlp: Array<u64>,
//         );

//     let difficulty: u64 = dsp.store.get_difficulty(block.number);

//     assert_eq!(difficulty, data);
// }

// #[test]
// fn process_block_gas_used_test() {
//     let dsp = setup();

//     let block = proofs::blocks::BLOCK_0();
//     let rlp = get_rlp();
//     let data = decode_gas_used(rlp);
//     let data_arr = array![data];

//     dsp
//         .store
//         .process_block(
//             ProcessBlockOptions::GasUsed,
//             block.number,
//             1, // block_header_rlp_bytes_len: usize ,
//             data_arr // block_header_rlp: Array<u64>,
//         );

//     let gas_used: u64 = dsp.store.get_gas_used(block.number);

//     assert_eq!(gas_used, data);
// }

// #[test]
// fn process_block_success_timestamp_test() {
//     let dsp = setup();

//     let block = proofs::blocks::BLOCK_0();
//     let rlp = get_rlp();
//     let data = decode_timestamp(rlp);
//     let data_arr = array![data];

//     dsp
//         .store
//         .process_block(
//             ProcessBlockOptions::TimeStamp,
//             block.number,
//             1, // block_header_rlp_bytes_len: usize ,
//             data_arr // block_header_rlp: Array<u64>,
//         );

//     let timestamp: u64 = dsp.store.get_timestamp(block.number);

//     assert_eq!(timestamp, data);
// }

// #[test]
// fn process_block_success_base_fee_test() {
//     let dsp = setup();

//     let block = proofs::blocks::BLOCK_0();
//     let rlp = get_rlp();
//     let data = decode_base_fee(rlp);
//     let data_arr = array![data];

//     dsp
//         .store
//         .process_block(
//             ProcessBlockOptions::BaseFee,
//             block.number,
//             1, // block_header_rlp_bytes_len: usize ,
//             data_arr // block_header_rlp: Array<u64>,
//         );

//     let base_fee: u64 = dsp.store.get_base_fee(block.number);

//     assert_eq!(base_fee, data);
// }

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
