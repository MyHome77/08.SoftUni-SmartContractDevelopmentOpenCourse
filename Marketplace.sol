
contract Marketplace {
	address owner;
	mapping (uint256 => Store) stores;
	mapping (address => Administrator) administrators;
	
	modifier onlyAdministrator {
		require(administrators[msg.sender] == msg.sender);
		_;
	}
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	
	function AddStore(Store store) public returns (bool) onlyAdministrator {
		if(stores[store.Id] != store) {
			stores[store.owner] = store;
			return true;
		}
		return false;
	}
}

contract StoreOwner {
	address owner;
	uint256 funds;
	mapping (uint256 => Storefront) storefronts;
	
	function AddStorefront(Storefront storefront) public returns (bool) onlyStoreOwner {
		if(storefronts[storefront.id].id != storefront.id) {	
			storefronts[storefront.id] = storefront;
			return true;
		}
		return false;
	}
	
	
	
	
}

library StoreLib {
	struct Store {
		uint256 id;
		address owner;
		mapping(uint256 => Storefront) storefronts;
	}
	
	function CreateStore(uint256 id) {
		if(id <= 0) {
			return false;
		}
		Store = {Id: id, Owner: msg.sender};
		return true;
	}
	
	function RequestStoreCreation() {
		//TODO
	}
}

library StorefrontLib {
	using ProductLib for Product;
	struct Storefront {
		uint256 Id;
		address Owner;
		mapping(uint256 => Product) Products;
	}
	
	function CreateStorefront(uint256 id) returns (bool) onlyStoreOwner {
		if(id <= 0) {
			return false;
		}
		Storefront = {Id: id, Owner: msg.sender};
		return true;
	}
	function AddProduct(uint256 sku, string title, uint256 price, uint256 quantity) public returns (bool) onlyStoreOwner {
		if(Products[sku] != sku) {
			Products[sku] = ProductLib.CreateProduct(sku, title, price, quantity);
			return true;
		}
		return false;
	}
	
	function RemoveProduct(Storefront storefront, Product _product) public returns (bool) onlyStoreOwner {
		if(Products[sku] == sku) {
			delete Products[sku];
			return true;
		}
		return false;
	}
}

library ProductLib {
	struct Product {
		uint256 Sku;
		string Title;
		uint256 Price;
		uint256 Quantity;
	}
	
	function CreateProduct(uint256 sku, string title, uint256 price, uint256 quantity) returns (bool) onlyStoreOwner {
		if(sku <= 0 || title.length <= 0 || price <=0 || quantity < 0){
			return false;
		}
		Product = {Sku: sku, Title: title, Price: price, Quantity: quantity};
		return true;
	}
	function UpdatePrice(uint256 _price) public returns (bool) onlyStoreOwner {
		if(_price <= 0) {
			return false;
			
		}
		Product.Price = _price;
		return true;
	}
	
	function UpdateQuantity(uint256 _quantity) public returns (bool) onlyStoreOwner {
		if(_quantity < 0) {
			return false;
		}
		Product.Quantity = _quantity;
		return true;
	}
}

contract Administrator {

}