from utils.blockchain_uitls import get_eth_provider
from utils.blockchain_uitls import get_compiled_code
from utils.blockchain_uitls import get_contract_abi
from utils.blockchain_uitls import get_contract_bytecode

import settings
from web3 import Web3
from web3.contract import ConciseContract
import hashlib


# https://stackoverflow.com/questions/16008670/python-how-to-hash-a-string-into-8-digits
def generate_8_digit_hash_out_of_provider_name_and_survey_key(provider_name, survey_key):
    hash_base = provider_name + survey_key
    return int(hashlib.sha256(hash_base.encode('utf-8')).hexdigest(), 16) % 10**8


compiled_contract = get_compiled_code('ProviderRating.sol')
contract_byte_code = get_contract_bytecode(compiled_contract, 'ProviderRating.sol')
contract_abi = get_contract_abi(compiled_contract, 'ProviderRating.sol')


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

# Instantiate and deploy contract
ProviderRating = w3.eth.contract(abi=contract_abi, bytecode=contract_byte_code)


# Submit the transaction that deploys the contract
tx_hash = ProviderRating.constructor().transact()

# Wait for the transaction to be mined, and get the transaction receipt
tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
print ( "Deployed. gasUsed={gasUsed} contractAddress={contractAddress}".format(**tx_receipt) )

# Create the contract instance with the newly-deployed address
provider_rating = w3.eth.contract(
    address=tx_receipt.contractAddress,
    abi=contract_abi,
)

PROVIDER_NAME = b'Endesa'
PROVIDER_POSTAL_ADDRESS = b'Calle Pacheco y Nunez del Prado 55b bajo izquierda'
PROVIDER_IDENTIFICATION_NUMBER = b'Y4581880H'
SURVEY_KEY_FOR_RATING = b'123446'
PROVIDER_SCORE = 7
assert(0 <= PROVIDER_SCORE <= 10)
PROVIDER_COMMENT = b'generalmente estaba muy contento con el servicio de Endesa'
# we perform this operation (generating the hash) on the client side because it is faster and
# recommended to perform such operation on the client side in order to save gas costs)
HASH_OF_PROVIDER_NAME_AND_SURVEY_KEY = generate_8_digit_hash_out_of_provider_name_and_survey_key(PROVIDER_NAME,
                                                                                                 SURVEY_KEY_FOR_RATING)
print("creating an example rating now:")
tx_hash = provider_rating.functions.rateProvider(SURVEY_KEY_FOR_RATING, HASH_OF_PROVIDER_NAME_AND_SURVEY_KEY,
                                                 PROVIDER_NAME, PROVIDER_POSTAL_ADDRESS, PROVIDER_IDENTIFICATION_NUMBER,
                                                 PROVIDER_SCORE, PROVIDER_COMMENT).transact()
w3.eth.waitForTransactionReceipt(tx_hash)


print(
    'getting rating info of the rating that I just '
    'created: {}'.format(provider_rating.functions.getRatingForProviderNameAndSurveyKeyHash(HASH_OF_PROVIDER_NAME_AND_SURVEY_KEY).call()))

