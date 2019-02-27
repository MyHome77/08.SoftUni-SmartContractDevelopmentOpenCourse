pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

contract MultiDim{

    uint[][] public state; //works
    
    //UnimplementedFeatureError
    constructor(uint[][] memory _state) public {
	
        //can't pass multi dim arrays as aruments yet
        state = _state;
    }
    
    //works
    function append(uint[] memory arr) public {
        state.push(arr);
    }
    
    //UnimplementedFeatureError
    function getState() public returns (uint[][] memory) {
	
        //can't return multi dim arrays yet
        return state;
    }
}