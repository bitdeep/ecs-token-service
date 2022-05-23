//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "hardhat/console.sol";

contract TokenStorageService is Ownable {
    using SafeERC20 for ERC20;
    struct CategoryInfo {
        string name;
        uint id;
        bool enabled;
        address manager;
        uint version;
        uint fee;
        uint chainId;
    }
    struct TokenInfo {
        string name;
        address addy;
        string symbol;
        uint decimals;
        uint chainId;
        string logoURI;
        bool enabled;
        uint timestamp;
        string site;
    }

    CategoryInfo[] private categoryInfo;
    mapping(uint => TokenInfo[]) public tokensInfo;

    ERC20 token;
    constructor( address _token ) {
        token = ERC20(_token);
        token.balanceOf(address(this));
    }

    function categoriesLength() public view returns (uint) {
        return categoryInfo.length;
    }

    function getCategories() public view returns (CategoryInfo[] memory) {
        return categoryInfo;
    }

    function getCategory(uint id) public view returns (CategoryInfo memory) {
        return categoryInfo[id];
    }

    function adminAddNewCategory(string memory name, bool enabled, address manager,
        uint fee, uint chainId) public onlyOwner {
        uint id = categoryInfo.length;
        categoryInfo.push(CategoryInfo(
            {name : name, id : id, enabled : enabled, manager : manager, version : 0, fee: fee, chainId: chainId}));
    }

    function adminSetCategory(uint id, string memory name, bool enabled, address manager,
        uint fee, uint chainId) public onlyOwner {
        categoryInfo[id].name = name;
        categoryInfo[id].enabled = enabled;
        categoryInfo[id].manager = manager;
        categoryInfo[id].fee = fee;
        categoryInfo[id].chainId = chainId;
    }

    function addNewToken(uint cat, address addy, string memory logoURI, string memory site) public
    {
        require(categoryInfo[cat].enabled, "Category not enabled.");
        ERC20(addy).balanceOf(address(this));
        if( categoryInfo[cat].fee > 0 ){
            token.safeTransferFrom(msg.sender, categoryInfo[cat].manager, categoryInfo[cat].fee);
        }
        tokensInfo[cat].push(TokenInfo(
            {name : ERC20(addy).name(),
            addy : addy,
            symbol: ERC20(addy).symbol(),
            decimals: ERC20(addy).decimals(),
            chainId: categoryInfo[cat].chainId,
            logoURI: logoURI,
            enabled: false,
            site: site,
            timestamp: 0}));
    }

    function enableToken(uint cat, address addy, bool enabled) public
    {
        require(categoryInfo[cat].enabled, "Category not enabled.");
        require(categoryInfo[cat].manager == msg.sender, "Not authorized.");
        categoryInfo[cat].version++;

        for( uint i = 0 ; i < tokensInfo[cat].length; i++ ){
            if( tokensInfo[cat][i].addy != addy )
                continue;
            tokensInfo[cat][i].enabled = enabled;
            if( tokensInfo[cat][i].timestamp == 0 )
                tokensInfo[cat][i].timestamp = block.timestamp;
        }
    }
    function tokensAll(uint cat) public view returns(TokenInfo[] memory)
    {
        return tokensInfo[cat];
    }
    function tokens(uint cat) public view returns(TokenInfo[] memory)
    {
        uint total = tokensInfo[cat].length;
        uint enabled = 0;
        for( uint i = 0 ; i < total ; i ++ )
            if( tokensInfo[cat][i].enabled )
                enabled++;
        TokenInfo[] memory result = new TokenInfo[](enabled);
        uint j = 0;
        for( uint i = 0 ; i < total ; i ++ ){
            if( tokensInfo[cat][i].enabled ){
                result[j] = tokensInfo[cat][i];
                j++;
            }
        }
        return result;
    }

}
