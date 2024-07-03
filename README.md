# WIP of Fossil to Cairo 1

## References
- Fossil cairo 0: https://github.com/OilerNetwork/fossil_cairo0/tree/master
- Some utils libraries that can be reused after refacto to latest cairo updates: https://github.com/HerodotusDev/cairo-lib

### The repo structure and files organisation will be reviewed once all the components will be implemented

### Testing
1. Start Anvil in a new terminal with the command `anvil`.

2. Install dependencies:
   ```bash 
    dojoup -v 0.7.0-alpha.4
    ```

   ```bash
   cd ethereum
   forge soldeer install forge-std~1.8.2
   ```

3. Build the project and set up environment variables:
   ```bash
   cd starknet
   scarb build
   source katana/katana.env
   ```

4. I a New Terminal Start the Katana StarkNet node:
   ```bash
   katana --messaging anvil.messaging.json --disable-fee 
   ```

5. In a New Terminal Declare the Cairo contracts:
   ```bash
   cd starknet
   katana/declare.sh
   ```

6. Deploy the Cairo contracts:
   ```bash
   katana/deploy.sh
   ```

7. Set up local Ethereum testing:
   ```bash
   cd ../ethereum
   cp anvil.env .env
   source .env
   forge script script/LocalTesting.s.sol:LocalSetup --broadcast --rpc-url ${ETH_RPC_URL} 
   ```

8.  Send a message:
      ```bash
      forge script script/SendMessage.s.sol:Value --broadcast --rpc-url ${ETH_RPC_URL}
      ```

9. Deploy Mock Sol Contract:
     ```bash
     forge script script/DeployMockStorage.s.sol:DeployMockStorage --broadcast --rpc-url ${ETH_RPC_URL}
      ```