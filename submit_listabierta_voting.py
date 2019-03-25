from utils.blockchain_uitls import get_eth_provider
from utils.blockchain_uitls import get_compiled_code
from utils.blockchain_uitls import get_contract_abi
from utils.blockchain_uitls import get_contract_bytecode

import settings
from web3 import Web3

UNIQUE_USER_IDS = [1, 2]
UNIQUE_USER_HASHES = [b'fa50f97fa24791490497', b'181cc0b31847e08df976']
USER_IDS_USED_FOR_VOTES = [1, 1, 2, 2]
USER_IDS_USED_FOR_VOTES_VOTED_CANDIDATE = [2, 1, 2, 1]
USER_IDS_USED_FOR_VOTES_POINTS = [2, 1, 2, 1]
UNIQUE_CANDIDATE_IDS = [1, 2]
UNIQUE_CANDIDATE_NAMES = [b'Matyas', b'Lourdes']
VOTING_NAME = b'alpera'

compiled_contract = get_compiled_code('ListAbiertaVotingResult.sol')
contract_byte_code = get_contract_bytecode(compiled_contract, 'ListAbiertaVotingResult.sol')
contract_abi = get_contract_abi(compiled_contract, 'ListAbiertaVotingResult.sol')


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


# Instantiate and deploy contract
ListAbiertaVotingResult = w3.eth.contract(abi=contract_abi, bytecode=contract_byte_code)

# Submit the transaction that deploys the contract
tx_hash = ListAbiertaVotingResult.constructor().transact()

# Wait for the transaction to be mined, and get the transaction receipt
tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
print ( "Deployed. gasUsed={gasUsed} contractAddress={contractAddress}".format(**tx_receipt) )

# Create the contract instance with the newly-deployed address
voting_results = w3.eth.contract(
    address=tx_receipt.contractAddress,
    abi=contract_abi,
)


print('Submitting voting name and results...')
tx_hash = voting_results.functions.submitNewVoting(
    UNIQUE_USER_IDS, UNIQUE_USER_HASHES, USER_IDS_USED_FOR_VOTES, USER_IDS_USED_FOR_VOTES_VOTED_CANDIDATE,
    USER_IDS_USED_FOR_VOTES_POINTS, UNIQUE_CANDIDATE_IDS, UNIQUE_CANDIDATE_NAMES, VOTING_NAME).transact()

tx_hash_decoded = tx_hash.hex()
# Wait for transaction to be mined...
w3.eth.waitForTransactionReceipt(tx_hash)

c = 5

number_of_existing_votings = voting_results.functions.getNumberOfSubmittedVotings().call()
print("votings saved in blockchain:", number_of_existing_votings)
voting_name = b'alpera'
for index in range(0, number_of_existing_votings):
    voting_name = voting_results.functions.getVotingNameAtIndex(index).call()
    print("voting name: {}".format(voting_name))
    voter_id = 1
    voted_candidate_ids = voting_results.functions.getVotedCandidateIdsForVoterIdForVoting(voter_id, voting_name).call()
    print("voted candidate ids for voter with id {} and voting name {}: {}".format(voter_id, voting_name, voted_candidate_ids))
    voted_candidate_points = voting_results.functions.getVotedCandidatePointsForVoterIdForVoting(voter_id, voting_name).call()
    print("voted candidate points for voter with id {} and voting name {}: {}".format(voter_id, voting_name, voted_candidate_points))
    candidate_id = 2
    candidate_name = voting_results.functions.getCandidateNameForCandidateIdForVoting(
        candidate_id, voting_name).call()
    print("candidate name for candidate id {} is: {}".format(candidate_id, candidate_name))
    voter_hash = b'fa50f97fa24791490497'
    voter_id_found_through_hash = voting_results.functions.getVoterIdForVoterHashForVoting(
        voter_hash, voting_name).call()
    print("voter  id for voter with hash {} is: {}".format(voter_hash, voter_id_found_through_hash))
    total_number_of_points_for_matyas = voting_results.functions.getNumberOfTimesVotedForOnAllPositionsForCandidateNameForVoting(
        voting_name, b'Lourdes').call()
    print("total number of points submitted for matyas: {}".format(total_number_of_points_for_matyas))


