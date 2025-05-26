// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DenverNFT is ERC721 {
    using Strings for uint256;

    struct NFTFeatures {
        uint256 lastPrice;
        string specialAttribute;
        bool isTradable;
        bytes8 visualTraits; // Packed visual traits for SVG generation
    }

    address private immutable msbToken;
    uint256 private s_tokenCounter;
    IERC20 private token;
    address private tokensWithDrawAddress;

    ////////////////////////////////////////////////
    // view functions
    ///////////////////////////////////////////////
    function getMSB_token() public view returns (address) {
        return msbToken;
    }

    function getNext_NFTId() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getWithDrawAddress() public view returns (address) {
        return tokensWithDrawAddress;
    }

    function getNFTCost(uint256 _tokenId) public view returns (uint256) {
        return nftCost[_tokenId];
    }

    // SVG generation parameters
    string[] private backgroundColors = ["6385DF", "A3FF47", "FF4F4F", "FFFFFF"];
    string[] private headShapes = [
        '<path d="M500,200 Q700,300 500,600 Q300,300 500,200" fill="#F5D6BA"/>',
        '<circle cx="500" cy="400" r="300" fill="#F5D6BA"/>'
    ];
    string[] private eyeTypes = [
        '<circle cx="350" cy="350" r="50" fill="#000"/> <circle cx="650" cy="350" r="50" fill="#000"/>',
        '<rect x="300" y="300" width="100" height="50" fill="#000"/> <rect x="600" y="300" width="100" height="50" fill="#000"/>'
    ];
    string[] private mouthTypes = [
        '<path d="M350,500 Q500,600 650,500" fill="none" stroke="#000" stroke-width="10"/>',
        '<rect x="400" y="500" width="200" height="30" fill="#000"/>'
    ];

    mapping(uint256 tokenId => NFTFeatures) public nftFeatures;
    mapping(uint256 tokenId => uint256 minumumCost) public nftCost;

    modifier onlyWithDrawAddress() {
        require(msg.sender == tokensWithDrawAddress, "invalid address");
        _;
    }

    constructor(address _msbToken, address _withDrawAddress) ERC721("DENVER", "DNV") {
        msbToken = _msbToken;
        token = IERC20(_msbToken);
        tokensWithDrawAddress = _withDrawAddress;
    }

    function purchaseNFT(address _to, string memory _specialAttribute) public {
        require(token.balanceOf(msg.sender) >= 5 * 1e18, "Insufficient token balance");
        require(
            token.allowance(msg.sender, address(this)) >= 5 * 1e18, "the allowance is too low to perform transaction"
        );

        bool successPayment = token.transferFrom(msg.sender, address(this), 5 * 1e18);
        require(successPayment, "payment failed");

        // Generate random traits based on tokenId and block data
        bytes8 visualTraits = generateTraits(s_tokenCounter);

        _safeMint(_to, s_tokenCounter);
        nftFeatures[s_tokenCounter] = NFTFeatures({
            lastPrice: 5 * 1e18,
            specialAttribute: _specialAttribute,
            isTradable: false,
            visualTraits: visualTraits
        });

        nftCost[s_tokenCounter] = 5 * 1e18;
        s_tokenCounter++;
    }

    function withDrawTokens() public onlyWithDrawAddress {
        require(token.balanceOf(address(this)) > 0, "insufficient balance");
        bool successWithDraw = token.transfer(msg.sender, token.balanceOf(address(this)));
        require(successWithDraw, "withDraw failed");
    }

    function setPriceOfNFT(uint256 _newPrice, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId), "you are not owner of this nft");
        nftCost[_tokenId] = _newPrice;
    }

    // function toggleNFT_Tradable(uint256 _tokenId) public {
    //     require(msg.sender == ownerOf(_tokenId), "you are not owner of this nft");
    //     if (nftFeatures[_tokenId].isTradable) {
    //         nftFeatures[_tokenId].isTradable = false;
    //     } else {
    //         nftFeatures[_tokenId].isTradable = true;
    //     }
    // }

    function makeNFT_Tradable(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender && ownerOf(_tokenId) != address(0), "you are not owner of this nft");
        require(nftFeatures[_tokenId].isTradable == false, "it is already tradable nft");
        nftFeatures[_tokenId].isTradable = true;
    }

    function makeNFT_Not_Tradable(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender && ownerOf(_tokenId) != address(0), "you are not owner of this nft");
        require(nftFeatures[_tokenId].isTradable == true, "it is already not tradable nft");
        nftFeatures[_tokenId].isTradable = false;
    }

    function buyAlreadyOwnedNFT(uint256 _tokenId) public {
        require(ownerOf(_tokenId) != msg.sender && ownerOf(_tokenId) != address(0), "you are not able to buy NFT");
        require(nftCost[_tokenId] >= nftCost[_tokenId], "insufficient amount");
        require(nftFeatures[_tokenId].isTradable == true, "nft is not tradable");
        require(token.allowance(msg.sender,ownerOf(_tokenId)) >= nftCost[_tokenId], "allowance is too low");
        bool success = token.transferFrom(msg.sender, ownerOf(_tokenId), nftCost[_tokenId]);
        require(success, "Failed to buy NFT");
        setLastPrice(_tokenId, nftCost[_tokenId]);
        makeNFT_Not_Tradable(_tokenId);
        safeTransferFrom(ownerOf(_tokenId), msg.sender, _tokenId);
    }

    function generateSVG(uint256 tokenId) internal view returns (string memory) {
        NFTFeatures memory features = nftFeatures[tokenId];
        bytes8 traits = features.visualTraits;

        // Extract traits from packed bytes
        uint256 bgIndex = uint8(traits[0]) % backgroundColors.length;
        uint256 headIndex = uint8(traits[1]) % headShapes.length;
        uint256 eyeIndex = uint8(traits[2]) % eyeTypes.length;
        uint256 mouthIndex = uint8(traits[3]) % mouthTypes.length;

        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" viewBox="0 0 1000 1000" preserveAspectRatio="xMidYMid meet">',
                '<rect width="1000" height="1000" fill="#',
                backgroundColors[bgIndex],
                '"/>',
                headShapes[headIndex],
                eyeTypes[eyeIndex],
                mouthTypes[mouthIndex],
                '<text x="500" y="950" font-family="Arial" font-size="40" text-anchor="middle" fill="#000">',
                features.specialAttribute,
                "</text>",
                "</svg>"
            )
        );

        return svg;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(ownerOf(_tokenId) != address(0), "NFT does not exist");

        NFTFeatures memory features = nftFeatures[_tokenId];
        string memory svgImage = generateSVG(_tokenId);
        string memory imageBase64 = Base64.encode(bytes(svgImage));

        string memory json = string(
            abi.encodePacked(
                '{"name": "DENVER NFT #',
                _tokenId.toString(),
                '","description": "A unique Denver NFT with special attributes",',
                '"image": "data:image/svg+xml;base64,',
                imageBase64,
                '",',
                '"attributes": [',
                '{"trait_type": "Special Attribute", "value": "',
                features.specialAttribute,
                '"},',
                '{"trait_type": "Last Price", "value": "',
                features.lastPrice.toString(),
                ' MSB"},',
                '{"trait_type": "Tradable", "value": "',
                features.isTradable ? "Yes" : "No",
                '"},',
                '{"trait_type": "Background", "display_type": "number", "value": ',
                uint256(uint8(features.visualTraits[0])).toString(),
                "},",
                '{"trait_type": "Head Shape", "display_type": "number", "value": ',
                uint256(uint8(features.visualTraits[1])).toString(),
                "},",
                '{"trait_type": "Eye Type", "display_type": "number", "value": ',
                uint256(uint8(features.visualTraits[2])).toString(),
                "},",
                '{"trait_type": "Mouth Type", "display_type": "number", "value": ',
                uint256(uint8(features.visualTraits[3])).toString(),
                "}",
                "]}"
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    function generateTraits(uint256 tokenId) internal view returns (bytes8) {
        // Use tokenId and block data to generate deterministic but unique traits
        return bytes8(keccak256(abi.encodePacked(tokenId, block.prevrandao, block.timestamp)));
    }

    function setLastPrice(uint256 _tokenId, uint256 _amount) internal {
        nftFeatures[_tokenId].lastPrice = _amount;
    }
}
