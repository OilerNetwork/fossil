# WIP of Fossil to Cairo 1

## References
- Fossil cairo 0: https://github.com/OilerNetwork/fossil_cairo0/tree/master
- Some utils libraries that can be reused after refacto to latest cairo updates: https://github.com/HerodotusDev/cairo-lib

### The repo structure and files organisation will be reviewed once all the components will be implemented

### Testing
Start Anvil in a new terminal with the command `anvil`.

Install dependencies:
   ```bash 
   dojoup -v v1.0.0-alpha.1
    ```

   ```bash
   cd ethereum
   forge soldeer install forge-std~1.8.2
   ```
I a New Terminal Start the Katana StarkNet node:
   ```bash
   katana --messaging anvil.messaging.json --disable-fee 
   ```

In a New Terminal Build the project and set up environment variables:
   ```bash
   cd starknet
   scarb build
   source katana/katana.env
   ```

Declare the Cairo contracts:
   ```bash
   katana/declare.sh
   ```

Deploy the Cairo contracts:
   ```bash
   katana/deploy.sh
   ```

In a New Terminal Set up local Ethereum testing:
   ```bash
   cd ../ethereum
   cp anvil.env .env
   source .env
   forge script script/LocalTesting.s.sol:LocalSetup --broadcast --rpc-url ${ETH_RPC_URL} 
   ```

Send a message:
   ```bash
   forge script script/SendMessage.s.sol:Value --broadcast --rpc-url ${ETH_RPC_URL}
   ```
