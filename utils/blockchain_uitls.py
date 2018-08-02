from web3 import Web3, HTTPProvider
from pathlib import Path
import os
import settings
from solc import compile_source


def get_eth_provider(provider_name):

    # open a connection to a local ethereum node (ganache geth or simple in memory blockchain)
    eth_providers = {
        'local': HTTPProvider('http://localhost:9545'),
        'rinkeby': Web3.IPCProvider(os.path.join(str(Path.home()), '.ethereum/rinkeby/geth.ipc')),
        'in_memory_test_rpc': Web3.TestRPCProvider()
    }

    return eth_providers[provider_name]


def get_compiled_code(contract_name):
    contract_location = os.path.join(settings.CONTRACTS_FOLDER, contract_name)
    with open(contract_location) as file:
        source_code = file.readlines()
    compiled_code = compile_source(''.join(source_code))

    return compiled_code


def get_contract_bytecode(compiled_contract_code, contract_name):
    """
    :param compiled_contract_code: compiled code of the smart contract
    :param contract_name: the contract file name including file extension
    :return:
    """
    contract_name_without_extension = os.path.splitext(contract_name)[0]
    contract_bytecode = compiled_contract_code[f'<stdin>:{contract_name_without_extension}']['bin']
    return contract_bytecode


def get_contract_abi(compiled_contract_code, contract_name):
    """
    :param compiled_contract_code: compiled code of the smart contract
    :param contract_name: the contract file name including file extension
    :return:
    """
    contract_name_without_extension = os.path.splitext(contract_name)[0]
    contract_abi = compiled_contract_code[f'<stdin>:{contract_name_without_extension}']['abi']
    return contract_abi

