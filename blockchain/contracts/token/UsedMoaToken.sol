// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract UsedMoaToken is ERC20 {
    

    /// @notice 토큰 이름
    string public constant _token = "UsedMoaToken";

    /// @notice 토큰 기호
    string public constant _symbol = "UMT";

    /// @notice 십진법
    uint8 public constant _decimals = 18;

    /// @notice 토큰 발행 개수
    uint256 public constant INITIAL_SUPPLY = 2500000000000000000000000000;
    
    /// @notice 유저 지갑
    address public user_wallet = payable(msg.sender);

    /// @notice 토큰 잔액 - 여기 각 계좌 잔액을 저장합니다.
    mapping(address => uint256) balances;

    /// @notice 토큰 처음 만들어진 시간
    uint256 firstListingDate;

    /// @notice 최초 1회 실행 constructor
    constructor() ERC20("UsedMoaToken", "UMT") {
        address owners = msg.sender; // 지갑 주인
        _mint(owners, INITIAL_SUPPLY); // 토큰 발행
    }

    // 토큰전송
    mapping(address => uint256) public sendAmount; // 토큰을 얼마나 보냈는 지 확인을 위한 변수
    event SendToken(address from, address to, uint256 amount);


    // 토큰취소
    mapping(address => uint256) public cancelAmount; // 취소된 토큰 양


    // 토큰 이름
    /**
     *   @dev 토큰 이름 조회
     *   @return 해당 토큰 이름 반환
     */
    function tokenName() public pure returns(string memory) {
        return _token;
    }


    // 토큰 조회
    /**
     *   @dev 입력한 지갑 주소의 잔액을 조회
     *   @param wallet 조회할 지갑
     *   @return 해당 지갑 수량 반환
     */
    function getBalance(address wallet) public view returns(uint256){
        return balanceOf(wallet);
    }


    // 토큰 전송 - 일반 사용자만 가능
    /**
     *   @dev 일반 사용자만 토큰을 입력한 주소로 보낸다.
     *   @param _to 보낼 주소를 입력
     *   @param _amount 보낼 토큰의 양을 입력
     */
    function sendTokens(address _to, uint256 _amount) public {

        // 'require'의 첫 번째 인수가 'false'로 평가될 경우 트랜잭션이 되돌아갑니다.
        require(balanceOf(user_wallet) >= _amount, "Not Enough UMT");
        transfer(_to, _amount);
        sendAmount[user_wallet] += _amount;
        emit SendToken(user_wallet, _to, _amount);
    }    


    // 토큰 발급
    /**
     *   @dev 주소와 토큰 양을 적어서 보낸다. _mint 함수에서 토큰을 생성한다.
     *   @param to 받을 지갑 주소
     *   @param _amount 토큰 양
     */
    function tokenMint(address to, uint256 _amount) public {
        _mint(to, _amount);
    }


    // 토큰 소각
    /**
     *   @dev 주소와 토큰 양을 적어서 보낸다. _burn 함수에서 토큰을 생성한다.
     *   @param from 받을 지갑 주소
     *   @param _amount 토큰 양
     */
    function tokenBurn(address from, uint256 _amount) public {
        _burn(from, _amount);
    }


    // 토큰 정지
    /**
     *   @dev 해당 계약을 일시 중지한다.
     *   @param _from 보내는 지갑 주소
     *   @param _to 받는 지갑 주소
     *   @param _amount 보낸 토큰의 양
     */
    function tokenPause(address _from, address _to, uint256 _amount) public {
        _beforeTokenTransfer(_from, _to, _amount);
        cancelAmount[_from] -= _amount;
    }
}