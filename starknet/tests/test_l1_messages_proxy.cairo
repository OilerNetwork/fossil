use fossil::L1_messages_proxy::interface::IL1MessagesProxyDispatcherTrait;
use snforge_std::start_cheat_caller_address;
use starknet::EthAddress;
use super::test_utils::{setup, OWNER, ADMIN, L1_ORIGIN};

#[test]
fn set_l1_headers_store_test_success() {
    let dsp = setup();

    println!("proxy before: {:?}", dsp.proxy.get_l1_headers_store_address());
    assert_eq!(dsp.proxy.get_l1_headers_store_address(), starknet::contract_address_const::<0>());

    start_cheat_caller_address(dsp.proxy.contract_address, OWNER());
    dsp.proxy.set_l1_headers_store(dsp.store.contract_address);

    println!("proxy after: {:?}", dsp.proxy.get_l1_headers_store_address());

    assert_eq!(dsp.proxy.get_l1_headers_store_address(), dsp.store.contract_address);
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn set_l1_headers_store_test_fail() {
    let dsp = setup();

    start_cheat_caller_address(dsp.proxy.contract_address, ADMIN());
    dsp.proxy.set_l1_headers_store(dsp.store.contract_address);
}

#[test]
fn get_initialized_test() {
    assert!(true)
}

#[test]
fn get_l1_message_sender_test() {
    let dsp = setup();

    start_cheat_caller_address(dsp.proxy.contract_address, OWNER());
    assert_eq!(dsp.proxy.get_l1_messages_sender(), L1_ORIGIN());
}

#[test]
fn get_l1_headers_store_address_test() {
    let dsp = setup();

    start_cheat_caller_address(dsp.proxy.contract_address, OWNER());
    dsp.proxy.set_l1_headers_store(dsp.store.contract_address);

    assert_eq!(dsp.proxy.get_l1_headers_store_address(), dsp.store.contract_address);
}

#[test]
fn change_contract_addresses_success() {
    let dsp = setup();

    let new_l1_headers_store_address: starknet::ContractAddress = 'NEW_L1_HEADER_STORE_ADDRESS'
        .try_into()
        .unwrap();

    start_cheat_caller_address(dsp.proxy.contract_address, OWNER());
    dsp.proxy.change_contract_addresses(L1_ORIGIN(), new_l1_headers_store_address);
}

#[test]
#[should_panic]
fn change_contract_addresses_fail_calle_not_by_owner() {
    let dsp = setup();

    let new_l1_headers_store_address: starknet::ContractAddress = 'NEW_L1_HEADER_STORE_ADDRESS'
        .try_into()
        .unwrap();

    dsp.proxy.change_contract_addresses(L1_ORIGIN(), new_l1_headers_store_address);
}

