// SPDX-License-Identifier: GPL-3.0
/*
소스 코드가 GPL 버전 3.0에 따라 사용이 허가되었음을 알려줍니다. 
기계 판독 가능 라이선스 지정자는 소스 코드 게시가 기본값인 설정에서 중요합니다.
*/
pragma solidity >=0.4.16 <0.9.0;
/*
소스 코드가 Solidity 버전 0.4.16 또는 버전 0.9.0을 포함하지 않는 최신 버전의 언어용으로 작성되었음을 지정합니다. 
이는 계약이 다르게 작동할 수 있는 새(중단) 컴파일러 버전으로 컴파일할 수 없도록 하기 위한 것입니다. 
Pragma 는 소스 코드를 처리하는 방법에 대한 컴파일러의 일반적인 지침입니다
*/

// 테스트용 배포할 때는 제거
import "hardhat/console.sol";

contract SimpleStoregeUpgrade {

    uint storedData;

    event Change(string message, uint newVal);

    function set(uint x) public {
        console.log("The value is %d", x);
        require(x < 5000, "Should be less than 5000");
        storedData = x;
        emit Change("set", x);
    }

    function get() public view returns (uint) {
        return storedData;
    }
}