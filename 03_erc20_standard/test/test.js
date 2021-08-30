const Token = artifacts.require('Token')

contract('ERC20token', (accounts) => {
    let token;
    beforeEach(async () => {
        token = await Token.new('My token', 'TKN', 18 , 1000)
    })

    it('should have the current decimals', async () => {
        let decimals = await token.decimals();
        assert(decimals == 18);
    })

    it('should have the correct name', async () => {
        let name = await token.name()
        assert(name == 'My token');
    })

    it('should have the correct ticker', async () => {
        let name = await token.symbol()
        assert(name == 'TKN');
    })


    it('should transfer', async () => {
        const owner_balance = await token.balanceOf(accounts[0])
        assert(parseInt(owner_balance) == 1000, 'balance not 1000');
        await token.transfer(accounts[1], 100);
        assert(parseInt(await token.balanceOf(accounts[1])) == 100, 'bal not 100');
        assert(parseInt(await token.balanceOf(accounts[0])) == 900, 'bal not 900');
    })

    it('should approve and transfer', async () => {
        await token.approve(accounts[1], 100);
        await token.transferFrom(accounts[0], accounts[2], 100, {from:accounts[1]})
        assert(parseInt(await token.balanceOf(accounts[2])) == 100, 'bal not 100');
        assert(parseInt(await token.balanceOf(accounts[0])) == 900, 'bal not 900');
    })

})