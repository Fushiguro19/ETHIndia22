// Let’s start by importing the Openzeppelin ERC-721 template into our file
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// Next, let’s add our NFT smart contract and name the NFT token (Dynamic NFT)
error InvalidNumberOfOwners();
error ZeroAddress();
error NotOwner();
error NotEligible();

contract ReviseNFT is ERC721 {
    string baseuri = "";
    constructor(string memory _baseuri) ERC721("Dynamic NFT", "dNFT") {
        baseuri = _baseuri;
    }
    // Last but not the least, let’s add functions to enable minting and to enable setting the _baseURI().
    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
    function _baseURI() internal view override(ERC721) returns (string memory) {
        return baseuri;
    }

    mapping(address => mapping(uint256 => address[])) public fixedOwners;
    mapping(address => mapping(address => uint256[])) public tokenIdOwner;

    // 2
    mapping(address => mapping(uint256 => uint8)) public randomNumberOfOwners;
    mapping(address => mapping(uint256 => uint8)) public randomOwnersClaimed;

    // 1
    function addOwners(uint8 n, address[] calldata _owners, uint256 _id, address _nftAddress) external {
        if (IERC721(_nftAddress).ownerOf(_id) != msg.sender) revert NotOwner();
        if (_owners.length != n) revert InvalidNumberOfOwners();
        for (uint256 i; i < n; ) {
            if (_owners[i] == address(0)) revert ZeroAddress();
            fixedOwners[_nftAddress][_id].push(_owners[i]);
            unchecked {++i;}
        }
    }

    function claimOwnership(uint256 _id, address _nftAddress) external {
        uint256 numberOfIds = tokenIdOwner[msg.sender][_nftAddress].length;
        uint256 n = fixedOwners[_nftAddress][_id].length;

        if (numberOfIds > 0) {
            for (uint256 i; i < numberOfIds; ) {
                if (tokenIdOwner[msg.sender][_nftAddress][i] == _id) revert NotEligible();
                unchecked {++i;}
            }
        }

        for (uint256 i; i < n; ) {
            if (msg.sender != fixedOwners[_nftAddress][_id][i]) revert NotEligible();
            tokenIdOwner[msg.sender][_nftAddress].push(_id);
            unchecked {++i;}
        }
    }

    // 2
    function randomOwnership(uint8 _n, uint256 _id, address _nftAddress) external {
        if (IERC721(_nftAddress).ownerOf(_id) != msg.sender) revert NotOwner();
        randomNumberOfOwners[_nftAddress][_id] = _n;
    }

    function claimRandomOwnership(uint256 _id, address _nftAddress) external {
        if (randomOwnersClaimed[_nftAddress][_id] > randomNumberOfOwners[_nftAddress][_id]) revert NotEligible();
        randomOwnersClaimed[_nftAddress][_id] += 1;

        for (uint256 i; i < randomNumberOfOwners[_nftAddress][_id]; ) {
            if (msg.sender != fixedOwners[_nftAddress][_id][i]) revert NotEligible();
            tokenIdOwner[msg.sender][_nftAddress].push(_id);
            unchecked {++i;}
        }
    }
}
