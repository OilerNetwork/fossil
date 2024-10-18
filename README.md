# WIP of Fossil to Cairo 1

## References
- Fossil cairo 0: https://github.com/OilerNetwork/fossil_cairo0/tree/master
- Some utils libraries that can be reused after refacto to latest cairo updates: https://github.com/HerodotusDev/cairo-lib

### The repo structure and files organisation will be reviewed once all the components will be implemented

### Dependencies

1. Download:
   ```bash
      curl -L https://foundry.paradigm.xyz | bash;
      curl -L https://install.dojoengine.org | bash
   ```
2. New terminal:
```bash
   dojoup -v v1.0.0-alpha.16
   asdf plugin add starknet-foundry
   asdf plugin add scarb
   asdf plugin add starkli
   cd starknet; asdf install
   cd ../ethereum; forge soldeer install
```

### Testing
1. Start Anvil in a new terminal with the command:
   ```bash
   anvil
   ```

2. I a New Terminal Start the Katana StarkNet node:
   ```bash
   katana --messaging anvil.messaging.json --disable-fee 
   ```

3. In a New Terminal Build the project and set up environment variables:
   ```bash
   cd starknet
   scarb build
   source katana/katana.env
   ```

4. Declare the Cairo contracts:
   ```bash
   katana/declare.sh
   ```

5. Deploy the Cairo contracts:
   ```bash
   katana/deploy.sh
   ```

6. In a New Terminal Set up local Ethereum testing:
   ```bash
   cd ethereum
   cp anvil.env .env
   source .env
   forge script script/LocalTesting.s.sol:LocalSetup --broadcast --rpc-url ${ETH_RPC_URL} 
   ```

7. Generate the proof for the mock account and storage:
```
cast proof 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 0 --block 3
```

8. The script `starknet/katana/prove_sto.sh` is a wrapper to store the state root and verify account first and then storage proof for the slot 0x0 in `MockStorage.sol`.
```
katana/verify_proofs.sh
```
