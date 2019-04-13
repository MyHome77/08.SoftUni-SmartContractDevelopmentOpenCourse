pragma solidity ^0.5.0;

contract SupplyChain {

  /* set owner */
  address private owner;

  /* Add a variable called skuCount to track the most recent sku # */
  uint private skuCount;

  /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
     Call this mappings items
  */
  mapping ( uint => Item) private items;

  /* Add a line that creates an enum called State. This should have 4 states
    ForSale
    Sold
    Shipped
    Received
    (declaring them in this order is important for testing)
  */
  enum State {
    ForSale,
    Sold,
    Shipped,
    Received
  }

  /* Create a struct named Item.
    Here, add a name, sku, price, state, seller, and buyer
    We've left you to figure out what the appropriate types are,
    if you need help you can ask around :)
  */
  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address seller;
    address buyer;
  }

  
  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. */
    skuCount = 0;
    owner = msg.sender;
  }


  function addItem(string memory _name, uint _price) public returns(bool){
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    skuCount = skuCount + 1;
    return true;
  }

}
