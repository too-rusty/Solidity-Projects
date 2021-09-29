## What i learned while making this contract

lets say our Contract is Lottery

deploy : lottery = Lottery.deploy({'from':account})

view functions: lottery.some_func.call(param1, param2 ...., {'from':account})

transact: lottery.some_func(param1, param2, {'from':account})

sending value: lottery.some_func(params, {'from':account, 'value':value})

learnt to test on local development
some functionalities like oracle price feeds are available on mainnet fork

mainnet fork is a copy of mainnet where we can play with our eth and at the same time some deployed contracts are present
have a function that returns contracts on the basis of networks , network.show_active()

use mocks wherever required to mock the values

use event emission to get some values etc

accounts.add(private_key) can be used to add a metamask account which can be later used to test on rinkeby or something
use corresponding network params for eth, rinkeby, polygon , bsc

for mainnet fork use alchemy or maybe even infura does the trick !!

either use interfaces for using the functionalities, for that we need contract address only

or use Contract.from_abi(name, address, abi)

how to get the abi, use the Contract name ( actual contarct name )

Lottery[-1].abi

here after deployment for all the contracts , we can get the latest deployment as `Lottery[-1]`

for any contract defined, after deployment, we can get the latest version as A[-1] where A is the contract

for any transaction, better to wait for that transaction to finish , tx.wait(1) , maybe this is the number of blocks we need to wait
for the txn to finish

use mixes for some default easy functionalities
