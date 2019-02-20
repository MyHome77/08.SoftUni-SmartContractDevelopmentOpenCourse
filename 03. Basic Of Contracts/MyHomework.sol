pragma solidity >=0.4.22 <0.6.0;

contract Auction {
    
    address public owner;
    uint public startBlock;
    uint public endBlock;
    uint public margin;
    uint public placeBidTime;
    bool cancelled;
    
    
    address public highestBidder;
    mapping(address => uint) public fundsByBidder;
    mapping(address => uint) public placeBidTimeByBidder;
    
    event LogBid(address bidder, uint bid, address highestBidder, uint highestBid);
    event LogCanceled();
    event LogWithdraw(address withdrawer, address withdrawAccount, uint withdrawAmount);
    
    constructor(uint _startBlock, uint _endBlock, uint margin) public{
        require(_startBlock <= _endBlock);
        owner = msg.sender;
        startBlock = _startBlock;
        endBlock = _endBlock;
        margin = 5;
    }
    
    modifier onlyAfterStart{
        require(block.number > startBlock, "Auction is not started!");
        _;
    }
    modifier onlyBeforeEnd{
        require(block.number < endBlock, "Auction is not ended!");
        _;
    }
    modifier onlyOwner{
        require(owner == msg.sender,"Only owner can change the function!");
        _;
    }
    
    modifier onlyNotOwner{
        require(owner != msg.sender,"Anybody can change the function except owner!");
        _;
    }
    
    modifier onlyRunning{
        require(cancelled == false,"Auction is cancelled!");
        require((startBlock <= block.number) && (endBlock >= block.number),"Auction is expited!");
        _;
    }
    
    modifier onlyNotCancelled{
        require(cancelled == false,"Auction is not cancelled!");
        _;
    }
    
    modifier onlyEndedOrCancelled{
        require(cancelled == true || block.number > endBlock,"Auction is not ended or cancelled!");
        _;
    }
    
    modifier onlyMinimumBid{
        require(fundsByBidder[highestBidder] < msg.value + margin,"Minimum bid must be at least 5 greater than the highest bid!");
        _;
    }
    
    modifier onlyAfterOneHour{
        require(block.timestamp > placeBidTimeByBidder[msg.sender] + 1 hours,"Next bid must be made after 1 hour after latest bid!");
        _;
    }
    
    function placeBid() public payable onlyAfterStart onlyBeforeEnd onlyNotCancelled onlyNotOwner onlyMinimumBid{
        require(msg.value > 0, "Value must be greater then 0!");
        
        uint newBid = fundsByBidder[msg.sender] + msg.value;
        uint lastHighestBid = fundsByBidder[highestBidder];
        
        require(newBid > lastHighestBid,"Current bid must be greater than the highest bid!");
        
        fundsByBidder[msg.sender] = newBid;
        highestBidder = msg.sender;
        
        placeBidTime = now;
        placeBidTimeByBidder[msg.sender] = placeBidTime;
        
        emit LogBid(msg.sender, newBid, highestBidder, lastHighestBid);
    }
    
    function cancelAuction() public onlyOwner onlyBeforeEnd onlyNotCancelled{
        cancelled = true;
        emit LogCanceled();
    }
    
    function withdraw() public payable onlyEndedOrCancelled{
        address withdrawAccount = msg.sender;
        uint withdrawAmount;
        
        if(cancelled){
            withdrawAmount = fundsByBidder[msg.sender]; 
        } else {
            require(msg.sender != highestBidder,"Winner cannot withdraw funds!");
            
            if(msg.sender == owner){
                withdrawAmount = fundsByBidder[highestBidder];
				withdrawAccount = owner;
            } else {
                withdrawAmount = fundsByBidder[msg.sender];
            }
        }
        require(withdrawAmount > 0,"Withdraw amount should be greater than 0!");
        
        fundsByBidder[msg.sender] -= withdrawAmount;
        
        msg.sender.transfer(withdrawAmount);
        
        emit LogWithdraw(msg.sender, withdrawAccount, withdrawAmount);
    }
}

contract ServiceMarketplace {
    
    address public owner;
    uint public serviceCost;
    uint public revenue;
    uint public lastPurchaseTime;
    uint public lastWithdrawTime;
    
    event LogBoughtService(address buyer, uint serviceCost, uint difference, uint lastPurchaseTime);
    event LogWithdraw(uint amount, uint widthrawTime);
    
    constructor() public{
        owner = msg.sender;
        serviceCost = 1;
    }
    
    modifier onlyAmountsEqualOrGreaterThanServiceCost{
        require(msg.value >= serviceCost, "Amount must be greater than 1!");
        _;
    }
    
    modifier onlyAfterTwoMinutes{
        require(lastPurchaseTime + 2 minutes > now, "Last purchase was made less than 2 minutes ago!");
        _;
    }
    
    modifier onlyOncePerHour{
        require(lastWithdrawTime + 1 hours > now, "Last widthraw was made less than 1 hour ago!");
        _;
    }
    
    modifier onlyMaximumAmount{
        require(msg.value <= 5, "Maximum widthraw amount is 5");
        _;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner, "Only owner can withdraw funds!");
        _;
    }
    
    function buyService() public payable onlyAmountsEqualOrGreaterThanServiceCost onlyAfterTwoMinutes{
        uint difference = msg.value - serviceCost;
        if(difference > 0){
            msg.sender.transfer(difference);
        }
        
        revenue += serviceCost;
        lastPurchaseTime = now;
        
        emit LogBoughtService(msg.sender, serviceCost, difference, lastPurchaseTime);
    }
    
    function withdraw(uint amount) public payable onlyOwner onlyOncePerHour onlyMaximumAmount{
        revenue -= amount;
        msg.sender.transfer(amount);
        lastWithdrawTime = now;
        
        emit LogWithdraw(amount,lastWithdrawTime);
    }
}