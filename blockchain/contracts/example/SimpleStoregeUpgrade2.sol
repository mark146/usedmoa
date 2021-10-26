//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol"; // 테스트용 배포할 때는 제거

contract SimpleStoregeUpgrade2 {

    uint storedData;
    uint storedKey;

    event Change(string message, uint newVal);

    function set(uint x) public {
        console.log("The value is %d", x);
        require(x < 10000, "Should be less than 10000");
        storedData = x;
        emit Change("set", x);
    }

    function get() public view returns (uint) {
        return storedData;
    }

    function setKey(uint key) public {
        storedKey = key;
    }

    function getKey() public view returns (uint) {
        return storedKey;
    }
}