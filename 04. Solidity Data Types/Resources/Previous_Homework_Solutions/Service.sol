pragma solidity >=0.4.22 <0.6.0;


contract Service{
    event LogServiceBought(address indexed by, uint timestamp);
    
    uint lastBuy = 0;
    uint lastWithdraw = 0;
    
    address payable owner;
    
    modifier serviceLock{
        require(now > lastBuy + 2 minutes);
        _;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    modifier withdrawLock{
        require(now > lastWithdraw + 1 hours);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function buy() public payable serviceLock {
        require(msg.value >= 1 ether);
        
        lastBuy = now;
        emit LogServiceBought(msg.sender, now);
        
        uint amountToReturn = msg.value - 1 ether;
        if(amountToReturn > 0){
            msg.sender.transfer(amountToReturn);
        }
    }
    
    function withdraw(uint value) public onlyOwner withdrawLock {
        require(value <= 5 ether);
        require(address(this).balance >= value);
        
        lastWithdraw = now;
        
        owner.transfer(value);
    }
}
