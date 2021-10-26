// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../auction/SimpleAuction.sol";

// 참고:  https://docs.soliditylang.org/en/v0.8.9/style-guide.html
// contract UsedMoaTokenV3 is ERC1155, Ownable, Pausable {
contract UsedMoaTokenV3 is ERC1155, Ownable {

    string public name;
    string public symbol;

    // 토큰 타입
    uint256 public constant TOKEN = 0;
    uint256 public constant AUCTION = 1;


    constructor(
        string memory name_,
        string memory symbol_
    ) ERC1155("ipfs://usedmoa/api/{id}.json") { // ipfs 주소 작성
        name = name_;
        symbol = symbol_;
        _mint(msg.sender, TOKEN, 10**27, "");
        _mint(msg.sender, AUCTION, 1, "");
    }


    /**
     *   @dev 토큰 발급
     *   @param _account 사용자 계정 정보
     *   @param _id 토큰 타입
     *   @param _amount 생성할 토큰양
     */
    function mintTokens(
        address _account,
        uint256 _id,
        uint256 _amount
    ) public onlyOwner {
        _mint(_account, _id, _amount, "http://localhost/nft{id}.json");
    }


    /**
     *   @dev 입력한 지갑 주소의 잔액을 조회
     *   @param account 조회할 계정
     *   @param id 토큰 타입
     *   @return 해당 지갑 수량 반환
     */
    function getBalance(address account, uint256 id) public view returns(uint256){
        return balanceOf(account, id);
    }


    /**
     *   @dev 토큰을 입력한 주소로 보낸다.
     *   @param _from 발신자 주소 입력
     *   @param _to 수신자 주소를 입력
     *   @param _id 토큰 타입 입력
     *   @param _amount 보낼 토큰의 양을 입력
     */

    // external, public, internal, private 중 하나로 visibility를 설정 가능 (아래 참고)
    // payable, view, pure 등 함수 유형을 정의 가능
    function sendToken(address _from, address _to, uint256 _id, uint256 _amount) public payable {
        safeTransferFrom(_from, _to, _id, _amount, "");
    }


    // 기본 ERC-1155 인터페이스에서 제공해주는 uri 기능이 제대로 안됨 따라서, 오버라이드 해서 기능 수정 처리 진행함
    /**
     *   @dev 사용자 URI 정보 조회
     *   @param _tokenid 토큰 타입 입력
     *   @return URI 정보 반환
     */
    /**
    "name": "Thor's hammer",
    "description": "Mjölnir, the legendary hammer of the Norse god of thunder.",
    "image": "https://game.example/item-id-8u5h2m.png",
    "strength": 20
    */
    function uri(uint256 _tokenid) public view virtual override returns (string memory) {
        return string(abi.encodePacked("https://localhost/",Strings.toString(_tokenid),".json"));
    }


    function createAuction() public view returns (string memory) {
        console.log("createAuction");
        return string("https://localhost/");
    }
}