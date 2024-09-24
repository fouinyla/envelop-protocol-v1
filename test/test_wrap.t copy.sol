pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {FoundyWrap} from "../contracts/foundy_wrap.sol";
import {WrapperUsersV1Batch} from "../contracts/WrapperUsersV1Batch.sol";
import {WrapperUsersV1} from "../contracts/WrapperUsersV1.sol";
import {ETypes} from "../contracts/LibEnvelopTypes.sol";
import {MockEventManager} from "../contracts/mock/MockEventManager.sol";
import {MockUsersSBTCollectionRegistry} from "../contracts/mock/MockUsersSBTCollectionRegistry.sol";
import {MockUsersSBTCollection721} from "../contracts/mock/MockUsersSBTCollection721.sol";
import {TokenMock} from "../contracts/mock/MockERC20.sol";

contract FoundyWrapTest1 is Test {
    address public constant ZERO_ADDRESS =
        0x0000000000000000000000000000000000000000;

    MockUsersSBTCollection721 public users_behind_proxy;
    MockEventManager public users_registry;
    // MockEventManager public event_manager;
    WrapperUsersV1Batch public wrapper_users_v1_batch;
    WrapperUsersV1 public wrapper_users_v1;
    FoundyWrap public wrapper;

    TokenMock public erc20;

    function setUp() public {
        users_registry = new MockEventManager();
        wrapper_users_v1_batch = new WrapperUsersV1Batch(
            address(users_registry)
        );

        wrapper_users_v1 = new WrapperUsersV1(address(users_registry));

        users_behind_proxy = new MockUsersSBTCollection721(
            address(this),
            "test",
            "test",
            "https://example.com",
            address(wrapper_users_v1)
        );

        users_registry.addImplementation(
            MockUsersSBTCollectionRegistry.Asset(
                MockUsersSBTCollectionRegistry.AssetType.ERC721,
                address(users_behind_proxy)
            )
        );

        // event_manager = new MockEventManager();
        wrapper = new FoundyWrap(
            address(wrapper_users_v1_batch),
            address(users_behind_proxy),
            address(users_registry),
            address(wrapper_users_v1)
        );
        users_behind_proxy.setCreator(address(wrapper));

        erc20 = new TokenMock("erc1", "ERC1");
    }

    function test_wrap() public {
        address collection_address = wrapper.deployNewCollection(
            "test",
            "TEST"
        );

        MockEventManager.Asset[] memory a = users_registry.getUsersCollections(
            address(wrapper)
        );

        console.log(a[0].contractAddress);

        MockUsersSBTCollection721 collection = MockUsersSBTCollection721(
            a[0].contractAddress
        );

        console.log("this contract address", address(this));

        console.log("wrapperMinter", collection.wrapperMinter());
        console.log("collection owner", collection.owner());

        console.log("FoundyWrap", address(wrapper));
        console.log("wrapperUser", address(erc20));

        erc20.approve(address(wrapper), 1000000);

        ETypes.AssetItem memory _collateral = ETypes.AssetItem(
            ETypes.Asset(ETypes.AssetType.ERC20, address(erc20)),
            0,
            1000000
        );

        ETypes.AssetItem memory asset_item = wrapper.wrap{value: 5000000}(
            a[0].contractAddress,
            _collateral
        );

        (uint256 b, uint256 c) = wrapper_users_v1.getCollateralBalanceAndIndex(
            asset_item.asset.contractAddress,
            asset_item.tokenId,
            ETypes.AssetType.NATIVE,
            address(0),
            0
        );

        console.log("getCollateralBalanceAndIndex", b, c);

        // ETypes.AssetItem memory _originalNft = ETypes.AssetItem(
        //     ETypes.Asset(ETypes.AssetType.EMPTY, ZERO_ADDRESS),
        //     0,
        //     0
        // );

        // ETypes.INData memory _inData = ETypes.INData(
        //     _originalNft,
        //     ZERO_ADDRESS,
        //     new ETypes.Fee[](0),
        //     new ETypes.Lock[](0),
        //     new ETypes.Royalty[](0),
        //     ETypes.AssetType.ERC721,
        //     uint256(0),
        //     bytes2(0x0000)
        // );

        // ETypes.AssetItem[] memory _collateral = new ETypes.AssetItem[](0);

        // wrapper_users_v1_batch.wrapIn(
        //     _inData,
        //     _collateral,
        //     address(this),
        //     a[0].contractAddress
        // );
    }
}
