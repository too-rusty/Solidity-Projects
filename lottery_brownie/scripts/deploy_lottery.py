
import time
from brownie import network, Lottery
from scripts.helpful_scripts import get_account, get_contract, config, fund_with_link


def deploy_lottery():
    account = get_account()
    lottery = Lottery.deploy(
        get_contract('eth_usd_price_feed').address,
        get_contract('vrf_coordinator').address,
        get_contract('link_token').address,
        config['networks'][network.show_active()]['fee'],
        config['networks'][network.show_active()]['key_hash'],
        {'from':account},
    )
    print(f'deployed lottery at {lottery.address}')
    return lottery


def start_lottery():
    account = get_account()
    lottery = Lottery[-1]
    tx = lottery.startLottery({'from':account})
    tx.wait(1)
    print('lottery started!')


def enter_lottery():
    account = get_account()
    lottery = Lottery[-1]
    fee = lottery.getEntranceFee.call()  # in wei
    print(f'entrance Fee is {fee}')
    tx = lottery.enter({'from':account, 'value':fee})
    tx.wait(1)
    print('entered the lottery!!')

def end_lottery():
    account = get_account()
    lottery = Lottery[-1]
    # fund the contract with some link token first because that is the fee
    tx = fund_with_link(lottery.address)
    tx.wait(1)
    end_tx = lottery.endLottery({'from':account})
    end_tx.wait(1)
    time.sleep(10)
    winner = lottery.recentWinner.call()
    print(f'random val is {winner}')


def main():
    deploy_lottery()
    start_lottery()
    enter_lottery()
    end_lottery()