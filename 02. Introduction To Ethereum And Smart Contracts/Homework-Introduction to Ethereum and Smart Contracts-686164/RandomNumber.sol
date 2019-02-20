pragma solidity >=0.4.22 <0.6.0;
contract Random{
    /*
    A probable solution would be to use some of the given data by "block." and "msg."
    and combine them into a 
    
    Even if using any of the given values i.e. block. and msg. there are 
    problems with the uniqueness of the function. 
    
    */
    uint result;
    uint difficulty = block.difficulty;
    uint public value = msg.value;
    uint gas = gasleft();
    
    function random() public returns (uint){
        result = difficulty * value * gas;
        return result;
    }
}