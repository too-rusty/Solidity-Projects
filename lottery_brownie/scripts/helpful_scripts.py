from brownie import accounts, network, config, Contract
from brownie import MockV3Aggregator, VRFCoordinatorMock, LinkToken, interface

FORKED_LOCAL_ENVIRONMENTS = ['mainnet-fork', 'mainnet-fork-dev']
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ['development', 'ganache-local']
def get_account(index=None):

    if index:
        return accounts[index]
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS or
        network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    return accounts.add(config['wallets']['from_key'])


contract_to_mock = {
    'eth_usd_price_feed' : MockV3Aggregator,
    'vrf_coordinator' : VRFCoordinatorMock,
    'link_token': LinkToken,
}

def get_contract(contract_name: str):
    """
    This func will get contract address if defined or mock version deployed and returned
    args: contract name ( string )
    returns: most recently deployed contract
    """
    contract_type = contract_to_mock[contract_name]
    # if contract_name == 'link_token':
    #     if len(contract_type) == 0: deploy_mocks()
    #     contract = contract_type[-1]
    #     return contract
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(contract_type) == 0: deploy_mocks()
        contract = contract_type[-1]
    else:
        print(f'active network: {network.show_active()}')
        contract_address = config['networks'][network.show_active()][contract_name]
        contract = Contract.from_abi(contract_type._name, contract_address, contract_type.abi)
    return contract

DECIMALS = 8
INITIAL_VALUE = 2000 * (10 ** 8)

def deploy_mocks(initial_value=INITIAL_VALUE, decimals=DECIMALS):
    account = get_account()
    MockV3Aggregator.deploy(decimals,initial_value,{'from':account})
    link_token = LinkToken.deploy({'from':account})
    VRFCoordinatorMock.deploy(link_token.address, {'from':account})
    print('deployed')

def fund_with_link(contract_address, account=None, link_token_addr=None, amount=0.1*(10**18)):
    account = account if account else get_account()
    link_token_addr = link_token_addr if link_token_addr else get_contract('link_token').address
    link_token = get_contract('link_token')
    tx = link_token.transfer(contract_address, amount, {'from':account})
    tx.wait(1)
    # link_contract = interface.LinkTokenInterface(link_token_addr)
    # tx = link_contract.transfer(link_contract, amount, {'from':account})
    # tx.wait(1) # not working for some reason
    print(f'Funded contract {contract_address} with {amount} (wei) link tokens!')
    return tx
