
const { expectRevert, time, constants } = require('@openzeppelin/test-helpers')
const Timelock = artifacts.require('Timelock');
const Mocktoken1 = artifacts.require('Mocktoken1');
const Mocktoken2 = artifacts.require('Mocktoken2');

contract('something', (accounts) => {
    let timelock, mock1, mock2;
    beforeEach(async () => {
        // deploy token and timelock
        mock1 = await Mocktoken1.new({from:accounts[6]});
        mock2 = await Mocktoken2.new({from:accounts[7]});
        timelock = await Timelock.new();
    });

    it('should transfer mocktoken1 from account6 to account0', async () => {
        const bal = await mock1.balanceOf(accounts[6]);
        assert(parseInt(bal) == 2_000, "balance not 2000");
        await mock1.transfer(accounts[0], 100, {from:accounts[6]});
        assert(parseInt(await mock1.balanceOf(accounts[0])) ==  100);
    });

    it('should not deposit token without approval', async () => {
        // timelock
        timelock = await Timelock.new();

        let threw = false;
        await expectRevert(
            timelock.deposit(mock1.address, 10, 10, {from: accounts[6]}),
            'low allowance'
        );
    });


    it('should deposit token after approval', async () => {
        let threw = false;
        await mock1.approve(timelock.address, 100, {from:accounts[6]});
        const allowance = await mock1.allowance(accounts[6], timelock.address);
        assert(parseInt(allowance) == 100, 'allowance not 100');
        try { 
            await timelock.deposit(mock1.address,101,10, {from:accounts[6]});
        } catch (e) { 
            assert(e.message.includes('low allowance'), 'error message not correct');
            threw = true;
        }        
        assert(threw, 'exception not thrown');

    });

    it('should not withdraw tokens early or more than deposited', async () => {
        // const mock1 = await Mocktoken1.new({from:accounts[6]});
        // const timelock = await Timelock.new();

        await mock1.approve(timelock.address, 100, {from:accounts[6]});
        await timelock.deposit(mock1.address,100,10, {from:accounts[6]});

        await expectRevert(
            timelock.withdraw(mock1.address, 10, {from:accounts[6]}),
            'too early'
        )

        await expectRevert(
            timelock.withdraw(mock1.address, 1000, {from:accounts[6]}),
            'insufficient balance'
        )

    });

    it('should withdraw tokens after deposit', async () => {
        await mock1.approve(timelock.address, 100, {from:accounts[6]});
        await timelock.deposit(mock1.address, 100, 100, {from:accounts[6]});
        let threw = false;
        try {
            await timelock.withdraw(mock1.address, 100, {from:accounts[6]});
        } catch (e) {
            threw = true
            assert(e.message.includes('too early'), 'message is not too early');
        }
        assert(threw, 'exception should be thrown');
        await time.increase(time.duration.seconds(100));
        let balance = await mock1.balanceOf(accounts[6]);
        assert(parseInt(balance) == 1900, 'balance should be 1900');
        await timelock.withdraw(mock1.address, 100, {from:accounts[6]});
        balance = await mock1.balanceOf(accounts[6 ]);
        assert(parseInt(balance) == 2000, 'balance not 100');
    });

    it('should deposit and withdraw multiple tokens after transfer', async () => {
        await mock1.transfer(accounts[0], 100, {from:accounts[6]});
        await mock2.transfer(accounts[0], 100, {from:accounts[7]});

        assert(parseInt(await mock1.balanceOf(accounts[0])) == 100, "balance should be 100");
        assert(parseInt(await mock1.balanceOf(accounts[0])) == 100, "balance should be 100");

        await mock1.approve(timelock.address, 100, {from:accounts[0]});
        await mock2.approve(timelock.address, 90, {from:accounts[0]});
// by default txn is initiated from accounts[0]
        await timelock.deposit(mock1.address, 100, 1000); // no need for {from:accounts[0]}
        assert(parseInt(await mock1.balanceOf(accounts[0])) == 0, 'bal of acc0 m1 0');
        await timelock.deposit(mock2.address, 90, 2000);
        assert(parseInt(await mock2.balanceOf(accounts[0])) == 10, 'bal of acc0 m2 0');

        await time.increase(time.duration.seconds(1000));
        await timelock.withdraw(mock1.address, 100);
        const mock1balance = await mock1.balanceOf(accounts[0]);
        assert(parseInt(mock1balance) == 100, 'bal should be 100 again');

        let threw = false
        try {
            await timelock.withdraw(mock2.address, 100);
        } catch (e) {
            threw = true;
            assert(e.message.includes('insufficient balance'));
        }
        assert(threw, 'exception not thrown');

        threw = false
        try {
            await timelock.withdraw(mock2.address, 90);
        } catch (e) {
            threw = true;
            assert(e.message.includes('too early'));
        }
        assert(threw, 'exception not thrown');

        await time.increase(time.duration.seconds(1000));
        await timelock.withdraw(mock2.address, 90);
        const finalBalance = await mock2.balanceOf(accounts[0]);
        assert(parseInt(finalBalance) == 100, 'final balance should be 100');

    });


});

/*
Learnings

new starts a new contract so need to specify the sender of txn
but deployed runs the migration so no need to specify the sender
better to use beforeEach then ...

https://github.com/ethereum-optimism/Truffle-ERC20-Example/blob/master/test/erc20.spec.js

other nice tests and methods
*/