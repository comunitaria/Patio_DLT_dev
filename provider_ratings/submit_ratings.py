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
    return int(hashlib.sha256(hash_base).hexdigest(), 16) % 10**8


# https://docs.python.org/3/library/stdtypes.html#int.to_bytes
def int_to_bytes(x):
    return x.to_bytes((x.bit_length() + 7) // 8, 'big')


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

if not settings.PROVIDER_RATING_CONTRACT_EXISTING_ON_BLOCKCHAIN:

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
else:
    print("Found existing smart contract deployed at: {}".format(settings.PROVIDER_RATING_CONTRACT_ADDRESS))
    provider_rating = w3.eth.contract(
        address=settings.PROVIDER_RATING_CONTRACT_ADDRESS,
        abi=contract_abi
    )

PROVIDER_NAME = b'Endesa121unique'
PROVIDER_POSTAL_ADDRESS = b'Calle Pacheco y Nunez del Prado 55b bajo izquierda'
PROVIDER_IDENTIFICATION_NUMBER = b'Y4581880H'
SURVEY_KEY_FOR_RATING = b'1234567'
PROVIDER_SCORE = 3
assert(0 <= PROVIDER_SCORE <= 5)
PROVIDER_COMMENT = b'new comment'
# we perform this operation (generating the hash) on the client side because it is faster and
# recommended to perform such operation on the client side in order to save gas costs)
HASH_OF_PROVIDER_NAME_AND_SURVEY_KEY = int_to_bytes(
    generate_8_digit_hash_out_of_provider_name_and_survey_key(PROVIDER_NAME, SURVEY_KEY_FOR_RATING))
print("creating an example rating now:")
try:
    tx_hash = provider_rating.functions.rateProvider(SURVEY_KEY_FOR_RATING, HASH_OF_PROVIDER_NAME_AND_SURVEY_KEY,
                                                 PROVIDER_NAME, PROVIDER_POSTAL_ADDRESS, PROVIDER_IDENTIFICATION_NUMBER,
                                                 PROVIDER_SCORE, PROVIDER_COMMENT).transact()

    w3.eth.waitForTransactionReceipt(tx_hash)
    number_of_existing_ratings = provider_rating.functions.getNumberOfRatingsSaved().call()
    for i in range(0, number_of_existing_ratings):
        rating_hash = provider_rating.functions.getRatingHashAtIndex(i).call()
        # c = provider_rating.functions.getRatingAuthorKeyForRatingHash(rating_hash).call()
        rating_comment = provider_rating.functions.getRatingCommentForRatingHash(rating_hash).call()
        print('retrieved saved rating with hash: {} rating comment: {}'.format(rating_hash, rating_comment))

    ratings = provider_rating.functions.getRatingsForProvider(PROVIDER_IDENTIFICATION_NUMBER).call()
    print(ratings)

except ValueError as e:
    print(e)
    print("failed to submit transaction this should only happen if you try to submit a providername and surveykey "
          "that already was already used to uniquely identify a Rating")



