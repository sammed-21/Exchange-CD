require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

const INFURA_KEY_URL = process.env.QUICKNODE_HTTP_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    sepolia: {
      url: INFURA_KEY_URL,
      accounts: [PRIVATE_KEY],
    },
  },
};
//0x4788c669893011e8123eAeB64E9916Cf4d878F0D
