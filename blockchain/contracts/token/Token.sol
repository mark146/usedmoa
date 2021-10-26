//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// 스마트 계약을 위한 메인 빌딩 블록
contract Token {
    
    // 토큰을 식별하는 일부 문자열 유형 변수.
    // 'public' 한정자는 계약 외부에서 변수를 읽을 수 있도록 합니다.
    string public name = "UsedMoaToken";
    string public symbol = "UMT";

    // 부호 없는 정수 유형 변수에 저장된 토큰의 고정 양입니다.
    uint256 public totalSupply = 5000000000000000000000000000;

    // 주소 유형 변수는 ethereum 계정을 저장하는 데 사용됩니다.
    address public owner;

    // 매핑은 키/값 맵입니다. 여기 각 계좌 잔액을 저장합니다.
    mapping(address => uint256) balances;

    /**
    계약 초기화.
    '건설자'는 계약이 성립될 때 한 번만 실행됩니다.
    */
    constructor() {
        // TotalSupply가 트랜잭션 보낸 사람(계정)에 할당됩니다.
        // 계약을 배포하는 중입니다.
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    /**
    토큰을 전송하는 함수입니다.
    '외부' 한정자는 외부에서 함수 *전용* 호출을 가능하게 합니다.
    계약서.
    */
    function transfer(address to, uint256 amount) external {
        console.log("Sender balance is %s tokens", balances[msg.sender]);
        console.log("Trying to send %s tokens to %s", amount, to);

        // 트랜잭션 보낸 사람이 충분한 토큰을 가지고 있는지 확인합니다.
        // 'require'의 첫 번째 인수가 'false'로 평가될 경우 트랜잭션이 되돌아갑니다.
        require(balances[msg.sender] >= amount, "Not enough tokens");

        // 금액을 이전합니다.
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    /**
    지정된 계정의 토큰 잔액을 검색하는 읽기 전용 함수입니다.
    '보기' 수식어는 계약의 내용을 수정하지 않음을 나타냅니다.
    상태: 트랜잭션을 실행하지 않고도 호출할 수 있습니다.
    */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}