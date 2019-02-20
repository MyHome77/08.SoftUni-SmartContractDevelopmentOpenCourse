contract ContractOwnership {
    
    event OnlyOwnerEvent(address who);
    event OwnerChange(address oldOwner, address newOwner);
    address public owner;
    timestamp currentTime;
  
  constructor() public{
      owner = msg.sender;
      currentTime = block.timestamp;
  }
  
  modifier onlyOwner{
      require(msg.sender == owner, "Only the owner can execute function");
      _;
  }
  
  function ChangeOwner(address newOwner) public{
      emit OnlyOwnerEvent(msg.sender);
      address currentOwner = owner;
      owner = newOwner;
      emit OwnerChange(currentOwner, newOwner);
  }
  
  function AcceptOwnership(address owner) public{
      emit OnlyOwnerEvent(owner);
  }
}