// LICENSE
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/*
anyone can deposit any token here for a fixed period
you can only increase the period/duration when depositing again

*/

contract Timelock {
    // tokenaddr -> useraddr -> amount
    mapping ( address => mapping ( address => uint ) ) private tokenbalances;
    mapping ( address => mapping ( address => uint ) ) private when;
    mapping ( address => mapping ( address => bool ) ) private init;
    // locked balances of tokens of users and when can they withdraw

    constructor () {}
// what is try catch and what is virtual
// ok so the guy calling the function is the spender, contract is the spender here
    function deposit(address token, uint amount, uint duration) external {
        // here caller is this contract and they cannot simply transfer
        // they need to transfer from
        require(
            IERC20(token).allowance(msg.sender, address(this)) >= amount,
            'low allowance'
        );
        address _owner = msg.sender;
        IERC20(token).transferFrom(_owner, address(this), amount);
        // should fail anyways so no need for assert
        tokenbalances[token][_owner] += amount;

        if (init[token][_owner]) {
            when[token][_owner] += duration;
        } else {
            init[token][_owner] = true;
            when[token][_owner] = block.timestamp + duration;
        }
    }

    function getbalance(address token) public view returns(uint) {
        return tokenbalances[token][msg.sender];
    }

    function gettime(address token) public view returns(uint) {
        return when[token][msg.sender];
    }

    receive() external payable {}

    function withdraw(address token, uint amount) external {
        address _owner = msg.sender;

        require(tokenbalances[token][_owner] >= amount, 'insufficient balance');
        require(block.timestamp >= when[token][_owner], 'too early');

        IERC20(token).transfer(_owner, amount);
        tokenbalances[token][_owner] -= amount;

    }
}

/*
FINALLY a simple expln



user can unlock his wallet and call "transfer" to transfer his/her own token, 
that's reasonable function

user cannot call "transferFrom" directly because otherwise he/she can use anyone else's 
token without the corresponding private key or wallet, that's totally unacceptable, 
so he need get approved by the original token owner 
to use a certain amount of their token

https://ethereum.stackexchange.com/questions/46457/send-tokens-using-approve-and-transferfrom-vs-only-transfer/46458



*/


contract Mocktoken1 is ERC20 {
    constructor () ERC20('Mocktoken1', 'MOCK1') {
        _mint(msg.sender, 2000 );
    }
}

contract Mocktoken2 is ERC20 {
    constructor () ERC20('Mocktoken2', 'MOCK2') {
        _mint(msg.sender, 2000 );
    }
}


/*
LEARNINGS
1. transfer can either transfer the tokens directly to the address
    ( gas used is the gas sent by the sender, which begs the question that gas
    for any txn / interaction with the contract is sent by the sender)
2. transfer can also transfer the tokens in the IERC20 context
    as transfer(receiver, amount) -> which internally calls _transfer(sender, receiver, amount)
3. trasferFrom also calls the _transfer function internally but requires approval
4. here , sender is the guy calling this function, when its a 3rd party contract
    its the contract itself so when a 3rd party contract is involved
    we approve the contract to transact on our behalf, with/without transferring the funds
    to ourselves
5. when we know we are the ones transferring stuff, we can directly call the transfer
    function, like we are doing here when withdrawing tokens
*/