// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "@forge-std/src/Script.sol";
import {MockStorage} from "../src/Mock/MockStorage.sol";
import {DeployMockStorage} from "../script/DeployMockStorage.s.sol";
import {Test, console} from "@forge-std/src/Test.sol";

contract MockStorageTest is Test{
    MockStorage mockStorage;

    function setUp() external {
        DeployMockStorage deployer = new DeployMockStorage();
        mockStorage = deployer.run();
    }

        
    function testMockStorage() public view {

        assert( mockStorage.getValue() == 1000);
        assert( mockStorage.getMapValues(1000) == 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99);
        assert( mockStorage.getMapValues(2000) == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        assert( mockStorage.getArrValues(0) == 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99);
        assert( mockStorage.getArrValues(1) == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
       
    }
}