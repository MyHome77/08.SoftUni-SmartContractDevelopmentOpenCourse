pragma solidity >=0.4.22 <0.6.0;

contract Factorial {
    
    uint public result = 1;
    
    function factorialCycles(uint num) public returns(uint){
        result = 1;
        if(num == 0 || num == 1){
            return result;
        }
        while (num > 1) {
            result *= num;
            num--;
        }
        return result;
    }
    
    function factorialRecursive(uint num) public returns(uint){
       
        if(num==0 || num==1){
            result = 1;
            return 1;
        }

        result = factorialRecursive(num-1) * num;
        return result;
    } 
    // Ако се сложат големи числа за изчисляване е много скъпо.
    // Хубаво е да се даде някакъв лимит за големината на числото.
}

contract RandomNumber{
    function random() public returns (uint256) {
        uint randomnumber = uint(keccak256(abi.encodePacked(now, msg.sender))) % 100000;
        return randomnumber;
        // Проблемът е че всичко се знае от всеки.
    }
}