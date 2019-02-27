pragma solidity >=0.4.22 <0.6.0;


contract ArrayTest{

    //automatic index getter
    uint[3] public threeInts = [1,2,3];

    //automatic index getter
    uint[] public manyInts;
    
    function increment(uint8 index) public {
        threeInts[index] += 1;
    }
    
    function push(uint newInt) public {
        manyInts.push(newInt);
        //same as:
        manyInts.length += 1;
        manyInts[manyInts.length-1] = newInt;
    }
    
    //warning: only works if called from the outside, not a contract
    function getManyInts() public view returns(uint[] memory){
        return manyInts;
    }
    
    function getThreeInts() public view returns (uint[3] memory){
        return threeInts;
    }
}