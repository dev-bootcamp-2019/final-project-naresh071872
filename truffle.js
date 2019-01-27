var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "table income onion effort fence beyond seat suit key bag parade balance";
module.exports = {
    //   compilers: {
    //     solc: '0.4.25'
    //   },  
      networks: {
        development: {
          host: "localhost",
          port: 8545,
          network_id: "*" // Match any network id
        },
        rinkeby: {
          provider: function() {
            return new HDWalletProvider(mnemonic,"https://rinkeby.infura.io/v3/565cf132c5f04e558553e63d233ddc2f");
          },
          network_id:4
        }
      }
    };