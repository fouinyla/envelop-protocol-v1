// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ETypes} from "../contracts/LibEnvelopTypes.sol";

contract FoundyWrap {
    // enum AssetType {
    //     EMPTY,
    //     NATIVE,
    //     ERC20,
    //     ERC721,
    //     ERC1155,
    //     FUTURE1,
    //     FUTURE2,
    //     FUTURE3
    // }

    // struct Asset {
    //     AssetType assetType;
    //     address contractAddress;
    // }

    // struct AssetItem {
    //     Asset asset;
    //     uint256 tokenId;
    //     uint256 amount;
    // }

    // struct Fee {
    //     bytes1 feeType;
    //     uint256 param;
    //     address token;
    // }

    // struct Lock {
    //     bytes1 lockType;
    //     uint256 param;
    // }

    // struct Royalty {
    //     address beneficiary;
    //     uint16 percent;
    // }

    // struct INData {
    //     AssetItem inAsset;
    //     address unWrapDestination;
    //     Fee[] fees;
    //     Lock[] locks;
    //     Royalty[] royalties;
    //     AssetType outType;
    //     uint256 outBalance; //0- for 721 and any amount for 1155
    //     bytes2 rules;
    // }

    address public ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;
    address public WRAPPER_USERS_V1_BATCH;
    address public IMPL_ADDRESS;
    address public EVENT_MANAGER_CONTRACT;

    uint8 public constant OUT_TYPE = 3;

    address public owner;

    constructor(
        address wrapper_users_v1_batch,
        address impl_address,
        address event_manager_contract
    ) {
        owner = msg.sender;
        WRAPPER_USERS_V1_BATCH = wrapper_users_v1_batch;
        IMPL_ADDRESS = impl_address;
        EVENT_MANAGER_CONTRACT = event_manager_contract;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: You are not the owner, Bye.");
        _;
    }

    // function balance(IERC20 token) public view onlyOwner returns (uint256) {
    //     return token.balanceOf(address(this));
    // }

    // function withdraw(
    //     IERC20 token,
    //     uint256 amount
    // ) external onlyOwner returns (bool) {
    //     require(token.balanceOf(address(this)) >= amount, "Not enought usdt");
    //     return token.transfer(owner, amount);
    // }

    // function withdrawMatic(uint256 amount) public onlyOwner {
    //     require(
    //         IERC20(MATIC).balanceOf(address(this)) >= amount,
    //         "Not enought matic"
    //     );
    //     payable(owner).transfer(amount);
    // }

    function deployNewCollection(
        string memory name,
        string memory symbol
    ) public onlyOwner returns (address) {
        // create new collection
        bytes memory _collection_data = abi.encodeWithSignature(
            "deployNewCollection(address,address,string,string,string,address)",
            IMPL_ADDRESS,
            address(this),
            name,
            symbol,
            "https://api.envelop.is/metadata",
            WRAPPER_USERS_V1_BATCH
        );

        return
            abi.decode(
                Address.functionCallWithValue(
                    EVENT_MANAGER_CONTRACT,
                    _collection_data,
                    0
                ),
                (address)
            );
    }

    function wrap(
        address collection_address
    ) public onlyOwner returns (ETypes.AssetItem memory) {
        // approve usdt token
        // IERC20(USDT).approve(WRAPPER_USERS_V1_BATCH, 10000);

        // wrap nft
        ETypes.AssetItem memory _originalNft = ETypes.AssetItem(
            ETypes.Asset(ETypes.AssetType.EMPTY, ZERO_ADDRESS),
            0,
            0
        );

        ETypes.INData memory _inData = ETypes.INData(
            _originalNft,
            ZERO_ADDRESS,
            new ETypes.Fee[](0),
            new ETypes.Lock[](0),
            new ETypes.Royalty[](0),
            ETypes.AssetType.ERC721,
            uint256(0),
            0x0000
        );

        ETypes.AssetItem[] memory _collateral = new ETypes.AssetItem[](0);

        bytes memory _data = abi.encodeWithSignature(
            "wrapIn(INData,AssetItem[],address,address)",
            _inData,
            // [AssetItem(Asset(AssetType.ERC20, USDT), 0, 10000)],
            _collateral,
            address(this),
            collection_address
        );

        return
            abi.decode(
                Address.functionCallWithValue(WRAPPER_USERS_V1_BATCH, _data, 0),
                (ETypes.AssetItem)
            );
    }
}
