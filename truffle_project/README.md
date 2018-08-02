# How to deploy:

## If you are using ganache (local test development)

run `truffle develop` <br>
in app.py line 23 set network_to_use to 'local'<br>
in app.py line 37 set the right index for account_for_deployment (probably 0) <br>
run `python app.py`

## If you are running your own local node (geth)
create account and start node with unlocked account (unlocking means decrypting the private key which is needed to send
transactions) <br>
`geth --rinkeby account new --password ./node_password.txt` <br>
(the node password txt file should have a newline at the end of the password) remember created account number and get its public key in the next step
`32eee519e85bdc238853db5cb0d38671780fa062`<br>
get the public key of the account (to send funds to the account so that it can deploy smart contracts)
`geth --rinkeby account update 32eee519e85bdc238853db5cb0d38671780fa062` <br>
this will get you the public key of the wallet:
`0x32EEe519E85bdC238853Db5cB0D38671780fA062`<br>
send funds to this wallet and then start the ethereum node with this unlocked account:<br>
`geth --password ./node_password.txt --unlock 32eee519e85bdc238853db5cb0d38671780fa062 --rinkeby --light` <br>
attach from a different console to the node:
`geth --rinkeby attach` <br>
check account balances from this console:
get the account number that you want to use and check
`geth --rinkeby account list` <br>
get the right account index above and check the funds of the account<br>
`eth.getBalance(eth.accounts[5]);`<br>
now send some eth to this account (through metamask or the rinkeby faucet for example)
and reattach to your ethereum node's console and check the account balance again:
<<<<<<< HEAD:truffle_project/README.md
geth --rinkeby attach
eth.getBalance(eth.accounts[5]); it will show the new balance of your account your node synced successfully!
=======
`geth --rinkeby attach`
`eth.getBalance(eth.accounts[5]);` <br> 
<br>it will show the new balance of your account your node synced successfully!
 
