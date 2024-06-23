import hre from "hardhat";
import StreamManagerModule from "../ignition/modules/StreamManager";
import StreamCreatorModule from "../ignition/modules/StreamCreator";
import IvoryModule from "../ignition/modules/Ivory";

async function main() {

  const { streamManager } = await hre.ignition.deploy(StreamManagerModule);
  const managerAddress = await streamManager.getAddress();
  console.log(`StreamManager deployed to: ${managerAddress}`);

  const { streamCreator } = await hre.ignition.deploy(StreamCreatorModule);  
  const creatorAddress = await streamCreator.getAddress();
  console.log(`StreamCreator deployed to: ${creatorAddress}`);

  const { ivory } = await hre.ignition.deploy(IvoryModule, {
    parameters: { IvoryModule: {creatorAddress, managerAddress} }
  });
  console.log(`Ivory deployed to: ${await ivory.getAddress()}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
