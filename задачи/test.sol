pragma solidity >=0.6.6 <0.8.0;

contract Casino {

    uint16 private gamblersLimit;
    uint256 private totalSum;
    address private owner;
    mapping (address => uint256) private gambles;
    address[] private gamblers;
    bool isBetEven;
    address payable[] private winners;

    //event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner!");
        _;
    }

    constructor() public{
        owner = msg.sender; //msg.sender is the sender of the current call (address)
        emit OwnerSet(address(0), owner);
        totalSum = 0;
        gamblersLimit = 30;
        isBetEven = false;
    }

    function bet() public payable {
        require(gamblers.length < gamblersLimit, "Gamblers limit reached!");

        address sender = msg.sender;
        uint256 value = msg.value;

        if(gambles[sender] > 0){
            gambles[sender] += value;
        }
        else {
            gambles[sender] += value;
            gamblers.push(sender);
        }

        totalSum += value;

        if(gamblers.length == gamblersLimit){
            executeGambleReturns();
        }
    }

    function getTime() public view returns(uint256){
        return block.timestamp;
    }

    function executeGambleReturns() private {
        if((totalSum + block.timestamp) % 2 == 0){
            isBetEven = true;
        }

        uint256 winSum = 0;
        uint256 amountToGet = 0;

        for(uint i=0; i < gamblers.length; i++){
            uint256 bet = gambles[gamblers[i]];

            if(bet % 2 == 0 && isBetEven){
                winners.push(payable(gamblers[i]));
            }
            else if(bet % 2 != 0 && !(isBetEven)){
                winners.push(payable(gamblers[i]);)
            }
            else{
                winSum += bet;
            }
        }

        amountToGet = winSum / winners.length;

        for(uint i=0; i < winners.length; i++){
            winners[i].transfer(gambles[winners[i]] + amountToGet);
        }

        resetState();
    }

    function resetState() private {
        gamblersLimit = 30;
        totalSum = 0;

        for(uint i=0; i < gamblers.length; i++){
            gambles[gamblers[i]] = 0;
        }

        isBetEven = false;

        delete gamblers;
        delete winners;
    }

    function getTotalSum() external view returns(uint256){
        return totalSum;
    }

    function getNumberofGamblers() external view returns(uint256) {
        return gamblers.length;
    }

    function getmyBalance() external view returns(uint256){
        return gambles[msg.sender];
    }

    function changeLimit(uint16 _newLimit) external isOwner{
        gamblersLimit = _newLimit;
    }

    function getLimit() external view returns(uint16) {
        return gamblersLimit;
    }

    function changeOwner(address _newOwner) public isOwner {
        emit OwnerSet(owner, _newOwner);
        owner = _newOwner;
    }

    function getOwner() external view returns(address){
        return owner;
    }
}