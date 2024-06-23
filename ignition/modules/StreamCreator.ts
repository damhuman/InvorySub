import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("StreamCreatorModule", (m) => {
  const streamCreator = m.contract("StreamCreator");

  return { streamCreator };
});
