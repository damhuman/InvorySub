import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("StreamManagerModule", (m) => {
  const streamManager = m.contract("StreamManager");

  return { streamManager };
});
