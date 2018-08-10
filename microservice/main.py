# encoding: utf-8
import os
import json
import settings
from web3 import Web3
from web3.contract import ConciseContract
from flask import (Flask, request, session, g, redirect, url_for, abort,
                   render_template, flash, make_response, Response)
from functools import wraps

from utils.blockchain_uitls import get_eth_provider
from utils.blockchain_uitls import get_compiled_code
from utils.blockchain_uitls import get_contract_abi
from utils.blockchain_uitls import get_contract_bytecode

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
        except OSError:
            return Web3.HTTPProvider('http://127.0.0.1:8545')
    return g.web3prov


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
    compiled_contract = get_compiled_code('Voting.sol')
    contract_byte_code = get_contract_bytecode(compiled_contract, 'Voting.sol')
    contract_abi = get_contract_abi(compiled_contract, 'Voting.sol')

    # web3.py instance
    provider_to_use = get_provider()
    w3 = Web3(provider_to_use)

    # set pre-funded account as sender
    w3.eth.defaultAccount = w3.eth.accounts[0]

    # Instantiate and deploy contract
    Voting = w3.eth.contract(abi=contract_abi, bytecode=contract_byte_code)
    
    # Submit the transaction that deploys the contract
    tx_hash = Voting.constructor(voting_options,
                                 votes_count,
                                 user_keys_used,
                                 votes_submitted,
                                 voting_name).transact()

    # Wait for the transaction to be mined, and get the transaction receipt
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    return tx_receipt.contractAddress


@app.route('/get_voting_attr', methods=['POST'])
@requires_auth
def get_attr():
    # Get data from request.json
    data = request.json
    attr = data['attr']

    # Get contract code
    compiled_contract = get_compiled_code('Voting.sol')
    contract_byte_code = get_contract_bytecode(compiled_contract, 'Voting.sol')
    contract_abi = get_contract_abi(compiled_contract, 'Voting.sol')

    # web3.py instance
    provider_to_use = get_provider()
    w3 = Web3(provider_to_use)

    # set pre-funded account as sender
    w3.eth.defaultAccount = w3.eth.accounts[0]

    # Create the contract instance with the deployed address
    voting = w3.eth.contract(
        address=data['contract_address'],
        abi=contract_abi,
    )

    if attr == 'name':
        return voting.functions.getVotingName().call()
    elif attr == 'votes':
        option = bytes(data['option'], 'utf-8')
        return str(voting.functions.getFullAmountOfVotesForOption(option).call())
    elif attr == 'voted_option':
        k = bytes(data['userkey'], 'utf-8')
        result = voting.functions.getVotedOptionForUserKey(k).call()
        return result.decode('utf-8')


if __name__ == '__main__':
    app.run(
        host="0.0.0.0",
        port=int("5500"),
        debug=True
    )


