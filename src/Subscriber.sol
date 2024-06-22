// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PatreonWeb3 {
    struct Tier {
        uint256 price;
        string contentHash; // IPFS hash or other content identifier
    }

    struct Subscription {
        address subscriber;
        address publisher;
        uint256 tierId;
        uint256 expirationTime;
    }

    mapping(address => mapping(uint256 => Tier)) public publisherTiers;
    mapping(address => uint256) public balances;
    Subscription[] public subscriptions;

    event TierCreated(address indexed publisher, uint256 indexed tierId, uint256 price, string contentHash);
    event Subscribed(address indexed subscriber, address indexed publisher, uint256 indexed tierId, uint256 expirationTime);
    event SubscriptionProlonged(address indexed subscriber, address indexed publisher, uint256 indexed tierId, uint256 newExpirationTime);
    event SubscriptionCancelled(address indexed subscriber, address indexed publisher, uint256 indexed tierId);
    event TierUpgraded(address indexed subscriber, address indexed publisher, uint256 oldTierId, uint256 newTierId);

    // Third-party functions (stub implementations)
    function initiate(uint128 amount_per_month, uint128 count_of_months, address recipient_addr) external {
        // Call third-party initiate function
    }

    function cancel(address recipient_addr) external {
        // Call third-party cancel function
    }

    function createTier(uint256 _tierId, uint256 _price, string memory _contentHash) external {
        publisherTiers[msg.sender][_tierId] = Tier({
            price: _price,
            contentHash: _contentHash
        });

        emit TierCreated(msg.sender, _tierId, _price, _contentHash);
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function subscribe(address _publisher, uint256 _tierId, uint256 _startTime, uint256 _months) external {
        Tier memory tier = publisherTiers[_publisher][_tierId];
        require(tier.price > 0, "Tier does not exist");
        uint256 totalCost = tier.price * _months;
        require(balances[msg.sender] >= totalCost, "Insufficient balance");

        balances[msg.sender] -= totalCost;

        Subscription memory newSubscription = Subscription({
            subscriber: msg.sender,
            publisher: _publisher,
            tierId: _tierId,
            expirationTime: _startTime + (_months * 30 days)
        });

        subscriptions.push(newSubscription);

        initiate(uint128(tier.price), uint128(_months), _publisher);

        emit Subscribed(msg.sender, _publisher, _tierId, newSubscription.expirationTime);
    }

    function prolongSubscription(address _publisher, uint256 _tierId, uint256 _months) external {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == msg.sender && subscriptions[i].publisher == _publisher && subscriptions[i].tierId == _tierId) {
                uint256 additionalCost = publisherTiers[_publisher][_tierId].price * _months;
                require(balances[msg.sender] >= additionalCost, "Insufficient balance");

                balances[msg.sender] -= additionalCost;
                subscriptions[i].expirationTime += _months * 30 days;

                initiate(uint128(publisherTiers[_publisher][_tierId].price), uint128(_months), _publisher);

                emit SubscriptionProlonged(msg.sender, _publisher, _tierId, subscriptions[i].expirationTime);
                return;
            }
        }
        revert("Subscription not found");
    }

    function cancelSubscription(address _publisher, uint256 _tierId) external {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == msg.sender && subscriptions[i].publisher == _publisher && subscriptions[i].tierId == _tierId) {
                cancel(_publisher);
                delete subscriptions[i];
                emit SubscriptionCancelled(msg.sender, _publisher, _tierId);
                return;
            }
        }
        revert("Subscription not found");
    }

    function upgradeTier(address _publisher, uint256 _oldTierId, uint256 _newTierId, uint256 _months) external {
        cancelSubscription(_publisher, _oldTierId);
        subscribe(_publisher, _newTierId, block.timestamp, _months);
        emit TierUpgraded(msg.sender, _publisher, _oldTierId, _newTierId);
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

    function getTierContent(address _publisher, uint256 _tierId) external view returns (string memory) {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriber == msg.sender && subscriptions[i].publisher == _publisher && subscriptions[i].tierId == _tierId) {
                require(subscriptions[i].expirationTime > block.timestamp, "Subscription expired");
                return publisherTiers[_publisher][_tierId].contentHash;
            }
        }
        revert("Not subscribed to this tier");
    }
}
