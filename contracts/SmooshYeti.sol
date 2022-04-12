// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";




contract NFTSmooshYeti is ERC721A, Ownable {
    using Strings for uint;

    string public baseURI;

    uint private constant MAX_SUPPLY = 3920;

    uint public publicSalePrice = 0.085 ether;


    constructor(string memory _baseURI) ERC721A("SmooshYeti NFT", "SY")
    {
        baseURI = _baseURI;
    }

    modifier isNotContract() {
        require(tx.origin == msg.sender, "Reentrancy Guard is watching");
        _;
    }

    function publicSaleMint(address _account, uint _quantity) external payable isNotContract {
        uint price = publicSalePrice;
        require(price != 0, "Price is 0");
        require(totalSupply() + _quantity <= MAX_SUPPLY, "Max supply exceeded");
        require(msg.value >= price * _quantity, "Not enought funds");
        _safeMint(_account, _quantity);
    }

    function setBaseUri(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }
    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");

        return string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"));
    }
  
}