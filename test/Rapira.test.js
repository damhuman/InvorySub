const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Rapira", function () {
  let rapira, streamCreator, streamManager;
  let deployer, addr1, addr2;

  beforeEach(async function () {
    [deployer, addr1, addr2] = await ethers.getSigners();



    const StreamManagerFactory = await ethers.getContractFactory("StreamManager");
    streamManager = await StreamManagerFactory.deploy();
    await streamManager.waitForDeployment()
    streamManagerAddress = streamManager.target;
    console.log(streamManagerAddress);

    const StreamCreatorFactory = await ethers.getContractFactory("StreamCreator");
    streamCreator = await StreamCreatorFactory.deploy();
    await streamCreator.waitForDeployment()
    streamCreatorAddress = streamCreator.target;
    console.log(streamCreatorAddress);

    // Deploy Rapira with the addresses of the deployed contracts
    const RapiraFactory = await ethers.getContractFactory("Rapira");
    console.log(RapiraFactory.bytecode);
    console.log(RapiraFactory.interface);
    console.log(RapiraFactory.runner);

    rapira = await RapiraFactory.deploy(streamCreatorAddress, streamManagerAddress);
    await rapira.waitForDeployment()
    rapiraAddress = await rapira.getAddress();
    console.log(rapiraAddress);
  });

  
  it("Should deposit ETH and convert to WETH", async function () {
    // const depositAmount = ethers.utils.parseEther("1");
    // await rapira.connect(addr1).deposit({ value: depositAmount });

    // const balance = await rapira.balances(addr1.address);
    // expect(balance).to.equal(depositAmount);
  });
/*
  it("Should withdraw WETH and convert to ETH", async function () {
    const depositAmount = ethers.utils.parseEther("1");
    await rapira.connect(addr1).deposit({ value: depositAmount });

    const withdrawAmount = ethers.utils.parseEther("0.5");
    await rapira.connect(addr1).withdraw(withdrawAmount);

    const balance = await rapira.balances(addr1.address);
    expect(balance).to.equal(depositAmount.sub(withdrawAmount));
  });

  it("Should create a tier", async function () {
    const prices = [ethers.utils.parseEther("1"), ethers.utils.parseEther("2")];
    await rapira.connect(addr1).createTiers(prices);

    const tierPrice1 = await rapira.getTierPrice(addr1.address, 0);
    const tierPrice2 = await rapira.getTierPrice(addr1.address, 1);
    expect(tierPrice1).to.equal(prices[0]);
    expect(tierPrice2).to.equal(prices[1]);
  });

  it("Should subscribe to a tier", async function () {
    const prices = [ethers.utils.parseEther("1")];
    await rapira.connect(addr1).createTiers(prices);

    const depositAmount = ethers.utils.parseEther("3");
    await rapira.connect(addr2).deposit({ value: depositAmount });

    await rapira.connect(addr2).subscribe(addr1.address, 0, 1);

    const subscriptions = await rapira.getSubscriptionsBySubscriber(addr2.address);
    expect(subscriptions.length).to.equal(1);
    expect(subscriptions[0].publisher).to.equal(addr1.address);
  });

  it("Should cancel a subscription", async function () {
    const prices = [ethers.utils.parseEther("1")];
    await rapira.connect(addr1).createTiers(prices);

    const depositAmount = ethers.utils.parseEther("3");
    await rapira.connect(addr2).deposit({ value: depositAmount });

    await rapira.connect(addr2).subscribe(addr1.address, 0, 1);

    await rapira.connect(addr2).cancelSubscription(addr1.address);

    const subscriptions = await rapira.getSubscriptionsBySubscriber(addr2.address);
    expect(subscriptions.length).to.equal(0);
  });

  it("Should upgrade a tier", async function () {
    const prices = [ethers.utils.parseEther("1"), ethers.utils.parseEther("2")];
    await rapira.connect(addr1).createTiers(prices);

    const depositAmount = ethers.utils.parseEther("5");
    await rapira.connect(addr2).deposit({ value: depositAmount });

    await rapira.connect(addr2).subscribe(addr1.address, 0, 1);
    await rapira.connect(addr2).upgradeTier(addr1.address, 1, 1);

    const subscriptions = await rapira.getSubscriptionsBySubscriber(addr2.address);
    expect(subscriptions.length).to.equal(1);
    expect(subscriptions[0].tierIndex).to.equal(1);
  });

  it("Should prolong a subscription", async function () {
    const prices = [ethers.utils.parseEther("1")];
    await rapira.connect(addr1).createTiers(prices);

    const depositAmount = ethers.utils.parseEther("3");
    await rapira.connect(addr2).deposit({ value: depositAmount });

    await rapira.connect(addr2).subscribe(addr1.address, 0, 1);
    await rapira.connect(addr2).prolongSubscription(addr1.address, 1);

    const subscriptions = await rapira.getSubscriptionsBySubscriber(addr2.address);
    expect(subscriptions.length).to.equal(1);
    expect(subscriptions[0].expirationTime).to.be.gt(Math.floor(Date.now() / 1000)); // Compare to current time
  });
  */
});
