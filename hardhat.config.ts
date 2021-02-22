import "@nomiclabs/hardhat-ethers";
import "hardhat-spdx-license-identifier";
import "hardhat-abi-exporter";
export default {
  abiExporter: {
    path: './abi',
    clear: true,
    flat: true,
  },
  spdxLicenseIdentifier: {
    overwrite: true,
    runOnCompile: true,
  },
  solidity: {
    compilers :[
      {
        version: "0.8.1",
      }
    ]
  },
  networks: {
    hardhat: {
      gas: 10000000,
      accounts: {
        accountsBalance: "1000000000000000000000000",
      },
      allowUnlimitedContractSize: true,
      timeout: 1000000,
      forking: {
        url: "https://eth-mainnet.alchemyapi.io/v2/90dtUWHmLmwbYpvIeC53UpAICALKyoIu",
        blockNumber: 11880109
      }
    },
    coverage: {
      url: "http://localhost:8555",
    },
  },
};
