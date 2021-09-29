pragma solidity ^0.6.0;

import '@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@chainlink/contracts/src/v0.6/VRFConsumerBase.sol';

contract Lottery is Ownable, VRFConsumerBase{
    // constructor() public {}
    address payable[] public players;
    address payable public recentWinner;
    uint256 public randomness;
    uint256 public entranceFee;
    AggregatorV3Interface internal priceFeed;
    
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING_WINNER }
    LOTTERY_STATE public lottery_state;
    uint256 public fee;
    bytes32 public keyHash;
    event RequestRandomness(bytes32 requestId);

    constructor(
        address _priceFeed,
        address _vrfCoordinator,
        address _link,
        uint256 _fee,
        bytes32 _keyHash
    ) public VRFConsumerBase(_vrfCoordinator, _link) {
        entranceFee = 50 * (10 ** 18);
        priceFeed = AggregatorV3Interface(_priceFeed);
        fee = _fee;
        keyHash = _keyHash;
        lottery_state = LOTTERY_STATE.CLOSED;
    }
    function enter() public payable {
        // 50$ min
        require(
            lottery_state == LOTTERY_STATE.OPEN,
            'can take part only when lottery state is open'
        );
        require(msg.value >= getEntranceFee(), 'not enough eth');
        players.push(msg.sender);
    }
    
    function getEntranceFee() public returns (uint256) { 
        ( , int price , , , ) =  priceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10 ** 10; // because feed has 8 decimals
        uint256 entranceFeeInETH = (entranceFee * 10 ** 18 ) / adjustedPrice;
        // adjusted price has 10 decimals, we multiply with 10 ** 18 because 
        /*
        2000$ -> 1 eth
        1$ -> 1/2000 eth
        50$ -> 50/2000 eth = x -> x * 10**18 wei, the actual price we want
        */
        return entranceFeeInETH;

    }
    function startLottery() public onlyOwner {
        require(lottery_state == LOTTERY_STATE.CLOSED);
        lottery_state = LOTTERY_STATE.OPEN;
    }
    function endLottery() public onlyOwner {
        // uint256(
        //     keccak256(
        //         abi.encodePacked(
        //             nonce,
        //             msg.sender,
        //             block.difficulty,
        //             block.timestamp
        //         )
        //     )
        // ) % players.length;
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        bytes32 requestId = requestRandomness(keyHash, fee);
        emit RequestRandomness(requestId);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER);
        require(_randomness > 0);
        uint256 index = _randomness % players.length;
        recentWinner = players[index];
        recentWinner.transfer(address(this).balance);
        //reset the lottery
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
    }
}