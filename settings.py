import os
project_directory =os.path.dirname(os.path.abspath(__file__))
listabierta_project_directory = os.path.abspath(os.path.join(project_directory, os.pardir))
RINKEBY_SOCKET_FILE_PATH = '/tmp/rinkeby/geth.ipc'
MAINNET_SOCKET_FILE_PATH = ''
NETWORK_TO_USE = 'rinkeby'  # choose between 'local' --> ganache (use this if you are developing with truffle and start
# the local blockchain with truffle develop) 'in_memory_test_rpc' --> simple in memory blockchain (use this if you are
# not using truffle to start the development blockchain)  or 'rinkeby' --> rinkeby testnet
CONTRACTS_FOLDER = contracts_folder = os.path.join(os.path.join(project_directory, 'truffle_project'), 'contracts')
PROVIDER_RATINGS_CONTRACTS_FOLDER = os.path.join(os.path.join(project_directory, 'provider_ratings'), 'contracts')
CONTRACTS_ABI_FOLDER = os.path.join(
    os.path.join(os.path.join(project_directory, 'truffle_project'), 'build'), 'contracts')


ETHER_WALLET_ID_TO_USE = 0
LISTABIERTA_CONTRACTS_FOLDER = os.path.join(os.path.join(listabierta_project_directory, 'provider_ratings'), 'contracts')

UPGRADABLE_VOTING_PROXY_SMART_CONTRACT_ADDRESS = '0xbb60d495d500100c0be856d6d5cbea3b00fa07ac'
PROVIDER_RATING_CONTRACT_EXISTING_ON_BLOCKCHAIN = False
PROVIDER_RATING_CONTRACT_ADDRESS = '0x8DA7eB4Ec3A4c1291797e13DB723f9046afF4a1C'

LISTABIERTA_VOTING_CONTRACT_EXISTING_ON_BLOCKCHAIN = True
LISTABIERTA_VOTING_CONTRACT_ADDRESS = '0x2cF2Ef6bb8094E45ac591712B7F3E620C713cabf'
