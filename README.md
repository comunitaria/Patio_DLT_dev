# How to work with the upgradeable smart contract infrastructure:
### if you deploy the smart contract for the first time
* start (or connect to) a blockchain. --> For local development run the command truffle develop
* create your the smart contract (e.g Voting.sol)
* then register this smart contract to zos with the command `zos add Voting`
* then push this configuration the the blockchain where an upgradable infrastructure will be created with the following command `zos push --network local`
* the command above created a proxy smart contract that calls a voting Smart Contract at a given address with the function that it gets passed. If we want to update our logic the logic smart contract gets replaced (and a new address will be created). The we set the new address in the proxy smart contract
* now we can create an upgradable instance of our smart contract with the command: `zos create Voting --init initialize --network local`
* safe the proxy address of the output of the command above and set it in the variable `UPGRADABLE_VOTING_PROXY_SMART_CONTRACT_ADDRESS` in the settings of the microservice (settings.py of the microservice) 
* now after we changed the logic of our smart we have to deploy the new version of the smart contract with the following command `zos push --network local`
* and then we set the new instance of our smart contract to our proxy contract with the following command: zos update Voting --network local
* the address of the proxy contract stays the same we do not have to update our microservices settings. 

### if you changed the logic of the smart contract and want to deploy a new version
* recompile the new version of the smart contract with the command `zos push --network local`
* and then we set the new instance of our smart contract to our proxy contract with the following command: zos update Voting --network local
* the address of the proxy contract stays the same we do not have to update our microservices settings. 

# Important if you are running a local blockchain the upgradable infrastructure gets deleted after you stop the blockchain. If you restart the blockchain delete the file zos.local.json and follow the steps described in deploy the smart contract for the first time to redeploy the smart contract with zos

# How to deploy the smart contract to your local development blockchain:
* from within the truffle project run the command `truffle develop` . This will create 10 different accounts that have eth available
* set the ETHER_WALLET_ID_TO_USE setting in settings.py to a number between 0 and 9
* set the `NETWORK_TO_USE` setting in settings.py to `local`
* set the `UPGRADABLE_VOTING_PROXY_SMART_CONTRACT_ADDRESS` setting to the address that is set in the Proxies object of the zos.local.json file
*  deploy the smart contract with the zos client (described above)

# How to deploy the smart contract to rinkeby:

* first we need an account that was created by geth.
* save the password for the account in a file (we need this file later to unlock the account when running geth) \# unlock_credentials.txt
*  `geth --rinkeby account new --password ./unlock_credentials.txt`
this will create your account and return the address of the created account.
* save this address.
* now we check the balance of the account:
* first start the geth node on rinkeby:
*  `geth --rinkeby --light` (this could take a while)
then attach a javascript console to it:
*  `geth --rinkeby attach`
* define this utility function: (just copy paste it into the console):
`function checkAllBalances() {
    var totalBal = 0;
    for (var acctNum in eth.accounts) {
        var acct = eth.accounts[acctNum];
        var acctBal = web3.fromWei(eth.getBalance(acct), "ether");
        totalBal += parseFloat(acctBal);
        console.log("  eth.accounts[" + acctNum + "]: \t" + acct + " \tbalance: " + acctBal + " ether");
    }
    console.log("  Total balance: " + totalBal + " ether");
};`
* then run it to see all of your account balances:
 `checkAllBalances();`
* if you don't have any accounts that have some ether (we will need it for the deployment) we need to add some funds. go to the rinkeby faucet and send some funds to your address (copy the addresse that you want to send ether to from the output that the command checkAllBalances() gave you)
* check your account balances again in the geth javascript console
* `checkAllBalances();`
* now we need to run our local node with an unlocked account (that means that the node has full access to the wallet and can spend ether when needed) **Make sure that the node does not accept connections through HTTP otherwise the ether of that account could be stolen**: https://blog.ethereum.org/2015/08/29/security-alert-insecurely-configured-geth-can-make-funds-remotely-accessible/
* set the ETHER_WALLET_ID_TO_USE setting in settings.py to the wallet id that you just funded.
* set the `NETWORK_TO_USE` setting in settings.py to `rinkeby`
* set the `UPGRADABLE_VOTING_PROXY_SMART_CONTRACT_ADDRESS` setting to the address that is set in the Proxies object of the zos.local.json file
* run your local geth node with the unlocked account : `geth --password ./unlock_credentials.txt --unlock 32eee519e85bdc238853db5cb0d38671780fa062(REPLACE WITH YOUR ACCOUNTADDRESS) --rinkeby --light`
* deploy the smart contract with the zos client (described above)

# How to deploy the smart contract to the ethereum main network:
* follow the same steps from the instructions from the **How to deploy the smart contract to rinkeby guide** but remove the `--rinkeby` flag on all `geth` commands


# How to change the direction of the socket file of  the ethereum node
* add the flag --ipcpath "/my/custom/path/to/geth.ipc"
* e.g : `geth --password ./unlock_credentials.txt --unlock 0x83b2cbd2345e805f39face47bcf840af5ddfda4b --rinkeby --light --ipcpath "/tmp/rinkeby/geth.ipc"`
* **make sure that the custom ipcpath matches the path that you have defined in the RINKEBY_SOCKET_FILE_PATH or MAINNET_SOCKET_FILE_PATH setting** (the ipc file only exists as long as geth is running)
