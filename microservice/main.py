# encoding: utf-8
import settings
from web3 import Web3
from flask import (Flask, request, session, g, redirect, url_for, abort,
                   render_template, flash, make_response, Response)
from functools import wraps
import hashlib

from utils.blockchain_uitls import get_eth_provider
from utils.blockchain_uitls import  get_compiled_contract_abi

from utils.blockchain_uitls import get_eth_provider
from utils.blockchain_uitls import get_compiled_listabierta_smart_contract_code
from utils.blockchain_uitls import get_contract_abi
from utils.blockchain_uitls import get_contract_bytecode
from utils.blockchain_uitls import get_compiled_code, get_compiled_contract_bytecode

# solc package in host is required.

app = Flask(__name__)


# Aux functions
def check_auth(username, password):
    """This function is called to check if a username /
    password combination is valid.
    """
    return username == 'admin' and password == 'secret'


def authenticate():
    """Sends a 401 response that enables basic auth"""
    return Response(
    'Could not verify your access level for that URL.\n'
    'You have to login with proper credentials', 401,
    {'WWW-Authenticate': 'Basic realm="Login Required"'})


def requires_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return decorated
# End aux


@app.route('/')
def hello_world():
    return 'Hello, World!'


def get_provider():
    if not hasattr(g, 'web3prov'):
        try:
            web3prov = get_eth_provider(settings.NETWORK_TO_USE)
            g.web3prov = web3prov
        except OSError as e:
            raise e # return Web3.HTTPProvider('http://127.0.0.1:8545')
    return g.web3prov


@app.route('/get_etherscan_address_of_voting_smart_contract', methods=['GET'])
@requires_auth
def get_etherscan_address_of_voting_smart_contract():
    if settings.NETWORK_TO_USE == 'rinkeby':
        return 'https://rinkeby.etherscan.io/address/{}'.format(settings.UPGRADABLE_VOTING_PROXY_SMART_CONTRACT_ADDRESS)
    return 'https://etherscan.io/address/{}'.format(settings.UPGRADABLE_VOTING_PROXY_SMART_CONTRACT_ADDRESS)


@app.route('/process_voting', methods=['POST'])
@requires_auth
def process_voting():
    # Get data from request.json
    data = request.json
    voting_options = data['voting_options']
    voting_options = [bytes(option, 'utf-8') for option in voting_options]
    votes_count = data['votes_count']
    user_keys_used = data['user_keys_used']
    user_keys_used = [bytes(k, 'utf-8') for k in user_keys_used]
    votes_submitted = data['votes_submitted']
    votes_submitted = [bytes(option, 'utf-8') for option in votes_submitted]
    voting_name = bytes(data['voting_name'], 'utf-8')

    # Get contract code
    # compiled_contract = get_compiled_voting_code('Voting.sol')
    # contract_byte_code = get_contract_bytecode(compiled_contract, 'Voting.sol')
    # contract_abi = get_contract_abi(compiled_contract, 'Voting.sol')

    # web3.py instance
    provider_to_use = get_provider()
    w3 = Web3(provider_to_use)
    if settings.NETWORK_TO_USE == 'rinkeby':
        # this is necessary because of the special consensus mechanism of rinkeby:
        # https://web3py.readthedocs.io/en/stable/middleware.html#geth-style-proof-of-authority
        from web3.middleware import geth_poa_middleware
        # inject the poa compatibility middleware to the innermost layer
        w3.middleware_stack.inject(geth_poa_middleware, layer=0)

    # set pre-funded account as sender
    w3.eth.defaultAccount = w3.eth.accounts[settings.ETHER_WALLET_ID_TO_USE]

    # Instantiate contract
    # Voting = w3.eth.contract(abi=contract_abi, bytecode=contract_byte_code)

    # Get compiled contract code
    compiled_contract_abi = get_compiled_contract_abi('Voting.json')
    compiled_contract_bytecode = get_compiled_contract_bytecode('Voting.json')

    voting_contract = None

    if not settings.VOTING_SMART_CONTRACT_EXISTING_ON_BLOCKCHAIN:

        # Instantiate and deploy contract
        VotingResult = w3.eth.contract(abi=compiled_contract_abi, bytecode=compiled_contract_bytecode)

        # Submit the transaction that deploys the contract
        tx_hash = VotingResult.constructor().transact()

        # Wait for the transaction to be mined, and get the transaction receipt
        tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
        print("Deployed. gasUsed={gasUsed} contractAddress={contractAddress}".format(**tx_receipt))

        # Create the contract instance with the newly-deployed address
        voting_contract = w3.eth.contract(
            address=tx_receipt.contractAddress,
            abi=compiled_contract_abi,
        )

    else:
        print("Found existing smart contract deployed at: {}".format(settings.VOTING_SMART_CONTRACT_ADDRESS))
        voting_contract = w3.eth.contract(
            address=settings.VOTING_SMART_CONTRACT_ADDRESS,
            abi=compiled_contract_abi
        )

    check_summed_contract_address = Web3.toChecksumAddress(settings.UPGRADABLE_VOTING_PROXY_SMART_CONTRACT_ADDRESS)

    voting_contract = w3.eth.contract(
        address=check_summed_contract_address,
        abi=compiled_contract_abi,
    )

    # Submit the transaction that deploys the contract
    tx_hash = voting_contract.functions.submitNewVoting(voting_options,
                                 votes_count,
                                 user_keys_used,
                                 votes_submitted,
                                 voting_name).transact()

    # Wait for the transaction to be mined, and get the transaction receipt
    # tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    # tx_hash = tx_receipt.transactionHash
    print(tx_hash.hex())
    return tx_hash.hex()


@app.route('/get_voting_attr', methods=['POST'])
@requires_auth
def get_attr():
    # Get data from request.json
    data = request.json
    attr = data['attr']

    # Get contract code
    # compiled_contract = get_compiled_code('Voting.sol')
    # contract_byte_code = get_contract_bytecode(compiled_contract, 'Voting.sol')
    # contract_abi = get_contract_abi(compiled_contract, 'Voting.sol')

    # web3.py instance
    provider_to_use = get_provider()
    w3 = Web3(provider_to_use)

    # set pre-funded account as sender
    w3.eth.defaultAccount = w3.eth.accounts[settings.ETHER_WALLET_ID_TO_USE]

    # Get compiled contract code
    compiled_contract_abi = get_compiled_contract_abi('Voting.json')

    check_summed_contract_address = Web3.toChecksumAddress(settings.UPGRADABLE_VOTING_PROXY_SMART_CONTRACT_ADDRESS)

    # Create the contract instance with the deployed address
    # voting = w3.eth.contract(
    #    address=data['contract_address'],
    #    abi=contract_abi,
    # )

    voting = w3.eth.contract(
        address=check_summed_contract_address,
        abi=compiled_contract_abi,
    )

    if attr == 'name':
        registry_index_for_voting_name = voting.functions.getRegistryIndexForVotingName(attr).call()
        return voting.functions.getVotingNameAtIndex(registry_index_for_voting_name).call()
    elif attr == 'votes':
        voting_name = bytes(data['voting_name'], 'utf-8')
        option = bytes(data['option'], 'utf-8')
        return str(voting.functions.getFullAmountOfVotesForOptionForVoting(voting_name, option).call())
    elif attr == 'voted_option':
        voting_name = bytes(data['voting_name'], 'utf-8')
        k = bytes(data['userkey'], 'utf-8')
        result = voting.functions.getVotedOptionForUserKeyForVoting(k, voting_name).call()
        return result.decode('utf-8')


@app.route('/process_provider_rating', methods=['POST'])
@requires_auth
def process_provider_rating():
    # https://stackoverflow.com/questions/16008670/python-how-to-hash-a-string-into-8-digits
    def generate_8_digit_hash_out_of_provider_name_and_survey_key(provider_name, survey_key):
        hash_base = provider_name + survey_key
        return int(hashlib.sha256(hash_base).hexdigest(), 16) % 10**8


    # https://docs.python.org/3/library/stdtypes.html#int.to_bytes
    def int_to_bytes(x):
        return x.to_bytes((x.bit_length() + 7) // 8, 'big')

    # Get data from request.json
    data = request.json
    score = data['provider_score']
    provider_name = bytes(data['provider_name'], 'utf-8')
    provider_address = bytes(data['provider_address'], 'utf-8')
    provider_id = bytes(data['provider_id'], 'utf-8')
    provider_comment = ""
    survey_key = bytes(data['survey_key'], 'utf-8')

    # web3.py instance
    provider_to_use = get_provider()
    w3 = Web3(provider_to_use)
    if settings.NETWORK_TO_USE == 'rinkeby':
        # this is necessary because of the special consensus mechanism of rinkeby:
        # https://web3py.readthedocs.io/en/stable/middleware.html#geth-style-proof-of-authority
        from web3.middleware import geth_poa_middleware
        # inject the poa compatibility middleware to the innermost layer
        w3.middleware_stack.inject(geth_poa_middleware, layer=0)

    # set pre-funded account as sender
    w3.eth.defaultAccount = w3.eth.accounts[settings.ETHER_WALLET_ID_TO_USE]

    # Get compiled contract code
    compiled_contract = get_compiled_code('ProviderRating.sol')
    contract_byte_code = get_contract_bytecode(compiled_contract, 'ProviderRating.sol')
    contract_abi = get_contract_abi(compiled_contract, 'ProviderRating.sol')

    rating_contract = w3.eth.contract(
        address=settings.PROVIDER_RATING_CONTRACT_ADDRESS,
        abi=contract_abi
    )

    HASH_OF_PROVIDER_NAME_AND_SURVEY_KEY = int_to_bytes(
        generate_8_digit_hash_out_of_provider_name_and_survey_key(provider_name,
                                                                  survey_key))

    # Submit the transaction that deploys the contract
    try:
        tx_hash = rating_contract.functions.rateProvider(survey_key,
                                                         HASH_OF_PROVIDER_NAME_AND_SURVEY_KEY,
                                                         provider_name, provider_address,
                                                         provider_id,
                                                         score,
                                                         provider_comment).transact()
    except ValueError as e:
        print(e)
        return "Attempt of duplicated rating. Not allowed."


    # Wait for the transaction to be mined, and get the transaction receipt
    # tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    # tx_hash = tx_receipt.transactionHash
    print(tx_hash.hex())
    return tx_hash.hex()


@app.route('/save_listabierta_voting_result', methods=['POST'])
@requires_auth
def save_listabierta_voting_result():
    # Get data from request.json
    data = request.json
    unique_user_ids = data['unique_user_ids']
    # we know that hashes are 20 characters long so there is no problem with the limit of maximal 32 characters
    unique_user_hashes = data['unique_user_hashes']
    user_ids_used_for_votes = data['user_ids_used_for_votes']
    user_ids_used_for_votes_voted_candidate = data['user_ids_used_for_votes_voted_candidate']
    user_ids_used_for_votes_points = data['user_ids_used_for_votes_points']
    unique_candidate_ids = data['unique_candidate_ids']
    unique_candidtate_names = data['unique_candidate_names']
    # a candidate name could be longer than 32 characters.
    # therefore if that is the case here we make sure that we only save the first 30 characters
    for candidate_name in unique_candidtate_names:
        if len(candidate_name) > 30:
            candidate_name = candidate_name[0:30]
    voting_name = data['voting_name']
    unique_user_hashes = [bytes(hash, 'utf-8') for hash in unique_user_hashes]
    unique_candidtate_names = [bytes(name, 'utf-8') for name in unique_candidtate_names]
    voting_name = bytes(voting_name, 'utf8')


    provider_to_use = get_provider()

    compiled_contract = get_compiled_listabierta_smart_contract_code('ListAbiertaVotingResult.sol')
    contract_byte_code = get_contract_bytecode(compiled_contract, 'ListAbiertaVotingResult.sol')
    contract_abi = get_contract_abi(compiled_contract, 'ListAbiertaVotingResult.sol')

    # web3.py instance
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

    if not settings.LISTABIERTA_VOTING_CONTRACT_EXISTING_ON_BLOCKCHAIN:

        # Instantiate and deploy contract
        ListAbiertaVotingResult = w3.eth.contract(abi=contract_abi, bytecode=contract_byte_code)

        # Submit the transaction that deploys the contract
        tx_hash = ListAbiertaVotingResult.constructor().transact()

        # Wait for the transaction to be mined, and get the transaction receipt
        tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
        print("Deployed. gasUsed={gasUsed} contractAddress={contractAddress}".format(**tx_receipt))

        # Create the contract instance with the newly-deployed address
        voting_results = w3.eth.contract(
            address=tx_receipt.contractAddress,
            abi=contract_abi,
        )

    else:
        print("Found existing smart contract deployed at: {}".format(settings.LISTABIERTA_VOTING_CONTRACT_ADDRESS))
        voting_results = w3.eth.contract(
            address=settings.LISTABIERTA_VOTING_CONTRACT_ADDRESS,
            abi=contract_abi
        )

    print('Submitting voting name and results...')
    tx_hash = voting_results.functions.submitNewVoting(
        unique_user_ids, unique_user_hashes, user_ids_used_for_votes, user_ids_used_for_votes_voted_candidate,
        user_ids_used_for_votes_points, unique_candidate_ids, unique_candidtate_names, voting_name).transact()


    # Wait for the transaction to be mined, and get the transaction receipt
    # tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    # tx_hash = tx_receipt.transactionHash
    print(tx_hash.hex())
    return tx_hash.hex()


if __name__ == '__main__':
    app.run(
        host="0.0.0.0",
        port=int("5500"),
        debug=True
    )

# gunicorn -w 2 -b 0.0.0.0:5500 microservice:app
# nohup gunicorn -w 1 -b 0.0.0.0:5500 microservice:app --timeout 3600  --log-file /tmp/gunicorn_error.log &


