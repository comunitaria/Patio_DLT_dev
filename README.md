# How to work with the upgradeable smart contract infrastructure:
install the zos framework in the project: `npm install zos`
### if you deploy the smart contract for the first time
* start (or connect to) a blockchain. --> For local development run the command truffle develop
* create your the smart contract (e.g Voting.sol)
* then register this smart contract to zos with the command `zos add Voting`
* then run or connect to a blockchain. If you are running a local blockchain run `ganache-cli --port 9545 --deterministic`
* Then we start the session to work with a desired network. `zos session --network local --from 0x1df62f291b2e969fb0849d99d9ce41e2f137006e --expires 3600` 

* then push this configuration the the blockchain where an upgradable infrastructure will be created with the following command `zos push` (it will be pushed to the network that the session was started with)
* the command above created a proxy smart contract that calls a voting Smart Contract at a given address with the function that it gets passed. If we want to update our logic the logic smart contract gets replaced (and a new address will be created). The we set the new address in the proxy smart contract
* now we can create an upgradable instance of our smart contract with the command: `zos create Voting --init initialize --network local`
* safe the proxy address of the output of the command above and set it in the variable `UPGRADABLE_VOTING_PROXY_SMART_CONTRACT_ADDRESS` in the settings of the microservice (settings.py of the microservice) 
* now after we changed the logic of our smart we have to deploy the new version of the smart contract with the following command `zos push`
* and then we set the new instance of our smart contract to our proxy contract with the following command: zos update Voting
* the address of the proxy contract stays the same we do not have to update our microservices settings. 

### if you changed the logic of the smart contract and want to deploy a new version
* recompile the new version of the smart contract with the command `zos push --network rinkeby`(or any other network that you started the session with)
* and then we set the new instance of our smart contract to our proxy contract with the following command: `zos update Voting --network rinkeby` (or any other network that you started the session with)

* the address of the proxy contract stays the same we do not have to update our microservices settings. 

# Important if you are running a local blockchain the upgradable infrastructure gets deleted after you stop the blockchain. If you restart the blockchain delete the file zos.local.json and follow the steps described in deploy the smart contract for the first time to redeploy the smart contract with zos


# How to deploy the smart contract with the zos client to rinkeby:

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
* run your local geth node with the unlocked account : `geth --password ./unlock_credentials.txt --unlock 32eee519e85bdc238853db5cb0d38671780fa062(REPLACE WITH YOUR ACCOUNTADDRESS) --rinkeby --light --rpc`
* next add the Voting smart Contract 
* `zos add Voting
* now we tell zos to start a session in the rinkeby testnet with a specific ethereum wallet (the one that we unlocked in our previous geth command)
* `zos session --network rinkeby --from 0x83b2CBD2345e805F39fAce47BCf840Af5DdfDa4b --expires 3600`
* now the zos session file is written and everything is set up. 
* next we initialize our upgradable smart contract: 
* `zos create Voting --init initialize --network rinkeby`
* save the address that is printed in white on the terminal and use it as the UPGRADABLE_VOTING_PROXY_SMART_CONTRACT_ADDRESS value in settings.py

# How to deploy the smart contract to the ethereum main network:
* follow the same steps from the instructions from the **How to deploy the smart contract with the zos client to rinkeby** but remove the `--rinkeby` flag on all `geth` commands and use the parameter --netowork mainnet on the zos command. (You might also have to add the mainnet option in the truffle-config.js file)


# How to change the direction of the socket file of  the ethereum node
* add the flag --ipcpath "/my/custom/path/to/geth.ipc"
* e.g : `geth --password ./unlock_credentials.txt --unlock 0x83b2cbd2345e805f39face47bcf840af5ddfda4b --rinkeby --light --ipcpath "/tmp/rinkeby/geth.ipc" --rpc`
* **make sure that the custom ipcpath matches the path that you have defined in the RINKEBY_SOCKET_FILE_PATH or MAINNET_SOCKET_FILE_PATH setting** (the ipc file only exists as long as geth is running)
