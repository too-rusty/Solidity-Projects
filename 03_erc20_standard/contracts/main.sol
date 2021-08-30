// SPDX : MIT LICENSE

pragma solidity ^0.8.0;

contract Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;

    mapping(address => uint) public balances;
    mapping(address => mapping ( address => uint ) )  public allowed;

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        _mint(_totalSupply);
    }

    function _mint(uint amount) internal {
        balances[msg.sender] = amount;
    }

    function transfer(address _to, uint _amount) public returns(bool) {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
        /*
        returning a true value, what is the usecase here ?
        we can call a function as a txn or as a call
        calling a func as a txn modifies the blockchain
        calling as a call would tell us whether a txn would work or not
        if it is working , we can actually send the txn and save some gas
        by not sending the txn if it is gonna fail
        TODO cant RETURN A VALUE ACTUALLY WHEN TXN
        */
    }

    function transferFrom(address from, address to, uint amount) public returns (bool) {
        require ( allowed[from][msg.sender] >= amount , "amount not approved");
        require ( balances[from] >= amount, "not enough balance");
        allowed[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint amount) public returns (bool) {
        require ( spender != msg.sender , "cannot approve to oneself");
        require ( balances[msg.sender] >= amount ) ; // NOT NEEDED , checked in transfer
        allowed[msg.sender][spender] = amount;
        // value is overwritten
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return allowed[owner][spender];
    }

    function balanceOf(address owner) public view returns (uint) {
        return balances[owner];
    }


}