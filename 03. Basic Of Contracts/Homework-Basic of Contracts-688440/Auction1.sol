pragma solidity >=0.4.22 <0.6.0;

contract Auction {
    
    address public owner;
    
    uint public startBlock;
    uint public endBlock;
    uint public step;
    
    bool public canceled;
    address public highestBidder;
    mapping(address => uint256) public fundsByBidder;
    mapping(address => uint256) public fundsByBidderBlTimestamp;

    event LogBid(address bidder, uint bid, address highestBidder, uint highestBid);
    event LogWithdrawal(address withdrawer, address withdrawalAccount, uint amount);
    event LogCanceled();
    
    constructor (uint _startBlock, uint _step) public {
        require(_startBlock <= endBlock);
        require(_startBlock <= block.number);
        step = _step;
        owner = msg.sender;
        startBlock = _startBlock;
        endBlock = block.number+1000;
    }
    
    modifier onlyRunning {
        require(canceled == false);
        require( (block.number > startBlock) && (block.number < endBlock),'2' );
        _;
    }
    
    
    modifier timePlacePeriod(){
        require (fundsByBidderBlTimestamp[msg.sender]+3600<=block.timestamp, '6');
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner,'1');
        _;
    }
    
    modifier onlyNotOwner {
        require (msg.sender != owner,'3');
        _;
    }
    
    modifier onlyAfterStart {
       require (block.number >= startBlock,'2');
        _;
    }
    
    modifier onlyBeforeEnd {
        require(block.number <= endBlock,'4');
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
        timePlacePeriod
    {
        // reject payments of 0 ETH
        require (msg.value > 0);
      
 	
    
        // calculate the user's total bid based on the current amount they've sent to the contract
        // plus whatever has been sent with this transaction
        uint newBid = fundsByBidder[msg.sender] + msg.value;
        
        
        //timestamp stored 
    
        fundsByBidderBlTimestamp[msg.sender]= block.timestamp;
    
        // get the current highest bid
        uint lastHighestBid = fundsByBidder[highestBidder];
        
        // if the user isn't even willing to overbid the highest bid, there's nothing for us
        // to do except revert the transaction.
        require (newBid >= lastHighestBid+step);
    
        // update the user bid
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
            // if the auction was canceled, everyone should simply be allowed to withdraw their funds
            withdrawalAmount = fundsByBidder[msg.sender];
            withdrawalAccount = msg.sender;
    
        } else {
            // highest bidder won the auction, so he cannot withdraw his money
            require(msg.sender != highestBidder);
            
            // the auction finished without being canceled
            if (msg.sender == owner) {
                // the auction's owner should be allowed to withdraw the highestBid
                withdrawalAmount = fundsByBidder[highestBidder];
            }
            else {
                // anyone who participated but did not win the auction 
                // should be allowed to withdraw
                // the full amount of their funds
                withdrawalAmount = fundsByBidder[msg.sender];
            }
        }
    
        require (withdrawalAmount > 0);
    
        fundsByBidder[withdrawalAccount] -= withdrawalAmount;
    
        // send the funds
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