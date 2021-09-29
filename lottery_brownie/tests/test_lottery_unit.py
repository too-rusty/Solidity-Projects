
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, fund_with_link, get_account, get_contract
from scripts.deploy_lottery import deploy_lottery
from brownie import network, exceptions
from web3 import Web3
import pytest

def test_get_entrance_fee():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    # Arrage
    lottery = deploy_lottery()
    # Act
    expected_entrance_fee = Web3.toWei(0.025, 'ether')
    entrance_fee = lottery.getEntranceFee.call()
    # Assert
    assert expected_entrance_fee == entrance_fee


def test_cant_enter_unless_started():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    lottery = deploy_lottery()
    account = get_account()
    # Act / Assert
    with pytest.raises(exceptions.VirtualMachineError):
        lottery.enter({'from':account, 'value':lottery.getEntranceFee.call()})

def test_can_start_and_enter_lottery():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    account = get_account()
    lottery = deploy_lottery()
    tx = lottery.startLottery({'from':account})
    tx.wait(1)
    lottery.enter({'from':account, 'value':lottery.getEntranceFee.call()})
    assert lottery.players.call(0) == account
    # assert lottery.players.call()[0] == account

def test_can_end_lottery():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    account = get_account()
    lottery = deploy_lottery()
    tx = lottery.startLottery({'from':account})
    tx.wait(1)
    lottery.enter({'from':account, 'value':lottery.getEntranceFee.call()})
    fund_with_link(lottery.address)
    lottery.endLottery({'from':account})
    assert lottery.lottery_state.call() == 2

def test_can_pick_winner_correctly():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    lottery = deploy_lottery()
    account = get_account()

    tx = lottery.startLottery({'from':account})
    tx.wait(1)
    lottery.enter({'from':account, 'value':lottery.getEntranceFee.call()})
    lottery.enter({'from':get_account(index=1), 'value':lottery.getEntranceFee.call()})
    lottery.enter({'from':get_account(index=2), 'value':lottery.getEntranceFee.call()})
    fund_with_link(lottery.address)
    tx = lottery.endLottery({'from':account})
    requestId = tx.events['RequestRandomness']['requestId']
    start_balance = account.balance()
    balance_lottery = lottery.balance()
    get_contract('vrf_coordinator').callBackWithRandomness(
        requestId, 777, lottery.address, {'from':account}
    )
    
    assert lottery.recentWinner.call() == account
    assert lottery.balance() == 0
    assert account.balance() == start_balance + balance_lottery
    


# def main():
#     test_get_entrance_fee()