// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { FormatWords64 } from "lib/FormatWords64.sol";

import "starknet/IStarknetMessaging.sol";

contract L1MessagesSender {
    IStarknetMessaging private _snMessaging;
    uint256 public immutable l2RecipientAddr;

    /// @dev starknetSelector(receive_from_l1)
    uint256 constant SUBMIT_L1_BLOCKHASH_SELECTOR = 598342674068027518481179578557554850038206119856216505601406522348670006916;

    // TODO - describe
    constructor(address snMessaging, uint256 l2RecipientAddr_) {
        _snMessaging = IStarknetMessaging(snMessaging);
        l2RecipientAddr = l2RecipientAddr_;
    }

    // TODO - natspec
    function sendExactParentHashToL2(uint256 blockNumber_) external payable {
        bytes32 parentHash = blockhash(blockNumber_ - 1);
        require(parentHash != bytes32(0), "ERR_INVALID_BLOCK_NUMBER");
        _sendBlockHashToL2(parentHash, blockNumber_);
    }

    function sendLatestParentHashToL2() external payable {
        bytes32 parentHash = blockhash(block.number - 1);
        _sendBlockHashToL2(parentHash, block.number);
    }

    function _sendBlockHashToL2(bytes32 parentHash_, uint256 blockNumber_) internal {
        uint256[] memory message = new uint256[](5);
        (bytes8 hashWord1, bytes8 hashWord2, bytes8 hashWord3, bytes8 hashWord4) = FormatWords64.fromBytes32(parentHash_);

        message[0] = uint256(uint64(hashWord1));
        message[1] = uint256(uint64(hashWord2));
        message[2] = uint256(uint64(hashWord3));
        message[3] = uint256(uint64(hashWord4));
        message[4] = blockNumber_;

        _snMessaging.sendMessageToL2{value: msg.value}(l2RecipientAddr, SUBMIT_L1_BLOCKHASH_SELECTOR, message);
    }
}