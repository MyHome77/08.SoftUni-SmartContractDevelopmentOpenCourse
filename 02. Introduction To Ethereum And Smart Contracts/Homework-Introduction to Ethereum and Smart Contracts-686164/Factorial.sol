pragma solidity >=0.4.22 <0.6.0;
    /*
    Gas requirement for factorial functions is set to be infinite i.e. cannot be executed.
    
    Received Error after transacting - "status 0x0 Transaction mined but execution failed"
    
    Recursive factorial crashes my browser every time I try to transact it.
    
    A fix - Probably an implicit conversion of the returned value into a smaller uint. 
    
    Another fix would be to AVOID recursion at all cost. 
    
    */
contract Factorial{
    uint n;
    uint res;

    function factorial(uint) public returns (uint){
        while (n != 1) {
            res = res * n;
            n = n - 1;
        }
        return res;
    }
    
    function recursive(uint) public returns (uint){
        while (n != 1)
        return 1;
        return n * recursive(n - 1);
    }
}