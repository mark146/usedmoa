/**
 샘플 프로젝트는 Waffle 및 Ethers.js 를 사용하는 이러한 테스트와 함께 제공됩니다 .
 원하는 경우 다른 라이브러리를 사용할 수 있습니다. 가이드에 설명된 통합을 확인하십시오.
 */

const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});