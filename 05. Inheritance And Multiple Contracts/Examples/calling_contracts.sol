pragma solidity >=0.4.22 <0.6.0;

contract MathHelper{
    function add(uint a, uint b) pure public returns (uint);
}

contract MathUser{
    MathHelper public math;
    uint public lastRes;
    
    constructor (address mathHelper) public {
        //math = new MathHelper() -> error, no implementation
        math = MathHelper(mathHelper);
    }
    
    function work() public {
        uint n = 3;
        uint m = 4;
        
        lastRes = math.add(n, m);
    }
    
    function temporaryContract(address mathHelper) public {
        
        lastRes = MathHelper(mathHelper).add(7, 8);
    }
}
