pragma solidity >=0.4.22 <0.6.0;

contract Factorial {
    
 	function CalculateFactorialWithLoop(uint a) public returns (uint) {
 	    if(a <= 1){
 	        return 1;
 	    }
	    uint sum = 1;
	    while(a > 0){
	        sum *= a;
	        a--;
	    }
	    
	    return sum;
	}
	function CalculateFactorialRecursive(uint a) public returns (uint) {
	    uint result = 1;
	    if(a == 0 || a == 1){
	        return 1;
	    }
	    result = CalculateFactorialRecursive(a - 1) * a;
	    return result;
	}
	
	//The problem is that a miner can't tell up front how expensive the program will be to verify. 
	//Even very small programs can have very long runtimes, and some long programs (well behaved smart contracts) 
	//are quick to verify (few loops).
    //One alternative is a language that provides estimates or time bounds on computation. 
    //Miners can then prioritize effectively, e.g. requiring fees that are in part proportional to the verification cost, 
    //or terminate transactions that exceed their estimated runtimes. 
    //This incentivizes applications built on bitcoin to use programs that are efficient to verify.
}

contract RandomNumberGenerator{
    
    function GenerateNumber(uint a) public returns (uint) {
        return (block.gaslimit/3+(block.difficulty/4)%block.number)*a;
    }
	//There is a chance of collisions
}