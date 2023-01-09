import pytest
import logging
from brownie import Wei, reverts, chain
from makeTestData import makeNFTForTest721, makeFromERC721ToERC721WithoutCollateralLight

LOGGER = logging.getLogger(__name__)
ORIGINAL_NFT_IDs = [1,2,3,4, 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22, 23, 24, 25, 26, 27]
zero_address = '0x0000000000000000000000000000000000000000'


def test_addColl(accounts, erc721mock, wrapperLight, wnft721ForWrapperLightV1, niftsy20, erc721mock1):
    #make test data
    makeNFTForTest721(accounts, erc721mock, ORIGINAL_NFT_IDs)
    
    #make wrap NFT 721
    wTokenId = makeFromERC721ToERC721WithoutCollateralLight(accounts, erc721mock, wrapperLight, wnft721ForWrapperLightV1, niftsy20, ORIGINAL_NFT_IDs[0], accounts[3])

    
    #PREPARE DATA
    #make 721 for collateral
    makeNFTForTest721(accounts, erc721mock1, ORIGINAL_NFT_IDs)
    i = 1
    while i < wrapperLight.MAX_COLLATERAL_SLOTS()+2:
        erc721mock.transferFrom(accounts[0], accounts[1], ORIGINAL_NFT_IDs[i], {"from": accounts[0]} )
        erc721mock.approve(wrapperLight.address, ORIGINAL_NFT_IDs[i], {"from": accounts[1]} )
        if (i == wrapperLight.MAX_COLLATERAL_SLOTS()+1):
            with reverts("Too much tokens in collateral"):    
                wrapperLight.addCollateral(wnft721ForWrapperLightV1.address, wTokenId, [((3, erc721mock.address), ORIGINAL_NFT_IDs[i], 0)], {'from': accounts[1]})
        else:
            wrapperLight.addCollateral(wnft721ForWrapperLightV1.address, wTokenId, [((3, erc721mock.address), ORIGINAL_NFT_IDs[i], 0)], {'from': accounts[1]})
        collateral = wrapperLight.getWrappedToken(wnft721ForWrapperLightV1, wTokenId)[1]
        i += 1

    collateral = wrapperLight.getWrappedToken(wnft721ForWrapperLightV1, wTokenId)[1]

    i = 1
    while i < wrapperLight.MAX_COLLATERAL_SLOTS()+1:
        assert erc721mock.ownerOf(ORIGINAL_NFT_IDs[i]) == wrapperLight.address
        assert collateral[i-1] == ((3, erc721mock.address), ORIGINAL_NFT_IDs[i], 0)
        i += 1
    


