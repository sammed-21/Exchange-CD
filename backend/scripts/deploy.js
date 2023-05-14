const { ethers } = require("hardhat");

require("dotenv").config();

const { CRYPTO_DEV_TOKEN_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  const cryptoDevTokenAddress = CRYPTO_DEV_TOKEN_CONTRACT_ADDRESS;

  const exchangeContract = await ethers.getContractFactory("Exchange");

  const deployedExchangeContract = await exchangeContract.deploy(
    cryptoDevTokenAddress
  );
  deployedExchangeContract.deployed();

  console.log("exchange contract address", deployedExchangeContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
