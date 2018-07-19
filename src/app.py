import time
from web3 import Web3, HTTPProvider, eth
from solc import compile_source
from web3.contract import ConciseContract
import os

VOTING_CANDIDATES = [b'Yes', b'No', b'I dont care']

my_provider = Web3.IPCProvider('/home/matyas/.ethereum/rinkeby/geth.ipc')


# open a connection to the local ethereum node
#http_provider = HTTPProvider('http://localhost:9545')
#eth_provider = Web3(http_provider).eth
test = Web3(my_provider).eth

default_account = eth_provider.accounts[5]

transaction_details = {
    'from': default_account,
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



