pragma solidity >=0.4.22 <0.6.0;

contract Owned {
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier OnlyOwner{
        require(msg.sender == owner);
        _;
    }
}

contract SafeAddUint8 {
    //library that can safely add uint8s by checking for overflow
    function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        assert(c >= a);
        return c;
    }
}

//inheriting both contracts
contract OwnerCounter is Owned, SafeAddUint8{
    uint8 public counter;
    constructor() public {
        reset();
    }
    
    function reset() public {
        counter = 0;
    }
    
    function addToCounter(uint8 b) public OnlyOwner {
        counter = add(counter, b);
    }
}
