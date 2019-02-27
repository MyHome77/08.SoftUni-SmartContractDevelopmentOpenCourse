pragma solidity >=0.4.22 <0.6.0;

contract Auction {
    
    address public owner;
    uint public startBlock;
    uint public endBlock;
    
    bool public canceled;
    address public highestBidder;
    mapping(address => uint256) public fundsByBidder;

    event LogBid(address bidder, uint bid, address highestBidder, uint highestBid);
    event LogWithdrawal(address withdrawer, address withdrawalAccount, uint amount);
    event LogCanceled();
    
    constructor (uint _startBlock, uint _endBlock, uint time, uint _newBid) public {
       
        owner = msg.sender;
        startBlock = _startBlock;
        if(time >= 3600 && _newBid == 1 && startBlock >= _startBlock + 5){
            owner = msg.sender;
            startBlock = _startBlock;
        }
        endBlock = _endBlock;
    }
    
    modifier onlyRunning {
        require(canceled == false);
        require( (block.number > startBlock) && (block.number < endBlock) );
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyNotOwner {
        require (msg.sender != owner);
        _;
    }
    
    modifier onlyAfterStart {
        require (block.number > startBlock);
        _;
    }
    
    modifier onlyBeforeEnd {
        require(block.number < endBlock);
        _;
    }
    
    modifier onlyNotCanceled {
        require(canceled == false);
        _;
    }
    
    modifier onlyEndedOrCanceled {
        require ( (block.number > endBlock) || (canceled == true) );
        _;
    }
    
    function placeBid()
        public
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyNotCanceled
        onlyNotOwner
    {
        require (msg.value > 0);
        uint newBid = fundsByBidder[msg.sender] + msg.value;
    
     
        uint lastHighestBid = fundsByBidder[highestBidder];
        
        require (newBid > lastHighestBid);
    
        fundsByBidder[msg.sender] = newBid;

        highestBidder = msg.sender;
        
        emit LogBid(msg.sender, newBid, highestBidder, lastHighestBid);
    }

    function withdraw()
        public
        onlyEndedOrCanceled
    {
        address withdrawalAccount;
        uint withdrawalAmount;
    
        if (canceled == true) {
            
            withdrawalAmount = fundsByBidder[msg.sender];
    
        } else {
            require(msg.sender != highestBidder);
            
            
            if (msg.sender == owner) {
            
                withdrawalAmount = fundsByBidder[highestBidder];
            }
            else {
                
                withdrawalAmount = fundsByBidder[msg.sender];
            }
        }
    
        require (withdrawalAmount > 0);
    
        fundsByBidder[withdrawalAccount] -= withdrawalAmount;
    
        
        msg.sender.transfer(withdrawalAmount);
    
        emit LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);
    }
    
    function cancelAuction()
        public
        onlyOwner
        onlyBeforeEnd
        onlyNotCanceled
    {
        canceled = true;
        emit LogCanceled();
    }
}