import os
import json
from microservice import settings
dir_path = os.path.dirname(os.path.realpath(__file__))
truffle_project = os.path.join(dir_path, 'truffle_project')
network_used_in_configuration = settings.NETWORK_TO_USE
zos_config_file_name = 'zos.{}.json'.format(network_used_in_configuration)
zos_json_config = os.path.join(truffle_project, zos_config_file_name)
with open(zos_json_config) as json_file:
    zos_config = json.load(json_file)
    latest_voting_proxy = zos_config['proxies']['Voting'][-1]
    voting_smart_contract_address = latest_voting_proxy['address']
