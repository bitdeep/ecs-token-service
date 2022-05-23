const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TokenStorageService", function () {
  it("categories", async function () {
    const [ dev ] = await ethers.getSigners();
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    const Main = await ethers.getContractFactory("TokenStorageService");
    const mint = '10000000000000000000'; // 10
    const fee = '1000000000000000000'; // 1
    const token = await MockERC20.deploy('test', 'test', mint);
    const main = await Main.deploy(token.address);
    await main.deployed();
    await token.approve(main.address, mint);
    const chainId = '3000';
    await main.adminAddNewCategory("a", true, dev.address, fee, chainId);
    await main.adminAddNewCategory("b", true, dev.address, fee, chainId);
    await main.adminAddNewCategory("c", false, dev.address, fee, chainId);
    const categoriesLength = (await main.categoriesLength()).toString();
    let getCategories = await main.getCategories();
    // console.log('getCategories', getCategories);
    // console.log('categoriesLength', categoriesLength);

    await main.adminSetCategory('0', "A", true, dev.address, fee, chainId);
    await main.adminSetCategory('1', "B", true, dev.address, fee, chainId);
    await main.adminSetCategory('2', "C", true, dev.address, fee, chainId);

    // getCategories = await main.getCategories();
    // console.log('getCategories', getCategories);

    console.log('dev', dev.address);
    const tokenA = await MockERC20.deploy('a', 'a', mint);
    const tokenB = await MockERC20.deploy('b', 'b', mint);
    const tokenC = await MockERC20.deploy('c', 'c', mint);
    await main.addNewToken('1', tokenA.address,
        'https://localhost/logoA.png', 'https://localhost/A');
    await main.enableToken('1',tokenA.address, true);

    await main.addNewToken('1', tokenB.address,
        'https://localhost/logoB.png', 'https://localhost/B');
    await main.enableToken('1',tokenB.address, true);

    await main.addNewToken('1', tokenC.address,
        'https://localhost/logoC.png', 'https://localhost/C');
    await main.enableToken('1',tokenC.address, false);

    // const tokensAll = await main.tokensAll('1');
    // console.log(tokensAll);

    const tokens = await main.tokens('1');
    console.log(tokens);

  });
});
