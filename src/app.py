import time
from web3 import Web3, HTTPProvider, eth
from solc import compile_source
from web3.contract import ConciseContract
import os
from pathlib import Path


def get_eth_provider(provider_name):

    # open a connection to a local ethereum node (ganache or geth)
    eth_providers = {
        'local': HTTPProvider('http://localhost:9545'),  # a (fake local blockchain instance (ganache)
        'rinkeby': Web3.IPCProvider(os.path.join(home, '.ethereum/rinkeby/geth.ipc')) # a rinkeby testnet provider
    }

    return eth_providers[provider_name]


VOTING_CANDIDATES = [b'Yes', b'No', b'I dont care']

home = str(Path.home())
network_to_use = 'rinkeby'
provider_to_use = get_eth_provider(network_to_use)

# todo not working yet but there is some issue with the rinkeby tesnet and its proof of authority style
#if network_to_use == 'rinkeby':
#    # https://ethereum.stackexchange.com/questions/44130/rinkeby-failure-with-web3-py-could-not-format-value-0x-as-field-extrada
#    from web3.middleware import geth_poa_middleware
#    provider_to_use.middleware_stack.inject(geth_poa_middleware, layer=0)


#http_provider = HTTPProvider('http://localhost:9545')
#eth_provider = Web3(http_provider).eth
eth_provider = Web3(provider_to_use).eth

account_for_deployment = eth_provider.accounts[5]

transaction_details = {
    'from': account_for_deployment,
}

project_directory = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
contracts_folder = os.path.join(project_directory, 'contracts')
voting_contract_location = os.path.join(contracts_folder, 'Voting.sol')

# load our Solidity code into an object
with open(voting_contract_location) as file:
    source_code = file.readlines()

# compile the contract
compiled_code = compile_source(''.join(source_code))

# store contract_name so we keep our code DRY
contract_name = 'Voting'

# lets make the code a bit more readable by storing these values in variables
contract_bytecode = compiled_code[f'<stdin>:{contract_name}']['bin']
contract_abi = compiled_code[f'<stdin>:{contract_name}']['abi']

contract_factory = eth_provider.contract(
    abi=contract_abi,
    bytecode=contract_bytecode,
)

contract_constructor = contract_factory.constructor(VOTING_CANDIDATES)

transaction_hash = contract_constructor.transact(transaction_details)

transaction_receipt = eth_provider.getTransactionReceipt(transaction_hash)
contract_address = transaction_receipt['contractAddress']

contract_instance = eth_provider.contract(
    abi=contract_abi,
    address=contract_address,
    ContractFactoryClass=ConciseContract,
)
voting_options = contract_instance.getVotingOptions()
print("voting contract deployed successfully the voting options are: ", [Web3.toText(option) for option in voting_options])
print("the deployed contract address is:", contract_address)



