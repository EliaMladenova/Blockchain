pragma solidity >=0.6.6 <0.8.0;

contract Casino {
    
    //Smart contract state (fields)
    bool isBetEven;
    address private owner;
    uint16 private gamblersLimit;
    uint256 private totalSum;
    mapping (address => uint256) private gambles;
    address[] private gamblers;
    address payable[] private winners;
    
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner); 
        totalSum = 0;
        gamblersLimit = 30;
        isBetEven = false;
        
    }
    
    /**
     * @dev Places a bet
     */
    function bet() public payable {
       require(gamblers.length < gamblersLimit, "Gamblers limit reached!");
       
       address sender = msg.sender;
       uint256 value = msg.value;
       
       if(gambles[sender] > 0){
            gambles[sender] += value;
       }
       else{
            gambles[sender] += value;
            gamblers.push(sender);
       }
       
       totalSum += value;
       
       if(gamblers.length == gamblersLimit){
           executeGambleReturns();
       }
    }
     
    /**
     * @dev Decides on winners and awards winnings
     */ 
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
                winners.push(payable(gamblers[i]));
            }
            else {
                winSum += bet;
            }
        }
        
        amountToGet = winSum / winners.length;
        
        for(uint i = 0; i< winners.length; i++ ){
            winners[i].transfer(gambles[winners[i]] + amountToGet);
        }
        
        resetState();
    }

    /**
     * @dev Resets smart contract state
     */
    function resetState() private {
        gamblersLimit = 30;
        totalSum = 0;
        
        for(uint i = 0; i< gamblers.length; i++ ){
            gambles[gamblers[i]] = 0;
        }
        
        isBetEven = false;
        
        delete gamblers;
        delete winners;
    }
    
    /**
     * @dev Return the total sum of all bets
     * @return total sum of all bets
     */
    function getTotalSum() external view returns(uint256){
        return totalSum;
    }
    
    /**
     * @dev Return the current number of gamblers that have placed a bet
     * @return number of players
     */
    function getNumberOfGamblers() external view returns(uint256){
         return gamblers.length;
    }
    
    /**
     * @dev Returns the current balance of a player
     * @return current balance
     */
    function getMyBalance() external view returns(uint256){
        return gambles[msg.sender];
    }
    
    /**
     * @dev Set new gamblrs limit
     * @param _newLimit the number of max gamblers
     */
    function changeLimit(uint16 _newLimit) external isOwner {
        gamblersLimit = _newLimit;
    }
    
    /**
     * @dev Return max number of players
     * @return limit of players
     */
    function getLimit() external view returns (uint16) {
        return gamblersLimit;
    }
    
    /**
     * @dev Change owner
     * @param _newOwner address of new owner
     */
    function changeOwner(address _newOwner) public isOwner {
        emit OwnerSet(owner, _newOwner);
        owner = _newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
    
}