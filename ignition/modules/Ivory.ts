import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("IvoryModule", (m) => {
  const streamCreator = m.contract("StreamCreatorModule");
  const streamManager = m.contract("StreamManagerModule", []);

  const ivory = m.contract("Ivory", [streamCreator, streamManager]);

  return { ivory };
});
