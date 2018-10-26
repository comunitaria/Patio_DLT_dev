module.exports = {
  networks: {
    development: {
      host: "https",
      port: 9545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      host: "localhost", // Connect to geth on the specified
      port: 8545,
      from: "0xfc0c354877d3c9983c0aa9a2c277338d3acec110", // default address to use for any transaction Truffle makes during migrations
      network_id: 4,
      gas: 5612388// Gas limit used for deploys
    }
  }
};
