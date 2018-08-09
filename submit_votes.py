from utils.blockchain_uitls import get_eth_provider
from utils.blockchain_uitls import get_compiled_code
from utils.blockchain_uitls import get_contract_abi
from utils.blockchain_uitls import get_contract_bytecode

import settings
from web3 import Web3
from web3.contract import ConciseContract

# todo create rest api app where voting options and submitted votes and voting name can be passed
VOTING_OPTIONS = [b'Matyas', b'Luciano', b'Miguel']
VOTES_RECEIVED_TOTAL = [1, 2, 0]
USER_KEYS_USED = [b'leppvi12', b'uupal1by', b'mzcwxi85']
VOTED_OPTIONS_= [b'Matyas',  b'Luciano',  b'Luciano']
VOTING_NAME = b'Comunitaria teset vote '


compiled_contract = get_compiled_code('Voting.sol')
contract_byte_code = get_contract_bytecode(compiled_contract, 'Voting.sol')
contract_abi = get_contract_abi(compiled_contract, 'Voting.sol')


# web3.py instance
provider_to_use = get_eth_provider(settings.NETWORK_TO_USE)
w3 = Web3(provider_to_use)

# set pre-funded account as sender
w3.eth.defaultAccount = w3.eth.accounts[0]

# Instantiate and deploy contract
Voting = w3.eth.contract(abi=contract_abi, bytecode=contract_byte_code)


# Submit the transaction that deploys the contract
tx_hash = Voting.constructor(VOTING_OPTIONS, VOTES_RECEIVED_TOTAL, USER_KEYS_USED, VOTED_OPTIONS_,VOTING_NAME).transact()

# Wait for the transaction to be mined, and get the transaction receipt
tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
print ( "Deployed. gasUsed={gasUsed} contractAddress={contractAddress}".format(**tx_receipt) ) # added by me

# Create the contract instance with the newly-deployed address
voting = w3.eth.contract(
    address=tx_receipt.contractAddress,
    abi=contract_abi,
)

# Display the default voting name from the contract
print('Default contract name: {}'.format(
    voting.functions.getVotingName().call()
))

print('Setting the voting name to Changed voting name...')
tx_hash = voting.functions.setVotingName(b'Changed voting name').transact()

# Wait for transaction to be mined...
w3.eth.waitForTransactionReceipt(tx_hash)

# Display the new contract name value
print('Voting name is: {}'.format(
    voting.functions.getVotingName().call()
))
print('Getting votes for Matyas now: {}'.format(
    voting.functions.getFullAmountOfVotesForOption(b'Matyas').call()
))

print('Getting voted option for user key leppvi12 now: {}'.format(
    voting.functions.getVotedOptionForUserKey(b'leppvi12').call()
))
