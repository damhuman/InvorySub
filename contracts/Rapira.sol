// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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

    event TierCreated(address indexed publisher, uint256 indexed tierIndex, uint256 price);
    event Subscribed(address indexed subscriber, address indexed publisher, uint256 indexed tierIndex, uint256 expirationTime, uint256 streamId);
    event SubscriptionProlonged(address indexed subscriber, address indexed publisher, uint256 indexed tierIndex, uint256 newExpirationTime);
    event SubscriptionCancelled(address indexed subscriber, address indexed publisher);
    event TierUpgraded(address indexed subscriber, address indexed publisher, uint256 newTierIndex);

    constructor() {
        streamCreator = StreamCreator();
        streamManager = StreamManager();
    }

    function createTiers(uint256[] memory _prices) external {
        for (uint256 i = 0; i < _prices.length; i++) {
            publisherTiers[msg.sender].push(_prices[i]);
        }
        emit TiersCreated(msg.sender, _prices);
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function subscribe(address _publisher, uint256 _tierIndex, uint256 _months) external {
        require(_tierIndex < publisherTiers[_publisher].length, "Tier does not exist");
        uint256 price = publisherTiers[_publisher][_tierIndex];
        uint256 totalCost = price * _months;
        require(balances[msg.sender] >= totalCost, "Insufficient balance");

        balances[msg.sender] -= totalCost;

        uint256 streamId = streamCreator.createStream(uint128(price), uint128(_months), _publisher);

        Subscription memory newSubscription = Subscription({
            subscriber: msg.sender,
            publisher: _publisher,
            tierIndex: _tierIndex,
            expirationTime: block.timestamp + (_months * 30 days),
            streamId: streamId
        });

        subscriptions.push(newSubscription);

        emit Subscribed(msg.sender, _publisher, _tierIndex, newSubscription.expirationTime, streamId);
    }

    function prolongSubscription(address _publisher, uint256 _months) external {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == msg.sender && subscriptions[i].publisher == _publisher) {
                uint256 _tierIndex = subscriptions[i].tierIndex;
                uint256 price = publisherTiers[_publisher][_tierIndex];
                uint256 additionalCost = price * _months;
                require(balances[msg.sender] >= additionalCost, "Insufficient balance");

                balances[msg.sender] -= additionalCost;
                subscriptions[i].expirationTime += _months * 30 days;

                streamCreator.createStream(uint128(price), uint128(_months), _publisher);

                emit SubscriptionProlonged(msg.sender, _publisher, _tierIndex, subscriptions[i].expirationTime);
                return;
            }
        }
        revert("Subscription not found");
    }

    function prolongSubscription(address _publisher, uint256 _months) external {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == msg.sender && subscriptions[i].publisher == _publisher) {
                uint256 remainingTime = subscriptions[i].expirationTime > block.timestamp ? subscriptions[i].expirationTime - block.timestamp : 0;
                uint256 remainingMonths = remainingTime / 30 days;
                uint256 totalMonths = remainingMonths + _months;

                uint256 _tierIndex = subscriptions[i].tierIndex;

                cancelSubscription(_publisher);
                subscribe(_publisher, _tierIndex, totalMonths);

                return;
            }
        }
        revert("Subscription not found");
    }

    function cancelSubscription(address _publisher) external {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == msg.sender && subscriptions[i].publisher == _publisher) {
                uint256 streamId = subscriptions[i].streamId;
                uint256 refundedAmount = streamManager.cancel(streamId);
                balances[msg.sender] += refundedAmount;
                delete subscriptions[i];
                emit SubscriptionCancelled(msg.sender, _publisher);
                return;
            }
        }
        revert("Subscription not found");
    }

    function upgradeTier(address _publisher, uint256 _newTierIndex, uint256 _months) external {
        cancelSubscription(_publisher);
        subscribe(_publisher, _newTierIndex, block.timestamp, _months);
        emit TierUpgraded(msg.sender, _publisher, _newTierIndex);
    }

    function withdrawMaxForPublisher(uint256 streamId, address recipient) external {
        streamManager.withdrawMax(streamId, recipient);
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
