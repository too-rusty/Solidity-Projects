const EtherSender = artifacts.require('EtherSender');
const EtherReceiver = artifacts.require('EtherReceiver');

contract('something2', (accounts) => {
    let sender, receiver;
    before(async () => {
        // deploy both of them
        sender = await EtherSender.new();
        receiver = await EtherReceiver.new();
    });

    it('Should send and receive via call', async () => {
        const receiver_address = receiver.address;
        await sender.sendEtherViaC(receiver_address, {from: accounts[0], value:1_000});
        const balance = await web3.eth.getBalance(receiver_address)
        assert(parseInt(balance) === 1000);
    })

    it('Should send and receive via call', async () => {
        receiver = await EtherReceiver.new();
        // new instance , why use the older one
        const receiver_address = receiver.address;
        await sender.sendEtherViaT(receiver_address, {from: accounts[0], value:1_000});
        const balance = await web3.eth.getBalance(receiver_address)
        // assert(parseInt(balance) === 2000);
        assert(parseInt(balance) === 1000);
    })


});
