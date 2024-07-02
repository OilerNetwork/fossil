// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MockStorage {
    uint256 public value;
    mapping(uint256 => address) public mapValues;
    address[] public arrValues;

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

    function setArrValues(address _value) public {
        arrValues.push(_value);
    }

    function getArrValues(uint256 i) public view returns (address) {
        return arrValues[i];
    }
}
