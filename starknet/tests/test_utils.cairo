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

fn L1_ORIGIN() -> starknet::EthAddress {
    'L1_messege_origin'.try_into().unwrap()
}

fn OWNER() -> starknet::ContractAddress {
    starknet::contract_address_const::<'OWNER'>()
}
#[derive(Drop, Copy)]
struct Dispatchers {
    registry: IFactRegistryDispatcher,
    store: IL1HeadersStoreDispatcher,
    proxy: IL1MessagesProxyDispatcher,
}

pub fn setup() -> Dispatchers {
    let contract = declare("FactRegistry").unwrap();
    let (contract_address, _) = contract.deploy(@array![]).unwrap();
    let registry = IFactRegistryDispatcher { contract_address };

    let contract = declare("L1HeadersStore").unwrap();
    let (contract_address, _) = contract.deploy(@array![]).unwrap();
    let store = IL1HeadersStoreDispatcher { contract_address };

    let contract = declare("L1MessagesProxy").unwrap();
    let (contract_address, _) = contract.deploy(@array![]).unwrap();
    let proxy = IL1MessagesProxyDispatcher { contract_address };

    registry.initialize(store.contract_address);
    store.initialize(proxy.contract_address);
    proxy.initialize(L1_ORIGIN(), store.contract_address, OWNER());

    Dispatchers { registry, store, proxy }
}
