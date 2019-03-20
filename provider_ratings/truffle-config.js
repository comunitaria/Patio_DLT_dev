'use strict';

module.exports = {
  networks: {
    local: {
      host: 'localhost',
      port: 9545,
      gas: 5000000,
      network_id: '*'
    },
    rinkeby: {
      host: "localhost", // Connect to geth on the specified
      port: 8545,
      from: "0x83b2CBD2345e805F39fAce47BCf840Af5DdfDa4b",
      network_id: 4,
      gas: 4612388 // Gas limit used for deploys
    }
  }
};