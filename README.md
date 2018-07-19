# How to deploy:

## If you are using ganache (local test development)

run truffle develop
in app.py line 23 set network_to_use to 'local'
in app.py line 37 set the right index for account_for_deployment (probably 0)
run app.py

## If you are running your own local node (geth)
create account and start node with unlocked account (unlocking means decrypting the private key which is needed to send
transactions)
geth --rinkeby account new --password ./node_password.txt
(the node password txt file should have a newline at the end of the password) remember created account number and get its public key in the next step
32eee519e85bdc238853db5cb0d38671780fa062
get the public key of the account (to send funds to the account so that it can deploy smart contracts)
geth --rinkeby account update 32eee519e85bdc238853db5cb0d38671780fa062
this will get you the public key of the wallet:
0x32EEe519E85bdC238853Db5cB0D38671780fA062
send funds to this wallet and then start the ethereum node with this unlocked account:
geth --password ./node_password.txt --unlock 32eee519e85bdc238853db5cb0d38671780fa062 --rinkeby --light
attach from a different console to the node:
geth --rinkeby attach
check account balances from this console:
get the account number that you want to use and check
geth --rinkeby account list
get the right account index above and check the funds of the account
eth.getBalance(eth.accounts[5]);
now send some eth to this account (through metamask or the rinkeby faucet for example)
and reattach to your ethereum node's console and check the account balance again:
geth --rinkeby attach
eth.getBalance(eth.accounts[5]); it will show the new balance of your account your node synced successfully! 
