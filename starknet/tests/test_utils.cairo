use fossil::L1_headers_store::{
    contract::L1HeaderStore, interface::{IL1HeadersStoreDispatcher, IL1HeadersStoreDispatcherTrait}
};
use fossil::L1_messages_proxy::{
    contract::L1MessagesProxy,
    interface::{IL1MessagesProxyDispatcher, IL1MessagesProxyDispatcherTrait}
};
use fossil::fact_registry::{
    contract::FactRegistry, interface::{IFactRegistryDispatcher, IFactRegistryDispatcherTrait}
};
use snforge_std::{declare, ContractClassTrait};


pub fn L1_ORIGIN() -> starknet::EthAddress {
    'L1_messege_origin'.try_into().unwrap()
}

pub fn OWNER() -> starknet::ContractAddress {
    starknet::contract_address_const::<'OWNER'>()
}

pub fn OWNER2() -> starknet::ContractAddress {
    starknet::contract_address_const::<'OWNER2'>()
}

pub fn ADMIN() -> starknet::ContractAddress {
    starknet::contract_address_const::<'ADMIN'>()
}
#[derive(Drop, Copy)]
pub struct Dispatchers {
    pub registry: IFactRegistryDispatcher,
    pub store: IL1HeadersStoreDispatcher,
    pub proxy: IL1MessagesProxyDispatcher,
}

pub fn setup() -> Dispatchers {
    let contract_message_proxy = declare("L1MessagesProxy").unwrap();
    let mut constructor_calldata = array![L1_ORIGIN().into(), OWNER().into()];
    let (contract_address_message_proxy, _) = contract_message_proxy
        .deploy(@constructor_calldata)
        .unwrap();
    let proxy = IL1MessagesProxyDispatcher { contract_address: contract_address_message_proxy };

    let contract_header_store = declare("L1HeaderStore").unwrap();
    let mut constructor_calldata = array![proxy.contract_address.into(), ADMIN().into()];
    let (contract_address_header_store, _) = contract_header_store
        .deploy(@constructor_calldata)
        .unwrap();
    let store = IL1HeadersStoreDispatcher { contract_address: contract_address_header_store };

    let contract_factory = declare("FactRegistry").unwrap();
    let mut constructor_calldata = array![store.contract_address.into(), OWNER2().into()];
    let (contract_address_factory, _) = contract_factory.deploy(@constructor_calldata).unwrap();
    let registry = IFactRegistryDispatcher { contract_address: contract_address_factory };

    Dispatchers { registry, store, proxy }
}

#[test]
fn setup_test() {
    setup();
}
