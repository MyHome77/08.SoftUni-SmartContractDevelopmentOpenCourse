pragma solidity >=0.4.22 <0.6.0;

contract Marketplace {
    
    address public owner;
    uint public buyTime;
    uint public withdrawTime;
    uint public paymentsSum;
    uint public ownerWithdraw;


    event LogBought(address Buyer, uint Pay);
    event LogExtraBack(address buyer, uint extra);
    event LogOwnerWithdraw(address owner, uint withdraw);
    
    constructor () public {
       owner = msg.sender;
       
    }
    modifier onlyNotOwner {
        require (msg.sender != owner,'3');
        _;
    }
    modifier buyAfterTime {
        require (block.timestamp>=buyTime+120,'4');
        _;
    }
    modifier onlyOwner {
        require (msg.sender == owner,'2');
        _;
    }
    modifier withdrawAfterTime {
        require (block.timestamp>=withdrawTime+3600,'1');
        _;
    }

     
    function buy()
        public
        payable
        buyAfterTime
        onlyNotOwner
  
    {
        // reject payments of 0 ETH
        require (msg.value/1000000000000000000 >= 1);
      
        // current amount user's payed        
        uint newPay = msg.value/1000000000000000000;
                                
     if (newPay>1){
       uint extra = newPay-1;
       newPay-=extra;
        // send the funds
        msg.sender.transfer(extra*1000000000000000000);

        emit LogExtraBack(msg.sender, extra*1000000000000000000);
     } 
     //take the buy time
     buyTime = block.timestamp;
     paymentsSum+=newPay*1000000000000000000
        emit LogBought(msg.sender, newPay*1000000000000000000);
    }
    
    function withdraw()
    public
    payable
    onlyOwner
    withdrawAfterTime
    {
     ownerWithdraw = msg.value/1000000000000000000;

     //check if owner want to withdraw more than 5 ETH;
     require(ownerWithdraw<=5);

    if (paymentsSum-msg.value>=0){
        paymentsSum-=msg.value;

    msg.sender.transfer(msg.value);
        emit LogOwnerWithdraw(msg.sender, msg.value);

     //take the withdraw time
     withdrawTime = block.timestamp;
    }

    }

}