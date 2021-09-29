from brownie.network import account
import pytest
import time
from brownie import network
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, fund_with_link, get_account
from scripts.deploy_lottery import deploy_lottery

def test_can_pick_winner():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    lottery = deploy_lottery()
    account = get_account()
    lottery.startLottery({'from':account})
    lottery.enter({'from':account, 'value': lottery.getEntranceFee.call()})
    fund_with_link(lottery.address)
    end_tx = lottery.endLottery({'from':account})
    end_tx.wait(1)
    time.sleep(60)
    assert lottery.recentWinner.call() == account
    assert lottery.balance() == 0