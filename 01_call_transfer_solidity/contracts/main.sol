// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherReceiver {
    constructor () {}
    receive() external payable {}
    // the contract must have either receive or fallback ( for empty msg.data value )
}

contract EtherSender {
    function sendEtherViaC(address payable to) public payable {
        (bool sent, bytes memory data) = to.call{value: msg.value}("");
        require(sent, "failed to send");
        // so the gas used up by the sender is actually used up to send data
    }
    function sendEtherViaT(address payable to) public payable {
        to.transfer(msg.value);
    }
}
