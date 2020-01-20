/*
    This exercise has been updated to use Solidity version 0.5
    Breaking changes from 0.4 to 0.5 can be found here: 
    https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html
*/

pragma solidity ^0.5.12;

contract TestSupplyChain { // Submit this after  truffle tests. I have 4 passing. Did not test fetch function.

  /* set owner */
  address owner;

  /* Add a variable called skuCount to track the most recent sku # */

  uint skuCount;

  /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
     Call this mappings items
  */

  mapping (uint => Item) public items;

  /* Add a line that creates an enum called State. This should have 4 states
    ForSale
    Sold
    Shipped
    Received
    (declaring them in this order is important for testing)
  */

  enum State{ForSale, Sold, Shipped, Received}

  /* Create a struct named Item.
    Here, add a name, sku, price, state, seller, and buyer
    We've left you to figure out what the appropriate types are,
    if you need help you can ask around :)
    Be sure to add "payable" to addresses that will be handling value transfer
  */

  struct Item {

      string name;
      uint sku;
      uint256 price;
      State state;
      address payable seller;
      address payable buyer;
  }
  
  uint sku = sku;
  uint _price;
  string _name;

  /* Create 4 events with the same name as each possible State (see above)
    Prefix each event with "Log" for clarity, so the forSale event will be called "LogForSale"
    Each event should accept one argument, the sku */

    event LogForSale(uint sku);
    event LogSold(uint sku);
    event LogShipped(uint sku);
    event LogReceived(uint sku);

/* Create a modifier that checks if the msg.sender is the owner of the contract */

  modifier verifyBuyer() {require (msg.sender == items[sku].buyer); _;}
  modifier verifyOwner() {require (msg.sender == owner); _;}
  modifier verifySeller() {require(msg.sender == items[sku].seller); _;}
  modifier paidEnough() { require(msg.value >= items[sku].price); _;}
  modifier checkValue() {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    msg.value >= items[sku].price;
    uint amountToRefund = msg.value - items[sku].price;
    items[sku].buyer.transfer(amountToRefund);
  }

  /* For each of the following modifiers, use what you learned about modifiers
   to give them functionality. For example, the forSale modifier should require
   that the item with the given sku has the state ForSale. 
   Note that the uninitialized Item.State is 0, which is also the index of the ForSale value,
   so checking that Item.State == ForSale is not sufficient to check that an Item is for sale.
   Hint: What item properties will be non-zero when an Item has been added?
   */
  modifier forSale() {require (items[sku].state == State.ForSale); _;}
  modifier sold() {require (items[sku].state == State.Sold); _;}
  modifier shipped() {require (items[sku].state == State.Shipped); _;}
  modifier received() {require (items[sku].state == State.Received); _;}


  constructor() public {
      owner = msg.sender; 
      skuCount = 0;
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. */
  }

  function testaddItem(/*string*/ /*memory*/ /*_name, uint _price*/) public returns(bool){
      
    emit LogForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    skuCount = skuCount + 1;
    return true;
  }

  /* Add a keyword so the function can be paid. This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent. Remember to call the event associated with this function!*/

  function testbuyItem() payable public forSale() paidEnough() checkValue(){
      items[sku].seller.transfer(items[sku].price);
       items[sku].buyer = msg.sender;
      items[sku].state = State.Sold;
      emit LogSold(sku);
  }

  /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
  is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
  function testshipItem() public  /*verifySeller()*/ /*sold()*/{
      if (items[sku].state == State.Sold && (msg.sender == items[sku].seller))
          items[sku].state = State.Shipped;
          emit LogShipped(sku);
      

      //emit LogShipped(items[sku].sku);


  }

  /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
  function testreceiveItem() public /*shipped() verifyBuyer()*/{
      if (items[sku].state == State.Shipped && msg.sender == items[sku].buyer)
      items[sku].state = State.Received;
      emit LogShipped(sku); 

  }

  /* We have these functions completed so we can run tests, just ignore them :) */
  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }
}

 
