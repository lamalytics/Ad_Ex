// contracts/Bid.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Auth from the access-control subdirectory
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bid is Ownable{

    // fire when newAdvertiser is registered
    event newAdvertiser(address addr);

    // fire when new ad is placed
    event newAd(uint256 adId, uint256 value);

    struct Advertiser {
        address id;
        uint256 bidCount;
        bool isRegistered;
    }
    
    Advertiser[] public advertisers;
    mapping(address => Advertiser) adDetails;

    // initialize bidCount to 0
    uint bidCount = 0;

    uint curBid;
    // sets the bid floor bid passed in param
    constructor(uint256 _curBid) {
        curBid = _curBid;
    }
    
    
    // register advertiser for bidding (onlyOwner + admin[later])
    function register(address _address) public onlyOwner {
        // loops through advertisers array to see if address already exists already
        for(uint i = 0; i < advertisers.length; i++) {
            // registers address if address is new
            if(_address != advertisers[i].id) {
                advertisers.push(Advertiser({
                    id: _address,
                    bidCount: 0,
                    isRegistered: true
                }));
                // new Advertiser has registered
                
                emit newAdvertiser(_address);
            }
        }
        // else revert and error to say that the advertiser has already been registered
        // fallback for nonvalid addresses 
    }


    // place bid (ensure address is eligible for registered and owner)
        // ensure bid is higher than current bid
        // creates an ad id
        // fires event
        // mapping of address to ad id

    function placeBid (uint256 _value, Advertiser memory _advertiser) public {
        require(_value > curBid, "please bid above current bid");
        require(_advertiser.isRegistered == true, "please register your address");
        // transfer ad space 
        // call send transaction to contract address wallet

        // incremement bid count which is the ad ID
        bidCount++;
        emit newAd(bidCount, _value);
    }
    

    
    // transfer of funds to contract address if bid is successful
    // do not allow transaction if bid is lower or equal



    // function store(uint256 value) public onlyOwner {
    //     // Require that the caller is registered as an administrator in Auth
    //     // require(_auth.isAdministrator(msg.sender), "Unauthorized");

    //     _value = value;
    //     emit newBid(value);
    // }

    // function retrieve() public view returns (uint256) {
    //     return _value;
    // }
}