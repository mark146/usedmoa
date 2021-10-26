// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

// 참고 : https://soliditydeveloper.com/erc-1155
contract AirlineTokens is ERC1155 {
    address public governance;
    uint256 public airlineCount;

    modifier onlyGovernance() {
        require(msg.sender == governance, "only governance can call this");

        _;
    }

    constructor(address governance_) public ERC1155("") {
        governance = governance_;
        airlineCount = 0;
    }

    function addNewAirline(uint256 initialSupply) external onlyGovernance {
        airlineCount++;
        uint256 airlineTokenClassId = airlineCount;

        _mint(msg.sender, airlineTokenClassId, initialSupply, "");
    }
}