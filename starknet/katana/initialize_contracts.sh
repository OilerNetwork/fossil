#!/bin/bash

# Load the addresses from the deployed-contracts.txt file
declare -A addresses

while IFS= read -r line; do
    contract_name=$(echo "$line" | cut -d ':' -f 1 | xargs)
    contract_address=$(echo "$line" | cut -d ' ' -f 2 | xargs)
    addresses["$contract_name"]=$contract_address
done < katana/deployed-contracts.txt

# Retrieve the addresses
fact_registry_address=${addresses["fact-registry"]}
headers_store_address=${addresses["headers-store"]}
messages_proxy_address=${addresses["messages-proxy"]}

# Debug: Print the addresses
echo "Fact Registry Address: $fact_registry_address"
echo "Headers Store Address: $headers_store_address"
echo "Messages Proxy Address: $messages_proxy_address"

# Export the L2_CONTRACT_ADDRESS environment variable
export L2_CONTRACT_ADDRESS=$messages_proxy_address

# Debug: Verify the L2_CONTRACT_ADDRESS
echo "L2_CONTRACT_ADDRESS: $L2_CONTRACT_ADDRESS"

# Retrieve the L1_MESSAGE_SENDER_ADDRESS from the environment variables
l1_message_sender_address=${L1_MESSAGE_SENDER_ADDRESS}
owner_address=${OWNER_ADDRESS}

# Check if the L1_MESSAGE_SENDER_ADDRESS environment variable is set
if [ -z "$l1_message_sender_address" ]; then
    echo "Error: L1_MESSAGE_SENDER_ADDRESS environment variable is not set."
    exit 1
fi

# Perform the invocations
echo "Initializing fact-registry with headers-store address..."
starkli invoke "$fact_registry_address" initialize "$headers_store_address" -w

echo "Initializing messages-proxy with L1_MESSAGE_SENDER_ADDRESS and headers-store address..."
starkli invoke "$messages_proxy_address" initialize "$l1_message_sender_address" "$headers_store_address" "$owner_address" -w

echo "Initializing headers-store with messages-proxy address..."
starkli invoke "$headers_store_address" initialize "$messages_proxy_address" -w

echo "Invocations complete."
