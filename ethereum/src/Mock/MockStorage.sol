// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MockStorage {
    uint256 public value;
    mapping(uint256 => address) public mapValues;
    uint[] public arrValues;

    constructor() {
        value = 99;
        mapValues[99] = msg.sender;
        arrValues.push(1);
        arrValues.push(2);
        arrValues.push(3);
        arrValues.push(4);
        arrValues.push(5);
    }

    function setValue(uint256 _value) public {
        value = _value;
    }

    function getValue() public view returns (uint256) {
        return value;
    }

    function setMapValues(uint256 _value, address _add) public {
        mapValues[_value] = _add;
    }

    function getMapValues(uint256 _value) public view returns (address) {
        return mapValues[_value];
    }

    function setArrValues(uint _value) public {
        arrValues.push(_value);
    }

    function getArrValues(uint256 i) public view returns (uint) {
        return arrValues[i];
    }
}
