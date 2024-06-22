pragma solidity >=0.8.26;

struct Content {
    uint16 tier_count;
    array<uint256> tier_prices;
}

struct PublisherData {
    constructor(address addr) {
        data.addr = addr;
    }

    function getTierPrice(uint16 tier) public view returns (uint256) {
        return content.tier_prices[tier];
    }

    address addr;
    Content content;
}

struct SubscriberData {
    constructor(address addr) {
        data.addr = addr;
    }

    mapping(address => uint) public publisherTiers;

    address addr;
}

contract Publisher {
    array<PublisherData> public publishers;

    function addPublisher(address addr) public {
        publishers.push(PublisherData(addr));
    }

    function updateContent(address addr, uint16 tier_count, array<uint256> tier_prices) public {
        for (uint256 i = 0; i < publishers.length; i++) {
            if (publishers[i].addr == addr) {
                publishers[i].content.tier_count = tier_count;
                publishers[i].content.tier_prices = tier_prices;
                break;
            }
        }
    }

    function deletePublisher(address addr) public {
        for (uint256 i = 0; i < publishers.length; i++) {
            if (publishers[i].addr == addr) {
                delete publishers[i];
                break;
            }
        }
    }
}