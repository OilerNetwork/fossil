// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "@forge-std/src/Script.sol";
import {MockStorage} from "../src/Mock/MockStorage.sol";

contract DeployMockStorage is Script{

    uint256 public val1 = 1000;
    uint256 public val2 = 2000;
    address public addr = 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99;
    address public addr2 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    function run() external returns (MockStorage) {

        vm.startBroadcast();
        MockStorage mockStorage = new MockStorage();
        mockStorage.setValue(val1);
        mockStorage.setMapValues(val1, addr);
        mockStorage.setMapValues(val2, addr2);
        mockStorage.setArrValues(addr);
        mockStorage.setArrValues(addr2);
        vm.stopBroadcast();

        return mockStorage;
    }

}