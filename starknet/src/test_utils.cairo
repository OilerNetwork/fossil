use snforge_std::{ declare, ContractClassTrait };
use fossil::fact_registry::{contract::FactRegistry, interface::{IFactRegistryDispatcher, IFactRegistryDispatcherTrait}};
use fossil::L1_headers_store::{contract::L1HeaderStore, interface::{IL1HeadersStoreDispatcher, IL1HeadersStoreDispatcherTrait}};
use fossil::L1_messages_proxy::{contract::L1MessagesProxy, interface::{IL1MessagesProxyDispatcher, IL1MessagesProxyDispatcherTrait}};

fn L1_messege_origin() -> starknet::EthAddress {
    'L1_messege_origin'.try_into().unwrap()
}

fn OWNER() -> starknet::ContractAddress{
    starknet::contract_address_const::<'OWNER'>()
}
#[derive(Drop, Copy)]
struct Dispatchers {
    fact_registry: IFactRegistryDispatcher,
    l1_headers_store: IL1HeadersStoreDispatcher,
    l1_messages_proxy: IL1MessagesProxyDispatcher,
}

pub fn setup() -> Dispatchers {
    let contract = declare("FactRegistry").unwrap();
    let (contract_address, _) = contract.deploy(@array![]).unwrap();
    let fact_registry = IFactRegistryDispatcher{contract_address};

    let contract = declare("L1HeadersStore").unwrap();
    let (contract_address, _) = contract.deploy(@array![]).unwrap();
    let l1_headers_store = IL1HeadersStoreDispatcher{contract_address};

    let contract = declare("L1MessagesProxy").unwrap();
    let (contract_address, _) = contract.deploy(@array![]).unwrap();
    let l1_messages_proxy = IL1MessagesProxyDispatcher{contract_address};
    
    fact_registry.initialize(l1_headers_store.contract_address);
    l1_headers_store.initialize(l1_messages_proxy.contract_address);
    l1_messages_proxy.initialize(L1_messege_origin(), l1_headers_store.contract_address, OWNER());

    Dispatchers{fact_registry, l1_headers_store, l1_messages_proxy}
}