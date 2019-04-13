pragma solidity >=0.4.22 <0.6.0;

contract SomeContract {
    event callMeMaybeEvent(address _from);

    function callMeMaybe() payable public {
        emit callMeMaybeEvent(address(this));
    }
}

contract ThatCallsSomeContract {
    function callTheOtherContract(address _contractAddress) public {
        (bool successCall, bytes memory callData) = address(_contractAddress).call(abi.encodeWithSignature("callMeMaybe()"));
        (bool successDelegate, bytes memory delegateCallData) = address(_contractAddress).delegatecall(abi.encodeWithSignature("callMeMaybe()"));
        require(successCall, "Call failed");
        require(successDelegate, "Delegate failed");
        
        
        
        // require(_contractAddress.call(bytes4(keccak256("callMeMaybe()"))));
        // require(_contractAddress.delegateCall(bytes4(keccak256("callMeMaybe()"))));
    }
}