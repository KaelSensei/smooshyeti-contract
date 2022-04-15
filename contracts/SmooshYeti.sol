// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";




contract NFTSmooshYeti is ERC721A, Ownable {

    using Strings for uint;

    enum Step {
        Before,
        WhitelistSale,
        PublicSale,
        SoldOut,
        Reveal
    }

    string public baseURI;

    Step public sellingStep;

    uint private constant MAX_SUPPLY = 3920;
    uint private constant MAX_WHITELIST = 250;
    uint private constant MAX_PUBLIC = 3670;

    uint public whitelist_price = 0.0045 ether;
    uint public public_price = 0.0075 ether;

    bytes32 public merkleRoot;

    mapping(address => uint) public amountNFTperWalletWhitelistSale;

    constructor(string memory _baseURI) ERC721A("SmooshYeti NFT", "SY")
    {
        baseURI = _baseURI;
    }

    modifier isNotContract() {
        require(tx.origin == msg.sender, "Reentrancy Guard is watching");
        _;
    }

    function whitelistMint(address _account, uint _quantity, bytes32[] calldata _proof) external payable isNotContract {
        uint price = whitelist_price;
        require(price != 0, "Price is 0");
        require(sellingStep == Step.WhitelistSale, "Whitelist sale is not activated");
        require(isWhiteListed(msg.sender, _proof), "Not whitelisted");
        require(amountNFTperWalletWhitelistSale[msg.sender] + _quantity <= 1, "You can only get 1 NFT on the Whitelist Sale");
        require(totalSupply() + _quantity <= MAX_WHITELIST, "There's no more supply for the whitelist");
        require(msg.value >= price * _quantity, "Not enought funds");
        amountNFTperWalletWhitelistSale[msg.sender] += _quantity;
        _safeMint(_account, _quantity);
    }

    function publicSaleMint(address _account, uint _quantity) external payable isNotContract {
        uint price = public_price;
        require(price != 0, "Price is 0");
        require(sellingStep == Step.PublicSale, "You can't buy outside the public sale");
        require(totalSupply() + _quantity <= MAX_WHITELIST + MAX_PUBLIC, "NFT can't be mint anymore");
        require(msg.value >= price * _quantity, "Not enought funds");
        _safeMint(_account, _quantity);
    }

    function setBaseUri(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }
       
    function setStep(uint _step) external onlyOwner {
        sellingStep = Step(_step);
    }

    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");

        return string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"));
    }

   function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function isWhiteListed(address _account, bytes32[] calldata _proof) internal view returns(bool) {
        return _verify(leaf(_account), _proof);
    }

    function leaf(address _account) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(bytes32 _leaf, bytes32[] memory _proof) internal view returns(bool) {
        return MerkleProof.verify(_proof, merkleRoot, _leaf);
    }
    
    function withdraw(uint amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }
}
