// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Uint256Splitter} from "./lib/Uint256Splitter.sol";

import "./lib/starknet/IStarknetMessaging.sol";

contract L1MessagesSender {
    IStarknetMessaging private _snMessaging;
    uint256 public immutable l2RecipientAddr;
    uint16 public immutable finalizedBlockOffset;

    using Uint256Splitter for uint256;

    /// @dev starknetSelector(receive_from_l1)
    uint256 constant SUBMIT_L1_BLOCKHASH_SELECTOR =
        598342674068027518481179578557554850038206119856216505601406522348670006916;

    // TODO - describe
    constructor(address snMessaging, uint256 l2RecipientAddr_, uint16 finalizedBlockOffset_) {
        _snMessaging = IStarknetMessaging(snMessaging);
        l2RecipientAddr = l2RecipientAddr_;
        finalizedBlockOffset = finalizedBlockOffset_;
    }

    // TODO - natspec
    function sendExactParentHashToL2(uint256 blockNumber_) external payable {
        bytes32 parentHash = blockhash(blockNumber_ - 1);
        require(parentHash != bytes32(0), "ERR_INVALID_BLOCK_NUMBER");
        _sendBlockHashToL2(parentHash, blockNumber_);
    }

    function sendFinalizedBlockHashToL2() external payable {
        bytes32 finalizedBlockHash = blockhash(block.number - finalizedBlockOffset);
        _sendBlockHashToL2(finalizedBlockHash, block.number);
    }

    function _sendBlockHashToL2(bytes32 parentHash_, uint256 blockNumber_) internal {
        uint256[] memory message = new uint256[](4);
        (uint256 parentHashLow, uint256 parentHashHigh) = uint256(parentHash_).split128();
        (uint256 blockNumberLow, uint256 blockNumberHigh) = blockNumber_.split128();
        message[0] = parentHashLow;
        message[1] = parentHashHigh;
        message[2] = blockNumberLow;
        message[3] = blockNumberHigh;

        _snMessaging.sendMessageToL2{value: msg.value}(l2RecipientAddr, SUBMIT_L1_BLOCKHASH_SELECTOR, message);
    }
}
