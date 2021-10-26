// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "hardhat/console.sol"; // 배포시 로그 제거

/*
// 계정별로 소유한 토큰 유형 ID의 토큰 양을 반환합니다.
// 계정은 0 주소가 될 수 없습니다.
balanceOf(address account, uint256 id) → uint256

// BalanceOf의 Batched 버전입니다.
// 계정과 ID의 길이는 같아야 합니다.
balanceOfBatch(address[] accounts, uint256[] ids) → uint256[]

// 승인된 내용에 따라 발신자의 토큰을 전송할 수 있는 권한을 연산자에게 부여하거나 취소합니다.
// ApprovalForAll 이벤트를 내보냅니다.
// 연산자는 호출자가 될 수 없습니다.
setApprovalForAll(address operator, bool approved)

// 운영자가 계정의 토큰을 전송하도록 승인된 경우 true를 반환합니다.
// setApprovalForAll을 참조하십시오.
isApprovedForAll(address account, address operator) → bool

// 토큰 유형 ID의 토큰 양을 부터 까지 전송합니다.
// TransferSingle 이벤트를 발생시킵니다.
// 0 주소가 될 수 없습니다.
// 발신자가 발신인이 아닌 경우, 집합 ApprovalForAll을 통해 발신자의 토큰에서 지출하도록 승인되어야 합니다.
// from에는 최소 금액의 유형 ID 토큰 잔액이 있어야 합니다.
// 스마트 계약을 참조하려면 IERC1155Receiver.ONERC1155Received를 구현하고 수락 마법 값을 반환해야 합니다.
safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes data)


// safeTransferFrom의 일괄 처리된 버전입니다
// TransferBatch 이벤트를 발생시킵니다.
// ID와 양은 길이가 같아야 합니다.
// 스마트 계약을 참조하려면 IERC1155Receiver.ONERC1155BatchReceived를 구현하고 수락 마법 값을 반환해야 합니다.
safeBatchTransferFrom(address from, address to, uint256[] ids, uint256[] amounts, bytes data)


// 토큰 유형 ID의 값 토큰이 연산자에 의해 에서 로 전송될 때 내보내집니다.
TransferSingle(address operator, address from, address to, uint256 id, uint256 value)


// 여러 전송 단일 이벤트와 동일하며, 여기서 연산자는 모든 전송에 대해 동일하다.
TransferBatch(address operator, address from, address to, uint256[] ids, uint256[] values)


// 승인에 따라 계정이 운영자에게 토큰을 전송할 수 있는 권한을 부여하거나 취소할 때 방출됩니다.
ApprovalForAll(address account, address operator, bool approved)


// 토큰 유형 ID에 대한 URI가 비프로그램 URI인 경우 값으로 변경될 때 배출됩니다.
// ID에 대해 URI 이벤트를 내보낸 경우 표준에서는 값이 IERC1155Metadata에서 반환한 값과 동일함을 보장합니다.우리우리.우리.
URI(string value, uint256 id)


// 토큰 유형 ID에 대한 URI를 반환합니다.
// URI에 {id} 하위 문자열이 있는 경우 실제 토큰 유형 ID를 가진 클라이언트로 교체해야 합니다.
uri(uint256 id) → string
*/

// 참고
// https://github.com/redqoralsrl/DoBuyShop_Dapp/blob/master/contracts/DoBuyNFT.sol
// https://github.com/enjin/erc-1155/blob/master/contracts/ERC1155.sol
// https://docs.openzeppelin.com/contracts/4.x/api/token/erc1155
// https://docs.openzeppelin.com/contracts/4.x/erc1155
// https://docs.openzeppelin.com/contracts/4.x/erc1155#multi-token-standard
// https://soliditydeveloper.com/erc-1155
// https://github.com/gnosis/ido-contracts/tree/main/contracts
// https://merrily-code.tistory.com/102
// https://docs.soliditylang.org/en/latest/solidity-by-example.html#blind-auction
/*
contract UsedMoaToken_v2 is ERC1155 {

    // 참여자 구조체
    struct User {
        address addr; // 계정 주소
        uint    value; // 참여 금액
        string  nickName; // 참여자 닉네임
        string  email; // 참여자 이메일
    }

    // 참여자 목록
    mapping (address => User[]) public users;

    address private owner;
    uint    private numUsers;

    // 현재 경매의 최고가
    uint    public  value;
    // 최고가를 제시한 참여자 주소
    address private lastUser;
    // 경매 종료 여부
    bool    public  isEnd;
    // 최종 낙찰된 참여자 정보
    User    private confirmedUser;

    // 미술품 및 주최자 정보 링크
    string  public  url;
    // 링크 페이지의 해시 값
    string  public  pagehash;

    // 경매 마감 기간(~까지)
    uint    public  deadline;
    // 상한액
    uint    public  raiseLimit;



    // 소유자 접근 제한자
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    // 계약 생성자 (소유자만 접근)
    // _url: 미술품 정보 링크, _pagehash: 링크 페이지의 해시 값,
    // _deadline: 마감기간, _initValue: 초기금액, _raiseLimit: 상한액
    /*
    구조체, 배열 또는 매핑 유형의 모든 변수에 대한 명시적 데이터 위치는 이제 필수입니다.
    이는 함수 매개변수 및 반환 변수에도 적용됩니다.
    Storage는 블록체인 상에 영구적으로 저장되며, Memory는 임시적으로 저장되는 변수로 함수의 외부 호출이 일어날 때마다 초기화됩니다.

    constructor(string memory _pagehash, string memory _url, uint _deadline, uint _initValue, uint _raiseLimit) UsedMoaToken_v2()  {
        console.log("constructor play: ",block.timestamp);

        owner = msg.sender;
        numUsers = 0;
        value = _initValue;
        isEnd = false;
        url = _url;
        pagehash = _pagehash;
        deadline = block.timestamp + _deadline;
        raiseLimit = _raiseLimit;
    }
    function helloWorld() external pure returns (string memory) {
        return "Hello, World!";
    }


    // 경매에 참여 _nickName: 참여자 닉네임, _email: 참여자 이메일
    function join(string memory _nickName, string memory _email) public payable {
        require(!isEnd);
        require(block.timestamp < deadline);
        require(msg.value == value);

        uint idx = 0;

        while (idx <= numUsers) {
            // 이미 참여된 경우 revert
            if (users[idx].addr == msg.sender) {
                revert();
            }
            idx++;
        }

        // 참여자 정보 추가
        User memory user = users[numUsers++];
        user.addr = msg.sender;
        user.value = msg.value;
        user.nickName = _nickName;
        user.email = _email;
    }
}
*/