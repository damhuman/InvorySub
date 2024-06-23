// SPDX-License-Identifier: MIT
pragma solidity >=0.8.26;

import "./StreamCreator.sol";
import "./StreamManager.sol";

contract Rapira {
    struct Subscription {
        address subscriber;
        address publisher;
        uint256 tierIndex;
        uint256 expirationTime;
        uint256 streamId;
    }

    mapping(address => uint256[]) public publisherTiers;
    mapping(address => uint256) public balances;
    Subscription[] public subscriptions;

    StreamCreator public streamCreator;
    StreamManager public streamManager;

    event Subscribed(address indexed subscriber, address indexed publisher, uint256 indexed tierIndex, uint256 expirationTime, uint256 streamId);
    event SubscriptionProlonged(address indexed subscriber, address indexed publisher, uint256 indexed tierIndex, uint256 newExpirationTime);
    event SubscriptionCancelled(address indexed subscriber, address indexed publisher);
    event TierUpgraded(address indexed subscriber, address indexed publisher, uint256 newTierIndex);

    constructor(address _streamCreator, address _streamManager) {
        streamCreator = StreamCreator(_streamCreator);
        streamManager = StreamManager(_streamManager);
    }

    function createTiers(uint256[] memory _prices) external {
        for (uint256 i = 0; i < _prices.length; i++) {
            publisherTiers[msg.sender].push(_prices[i]);
        }
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function _subscribe(address _subscriber, address _publisher, uint256 _tierIndex, uint256 _months) internal {
        require(_tierIndex < publisherTiers[_publisher].length, "Tier does not exist");
        uint256 price = publisherTiers[_publisher][_tierIndex];
        uint256 totalCost = price * _months;
        require(balances[_subscriber] >= totalCost, "Insufficient balance");

        balances[_subscriber] -= totalCost;

        uint256 streamId = streamCreator.createStream(uint128(price), uint128(_months), _publisher);

        Subscription memory newSubscription = Subscription({
            subscriber: _subscriber,
            publisher: _publisher,
            tierIndex: _tierIndex,
            expirationTime: block.timestamp + (_months * 30 days),
            streamId: streamId
        });

        subscriptions.push(newSubscription);

        emit Subscribed(_subscriber, _publisher, _tierIndex, newSubscription.expirationTime, streamId);
    }

    function subscribe(address _publisher, uint256 _tierIndex, uint256 _months) external {
        _subscribe(msg.sender, _publisher, _tierIndex, _months);
    }

    function _cancelSubscription(address _subscriber, address _publisher) internal {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == _subscriber && subscriptions[i].publisher == _publisher) {
                uint256 streamId = subscriptions[i].streamId;
                uint256 refundedAmount = streamManager.cancel(streamId);
                balances[_subscriber] += refundedAmount;
                delete subscriptions[i];
                emit SubscriptionCancelled(_subscriber, _publisher);
                return;
            }
        }
        revert("Subscription not found");
    }

    function cancelSubscription(address _publisher) external {
        _cancelSubscription(msg.sender, _publisher);
    }

    function upgradeTier(address _publisher, uint256 _newTierIndex, uint256 _months) external {
        _cancelSubscription(msg.sender, _publisher);
        _subscribe(msg.sender, _publisher, _newTierIndex, _months);
        emit TierUpgraded(msg.sender, _publisher, _newTierIndex);
    }

    function prolongSubscription(address _publisher, uint256 _months) external {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == msg.sender && subscriptions[i].publisher == _publisher) {
                uint256 remainingTime = subscriptions[i].expirationTime > block.timestamp ? subscriptions[i].expirationTime - block.timestamp : 0;
                uint256 remainingMonths = remainingTime / 30 days;
                uint256 totalMonths = remainingMonths + _months;

                uint256 _tierIndex = subscriptions[i].tierIndex;

                _cancelSubscription(msg.sender, _publisher);
                _subscribe(msg.sender, _publisher, _tierIndex, totalMonths);

                return;
            }
        }
        revert("Subscription not found");
    }

    function withdrawMaxForPublisher(uint256 streamId, address recipient) private {
        streamManager.withdrawMax(streamId, recipient);
    }

    function withdrawForPublisher() external {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].publisher == msg.sender) {
                streamManager.withdrawMax(subscriptions[i].streamId, msg.sender);
            }
        }
    }

    function getAllSubscriptions() external view returns (Subscription[] memory) {
        return subscriptions;
    }

    function getSubscriptionsBySubscriber(address _subscriber) external view returns (Subscription[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == _subscriber) {
                count++;
            }
        }

        Subscription[] memory result = new Subscription[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == _subscriber) {
                result[index] = subscriptions[i];
                index++;
            }
        }

        return result;
    }

    function getSubscriptionsByPublisher(address _publisher) external view returns (Subscription[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].publisher == _publisher) {
                count++;
            }
        }

        Subscription[] memory result = new Subscription[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].publisher == _publisher) {
                result[index] = subscriptions[i];
                index++;
            }
        }

        return result;
    }

    function getTierPrice(address _publisher, uint256 _tierIndex) external view returns (uint256) {
        require(_tierIndex < publisherTiers[_publisher].length, "Tier does not exist");
        return publisherTiers[_publisher][_tierIndex];
    }

    function getSubscriberTier(address _subscriber, address _publisher) external view returns (int256) {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == _subscriber && subscriptions[i].publisher == _publisher) {
                return int256(subscriptions[i].tierIndex);
            }
        }
        return -1;
    }
}
