#!/bin/bash

# Declare the contracts
declare_contract() {
    local contract_name=$1
    local contract_file=$2

    echo "Declaring Cairo 1 class for $contract_name..."
    
    # Run the command and capture the output
    output=$(starkli declare "$contract_file" -w --compiler-version 2.6.2)

    echo "$contract_name: $output" >> katana/declared-classes.txt
    echo "Class hash for $contract_name saved to declared-classes.txt"
}

# Remove existing declared-classes.txt file if it exists
rm -f katana/declared-classes.txt

# Declare each contract and save the class hash
declare_contract "fact-registry" "target/dev/fossil_FactRegistry.contract_class.json"
declare_contract "headers-store" "target/dev/fossil_L1HeaderStore.contract_class.json"
declare_contract "messages-proxy" "target/dev/fossil_L1MessagesProxy.contract_class.json"
