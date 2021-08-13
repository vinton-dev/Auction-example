
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

// Importing OpenZeppelin's SafeMath Implementation
//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./SafeMath.sol";


contract Auction {
    
    using SafeMath for uint256;
    enum State{ Running, Finalized}
    // asset for bidding
    struct Asset {
    uint aid;
    address  owner; 
    string title;
    uint price;
    string description;
    State  auctionState;
    address highestbidder;
    uint highestprice;
    }



    mapping(uint => Asset)   assets ;   // assets mapping
    mapping(uint => mapping(address => uint))  bids; // bids mapping to store bidid,bidder address, price

    
   // function to create an asset

   function createAsset (
        uint _aid,
        string memory _title,
        uint _price,
        string memory _description
        ) public{
        require(_price > 0);
        Asset storage ast=assets[_aid];
        ast.aid = _aid;
        ast.owner = msg.sender;
        ast.title = _title;
        ast.price = _price;
        ast.description = _description;
        assets[_aid].auctionState = State.Running;

    }
    
      // function to get asset
    function getAsset(uint _aid) public view returns(Asset memory a){
        return assets[_aid] ;
    }
    
  
    // function to place a bid
    function placeBid(uint _aid,uint _price) public payable  returns(bool) {
        require(assets[_aid].auctionState == State.Running);            // check asset bid status
        require(assets[_aid].owner != msg.sender);                       // asset owner cannot bit on his own
        require(msg.value > 0);                                         // who ever calling value should be greater than zero
        require(_price>assets[_aid].highestprice) ;                         // bidding price should be greater than existing price            
        
        bids[_aid][msg.sender]=_price; // storing values in bid map
        assets[_aid].highestbidder= msg.sender; // asset highest bidder updating address with current caller
        assets[_aid].highestprice= _price;     // asset highest price is updated with current caller input price
        return true;
    }

    //function to stop bid by asset owner
    function finalizeAuction(uint _aid,address payable receipt) public payable returns (bool){
        require(msg.sender == assets[_aid].owner); // only asset owner can access this function
                assets[_aid].auctionState = State.Finalized; // only owner can stop the auction
                // receipt =  assets[_aid].owner;
        receipt.transfer(assets[_aid].highestprice); // once bid completed we are transfering the bid ammount to owner account
            return true;
    }
    
}