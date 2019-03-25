import os
NETWORK_TO_USE = 'in_memory_test_rpc'
project_directory = os.path.dirname(os.path.abspath(__file__))
listabierta_project_directory = project_directory # os.path.abspath(os.path.join(project_directory, os.pardir))
CONTRACTS_FOLDER = contracts_folder = os.path.join(os.path.join(project_directory, 'truffle_project'), 'contracts')
PROVIDER_RATINGS_CONTRACTS_FOLDER = os.path.join(os.path.join(project_directory), 'contracts')
CONTRACTS_ABI_FOLDER = os.path.join(
    os.path.join(os.path.join(project_directory, 'truffle_project'), 'build'), 'contracts')
LISTABIERTA_CONTRACTS_FOLDER = os.path.join(os.path.join(listabierta_project_directory), 'contracts')
