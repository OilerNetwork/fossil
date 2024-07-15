// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/src/Script.sol";
import "forge-std/src/console.sol";

import "src/ContractMsg.sol";
import "src/L1MessageSender.sol";
import "src/StarknetMessagingLocal.sol";
import "src/Mock/MockStorage.sol";

contract LocalSetup is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("ACCOUNT_PRIVATE_KEY");
        string memory json = "local_testing";

        vm.startBroadcast(deployerPrivateKey);

        // Deploy StarknetMessagingLocal
        StarknetMessagingLocal snLocal = new StarknetMessagingLocal();
        console.log("StarknetMessagingLocal deployed at:", address(snLocal));
        vm.serializeString(json, "snMessaging_address", vm.toString(address(snLocal)));

        // Deploy ContractMsg
        ContractMsg contractMsg = new ContractMsg(address(snLocal));
        console.log("ContractMsg deployed at:", address(contractMsg));
        vm.serializeString(json, "contractMsg_address", vm.toString(address(contractMsg)));

        // Deploy L1MessagesSender
        L1MessagesSender l1MessageSender = new L1MessagesSender(address(snLocal), vm.envUint("L2_CONTRACT_ADDRESS"));
        console.log("L1MessagesSender deployed at:", address(l1MessageSender));
        vm.serializeString(json, "l1MessageSender_address", vm.toString(address(l1MessageSender)));

        // Deploy MockStorage
        MockStorage mockStorage = new MockStorage();
        console.log("MockStorage deployed at:", address(mockStorage));
        vm.serializeString(json, "mockStorage_address", vm.toString(address(mockStorage)));

        vm.stopBroadcast();

        string memory data = vm.serializeBool(json, "success", true);

        string memory localLogs = "./logs/";
        vm.createDir(localLogs, true);
        vm.writeJson(data, string.concat(localLogs, "local_setup.json"));
    }
}