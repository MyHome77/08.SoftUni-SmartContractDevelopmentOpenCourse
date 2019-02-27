pragma solidity >=0.4.22 <0.6.0;

contract Stateful {

	enum State { Locked, Unlocked, Restricted }
	
	struct Counter {
		
		uint256 counter;
		uint256 timestamp;
		address addr;
	}
	
	State public state;
	
	Counter public counter;
	address owner;
	
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	
	modifier canExecute {
		require(state != State.Locked);
		require( (state == State.Unlocked) || ((state == State.Restricted) && (msg.sender == owner)));
		_;
	}
	
	constructor() public {
		owner = msg.sender;
	}
	
	function changeState(State newState) public onlyOwner 
	{
		state = newState;
	}
	
	function count() public canExecute {
		counter.counter++;
		counter.timestamp = now;
		counter.addr = msg.sender;
	}
}