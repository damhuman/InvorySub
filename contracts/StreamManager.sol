pragma solidity ^0.8.24;

import { ISablierV2Lockup } from "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";

contract StreamManagement {
    ISablierV2Lockup public immutable sablier;

    constructor() {
        sablier = ISablierV2LockupDynamic(0xc9940AD8F43aAD8e8f33A4D5dbBf0a8F7FF4429A);
    }

    function withdrawMax(uint256 streamId, address recipient) external {
        sablier.withdrawMax({ streamId: streamId, to: recipient });
    }

    function cancel(uint256 streamId) external returns (uint256) {
        uint128 refundableAmount = sablier.refundableAmountOf(streamId);
        sablier.cancel(streamId);
        return refundableAmount;
    }
}