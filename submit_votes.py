from utils.blockchain_uitls import get_eth_provider
from utils.blockchain_uitls import get_compiled_contract_abi

import settings
from web3 import Web3

VOTING_OPTIONS = [b'Matyas', b'Luciano', b'Miguel']
VOTES_RECEIVED_TOTAL = [1, 2, 0]
USER_KEYS_USED = [b'leppvi12', b'uupal1by', b'mzcwxi85']
VOTED_OPTIONS = [b'Matyas',  b'Luciano',  b'Luciano']
VOTING_NAME = b'test vote'


# web3.py instance
provider_to_use = get_eth_provider(settings.NETWORK_TO_USE)
w3 = Web3(provider_to_use)
if settings.NETWORK_TO_USE == 'rinkeby':
    # this is necessary because of the special consensus mechanism of rinkeby:
    # https://web3py.readthedocs.io/en/stable/middleware.html#geth-style-proof-of-authority
    from web3.middleware import geth_poa_middleware
    # inject the poa compatibility middleware to the innermost layer
    w3.middleware_stack.inject(geth_poa_middleware, layer=0)
# set pre-funded account as sender
w3.eth.defaultAccount = w3.eth.accounts[settings.ETHER_WALLET_ID_TO_USE]


# we read the contract abi from the file system (it was deployed with the zos client)

compiled_contract_abi = get_compiled_contract_abi('Voting.json')

check_summed_contract_address = Web3.toChecksumAddress('0xa8f70571907fae3c8e7eaef5573098905c2852d49dd592d12fbeaa39564736be')
voting = w3.eth.contract(
    address=check_summed_contract_address,
    abi=compiled_contract_abi,
)


print('Setting the voting name to Changed voting name...')
tx_hash = voting.functions.submitNewVoting(VOTING_OPTIONS, VOTES_RECEIVED_TOTAL, USER_KEYS_USED, VOTED_OPTIONS, VOTING_NAME).transact()

# Wait for transaction to be mined...
w3.eth.waitForTransactionReceipt(tx_hash)


number_of_existing_votings = voting.functions.getNumberOfSubmittedVotings().call()
print("votings saved in blockchain:")
for index in range(0, number_of_existing_votings-1):
    voting_name = voting.functions.getVotingNameAtIndex(index).call()
    user_key = voting.functions.getUserKeyForVotingNameAtIndex(voting_name, index).call()
    voted_option = voting.functions.getVotedOptionForUserKeyForVoting(user_key, voting_name).call()
    full_amount_of_votes_for_option_for_voting = voting.functions.getFullAmountOfVotesForOptionForVoting(voting_name, voted_option).call()
    print("voting with name {}: user key {} voted option {}".format(voting_name.decode("utf-8") , user_key.decode("utf-8") , voted_option.decode("utf-8") ))


