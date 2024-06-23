// scripts/deploy.ts
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy StreamManager
  const StreamManager = await ethers.getContractFactory("StreamManager");
  const streamManager = await StreamManager.deploy();
  await streamManager.deployed();
  console.log("StreamManager deployed to:", streamManager.address);

  // Deploy StreamCreator
  const StreamCreator = await ethers.getContractFactory("StreamCreator");
  const streamCreator = await StreamCreator.deploy();
  await streamCreator.deployed();
  console.log("StreamCreator deployed to:", streamCreator.address);

  // Deploy IWETH (assuming it's a mock contract for testing purposes)
  const IWETH = await ethers.getContractFactory("IWETH");
  const iWETH = await IWETH.deploy();
  await iWETH.deployed();
  console.log("IWETH deployed to:", iWETH.address);

  // Deploy Ivory and pass the addresses of StreamManager and StreamCreator
  const Ivory = await ethers.getContractFactory("Ivory");
  const ivory = await Ivory.deploy(streamCreator.address, streamManager.address);
  await ivory.deployed();
  console.log("Ivory deployed to:", ivory.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
