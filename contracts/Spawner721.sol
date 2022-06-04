// SPDX-License-Identifier: MIT
// ENVELOP protocol for NFT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

//v0.0.1
contract Spawner721 is ERC721, Ownable {
    using Strings for uint256;
    using Strings for uint160;
    using ECDSA for bytes32;
    
    string  public baseurl;

    // Oracle signers status
    mapping(address => bool) public oracleSigners;
    
    constructor(
        string memory name_,
        string memory symbol_,
        string memory _baseurl
    ) 
        ERC721(name_, symbol_)  
    {
        baseurl = string(
            abi.encodePacked(
                _baseurl,
                block.chainid.toString(),
                "/",
                uint160(address(this)).toHexString(),
                "/"
            )
        );

    }

    function mint(
        uint256 _tokenId, 
        //bytes32 _msgForSign, 
        bytes calldata _signature
    ) external virtual {

        bytes32 msgMustWasSigned = keccak256(abi.encode(
                msg.sender,
                block.chainid,
                address(this),
                _tokenId
        )).toEthSignedMessageHash();

        // Check signature  author
        require(oracleSigners[msgMustWasSigned.recover(_signature)], "Unexpected signer");

        _mint(msg.sender, _tokenId);
    }

    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    // function debug(uint256 tokenId, address _sender) public view returns (bytes32) {
    //     return keccak256(abi.encode(
    //             _sender,
    //             block.chainid,
    //             address(this),
    //             tokenId
    //         )).toEthSignedMessageHash();        
    // }

    // function debug1(uint256 tokenId, address _sender) public view returns (bytes32) {
    //     return keccak256(abi.encode(
    //             _sender,
    //             block.chainid,
    //             address(this),
    //             tokenId
    //         ));        
    // }

    // function debugNet() public view returns(uint256) {
    //     return block.chainid;
    // }

    /////////////////////////////////////////////////////////////

    function setSignerStatus(address _signer, bool _status) external onlyOwner {
        oracleSigners[_signer] = _status;
    }

    function baseURI() external view  returns (string memory) {
        return _baseURI();
    }

    function _baseURI() internal view  override returns (string memory) {
        return baseurl;
    }

}
