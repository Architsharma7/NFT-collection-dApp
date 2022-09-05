//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable{

    string _baseTokenURI;

    uint256 public _price = 0.01 ether;

    bool public _paused;                            //used to pause the contract in case of an emergency

    uint256 public maxTokenIds = 20;

    uint256 public tokenIds;                          //total number of tokenIds minted

    IWhitelist whitelist;                         // Whitelist contract instance (created an instance of IWhitelist)

    bool public presaleStarted;

    uint256 public presaleEnded;                      // timestamp for when presale would end


    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }
    /*
    RC721 constructor takes in a `name` and a `symbol` to the token collection.
    name is `Crypto Devs` and symbol is `CD`.
    */

   constructor(string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD"){
    baseURI = _baseTokenURI;
    whitelist = IWhitelist(whitelistContract);
   }

   function startPresale() public onlyOwner{
    presaleStarted = true;
    presaleEnded = block.timestamp + 5 minutes;        //Set presaleEnded time as current timestamp + 5 minutes
   }

   function presaleMint() public payable onlyWhenNotPaused{
    require(presaleStarted && block.timestamp < presaleEnded,  "Presale is not running");
    require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
    require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply");
    require(msg.value >= _price, "Ether sent is not correct");

    tokenIds += 1;
    _safeMint(msg.sender, tokenIds);          
                                        
   }



   function _mint() public payable onlyWhenNotPaused{
    require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet");
    require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
    require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply");
    require(msg.value >= _price, "Ether sent is not correct");

    tokenIds += 1;
    _safeMint(msg.sender, tokenIds);
   }

   //_baseURI overides the Openzeppelin's ERC721 implementation which by default returned an empty string for the baseURI

   function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }



    function setPaused(bool val) public onlyOwner{             
        _paused = val;
    }

 

    function withdraw() public onlyOwner{
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) =  _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

     receive() external payable {}

     fallback() external payable {}

}


