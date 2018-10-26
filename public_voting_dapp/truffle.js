
var HDWalletProvider = require("truffle-hdwallet-provider");
var providerSokol = new HDWalletProvider('pusher computer fog unglue crested marathon cursor unfeeling attempt mantra finless surrender', 'https://sokol.poa.network');

console.log("Public key = "+providerSokol.address);

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
   development: {
     host: 'localhost',
     port: 8545,
     gas: 5000000,
     network_id: '*', // eslint-disable-line camelcase
   },
    sokol: {
      provider: providerSokol,
      network_id: 77, // eslint-disable-line camelcase
      from: '0xb0d5fa336f575d9a9f49a454a7e6b71874c4e15f',
      port: 443,
      gasPrice: "100000",
      gas: 5000000,
    }
 }
};
