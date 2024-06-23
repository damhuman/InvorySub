import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
export default buildModule("IvoryModule", (m) => {
  const managerAddress = m.getParameter("managerAddress");
  const creatorAddress = m.getParameter("creatorAddress");

  const ivory = m.contract("Ivory", [creatorAddress, managerAddress]);

  return { ivory };
});
