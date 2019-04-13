pragma solidity ^0.5.0;
library StoreLib {
	struct Store {
		bytes32 id;
		address owner;
		string storeName;
	}
	
	/** @dev Creates a store with 4 properties id, owner and store name.
		* @param _owner Owner of the store.
		* @param _storeName Name of the store.
		* @return Store Copy of the store.
		*/

	function createStore(address _owner, string memory _storeName) internal pure returns (Store memory) {
		return Store({id: keccak256(abi.encodePacked(_owner, _storeName)), owner: _owner, storeName: _storeName});
	}
}