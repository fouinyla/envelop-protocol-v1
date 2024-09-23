pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {FoundyWrap} from "../contracts/foundy_wrap.sol";
import {WrapperUsersV1Batch} from "../contracts/WrapperUsersV1Batch.sol";
import {ETypes} from "../contracts/LibEnvelopTypes.sol";
import {MockEventManager} from "../contracts/mock/MockEventManager.sol";
import {MockUsersSBTCollectionRegistry} from "../contracts/mock/MockUsersSBTCollectionRegistry.sol";
import {MockUsersSBTCollection721} from "../contracts/mock/MockUsersSBTCollection721.sol";

contract FoundyWrapTest is Test {
    address public constant ZERO_ADDRESS =
        0x0000000000000000000000000000000000000000;

    MockUsersSBTCollection721 public users_behind_proxy;
    MockUsersSBTCollectionRegistry public users_registry;
    // MockEventManager public event_manager;
    WrapperUsersV1Batch public wrapper_users_v1_batch;
    FoundyWrap public wrapper;

    function setUp() public {
        users_registry = new MockUsersSBTCollectionRegistry();
        users_registry.addImplementation(
            MockUsersSBTCollectionRegistry.Asset(
                MockUsersSBTCollectionRegistry.AssetType.EMPTY,
                ZERO_ADDRESS
            )
        );
        wrapper_users_v1_batch = new WrapperUsersV1Batch(
            address(users_registry)
        );

        users_behind_proxy = new MockUsersSBTCollection721(
            address(this),
            "test",
            "test",
            "https://example.com",
            address(wrapper_users_v1_batch)
        );

        // event_manager = new MockEventManager();
        wrapper = new FoundyWrap(
            address(wrapper_users_v1_batch),
            address(users_behind_proxy),
            address(users_registry)
        );
    }

    function test_wrap() public {
        address collection_address = wrapper.deployNewCollection(
            "test",
            "test"
        );

        MockUsersSBTCollectionRegistry.Asset[] memory a = users_registry
            .getUsersCollections(address(wrapper));

        console.log(a[0].contractAddress);
        wrapper.wrap(a[0].contractAddress);

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
        //     uint256(3),
        //     0x0000
        // );

        // ETypes.AssetItem[] memory _collateral = new ETypes.AssetItem[](0);

        // bytes memory _data = abi.encodeWithSignature(
        //     "wrapIn(INData,AssetItem[],address,address)",
        //     _inData,
        //     // [AssetItem(Asset(AssetType.ERC20, USDT), 0, 10000)],
        //     _collateral,
        //     address(this),
        //     collection_address
        // );

        // abi.decode(
        //     Address.functionCallWithValue(address(wrapper_users_v1_batch), _data, 0),
        //     (ETypes.AssetItem)
        // );
    }
}
