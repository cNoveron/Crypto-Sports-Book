const path = require("path");
const HDWalletProvider = require('@truffle/hdwallet-provider');

require('dotenv').config();

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "app/src/contracts"),
  networks: {
    develop: {
      port: 9545
    },
    ganache: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "5777"
    },
    ropsten: {
      provider: function () {
        return new HDWalletProvider(
          process.env.MNEMONIC,
          "https://ropsten.infura.io/v3/" + process.env.INFURA_APIKEY,
          0,
          10,
          process.env.DERIVATION_PATH
        )
      },
      network_id: 3
    },
  }
};
