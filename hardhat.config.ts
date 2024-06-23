import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.26",
  networks: {
    scrollGoerli: {
      url: process.env.SCROLL_GOERLI_RPC_URL,
      accounts: [`${process.env.PRIVATE_KEY}`]
    }
  }
};

export default config;
