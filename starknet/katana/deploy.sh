#!/bin/bash

# Deploy the contracts
deploy_contract() {
    local contract_name=$1
    local class_hash=$2

    echo "Deploying contract for $contract_name with class hash $class_hash..."
    
    # Run the deployment command and capture the output
    output=$(starkli deploy "$class_hash" --salt 0x1 -w)

    echo "$contract_name: $output" >> katana/deployed-contracts.txt
    echo "Deployment address for $contract_name saved to deployed-contracts.txt"
}

# Remove existing deployed-contracts.txt file if it exists
rm -f katana/deployed-contracts.txt

# Read each line from declared-classes.txt and deploy the contract
while IFS= read -r line; do
    contract_name=$(echo "$line" | cut -d ':' -f 1 | xargs)
    class_hash=$(echo "$line" | cut -d ' ' -f 2 | xargs)
    deploy_contract "$contract_name" "$class_hash"
done < katana/declared-classes.txt
