/*
다음의 간단한 경매 계약의 일반적인 생각은 모든 사람이 입찰 기간 동안 그들의 입찰서를 보낼 수 있다는 것이다.
입찰에는 입찰자들을 입찰에 묶기 위해 돈을 보내는 것이 이미 포함되어 있다.
만약 최고 입찰가가 인상되면, 이전의 최고 입찰자는 그들의 돈을 돌려받는다.
입찰기간이 끝나면 수작업으로 계약을 체결해 돈을 받아야 하지만 계약 자체가 활성화될 수 없다.
*/
// 참고
// https://kyber.tistory.com/20
// http://tujac.com/%EC%8A%A4%EB%A7%88%ED%8A%B8-%EC%BB%A8%ED%8A%B8%EB%9E%99%ED%8A%B8-%EB%84%A4%ED%8A%B8%EC%9B%8C%ED%81%AC-smart-contract-network%EB%9E%80/
// https://github.com/tintinweb/smart-contract-sanctuary/blob/f1ba2d3302c77052189d74d8411d682163134765/contracts/ropsten/9c/9C04D0cFcFC5aAe4055c6A68DDfF030fD7346dF1_NFTBase.sol
// https://github.com/tintinweb/smart-contract-sanctuary/blob/20554c71968c346f5e712983f7e1eef660323b25/contracts/ropsten/56/56BC85B949Edb00B145242c1Ce057641bc8BAaBF_NFTBase.sol
// https://solidity-kr.readthedocs.io/ko/latest/solidity-by-example.html#id6
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;


import "hardhat/console.sol"; // 배포시 로그 제거


contract SimpleAuction {
    // 옥션의 파라미터. 시간은 아래 둘중 하나입니다.
    // 앱솔루트 유닉스 타임스탬프 (seconds since 1970-01-01)
    // 혹은 시한(time period) in seconds.
    address payable public beneficiary;
    uint public auctionEndTime;

    // 경매 현황입니다.
    address public highestBidder;
    uint public highestBid;

    // 이전 가격 제시들의 수락된 출금.
    mapping(address => uint) pendingReturns;

    // 마지막에 true로 설정하면 어떤 변경도 허용하지 않습니다. 기본값 : 'false'
    bool ended;

    // 변경에 발생하는 이벤트
    // 이벤트는 EVM 로깅 기능과의 편리한 인터페이스입니다.
    // 호출하면 인수가 트랜잭션 로그에 저장됩니다. 즉, 블록체인의 특수 데이터 구조입니다.
    // 이러한 로그는 계약의 주소와 연결되고 블록체인에 통합되며 블록에 액세스할 수 있는 한 그대로 유지됩니다.
    // https://docs.soliditylang.org/en/v0.8.9/contracts.html#events
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // 아래의 것은 소위 "natspec"이라고 불리우는 코멘트,
    // 3개의 슬래시에 의해 알아볼 수 있습니다.
    // 이것을 유저가 트렌젝션에 대한 확인을 요청 받을때 보여집니다.

    // 작업이 실패한 이유를 사용자에게 설명하는 편리하고 가스 효율적인 방법을 제공
    // 현재 호출의 모든 변경 사항을 되돌리고 오류 데이터를 호출자에게 다시 전달하는
    // revert 문과 함께 사용해야 합니다.
    /// 경매는 이미 끝났다.
    error AuctionAlreadyEnded();
    /// 이미 더 높거나 같은 입찰가가 있습니다.
    error BidNotHighEnough(uint highestBid);
    /// 경매는 아직 끝나지 않았다.
    error AuctionNotYetEnded();
    /// optionEnd 함수가 이미 호출되었습니다.
    error AuctionEndAlreadyCalled();


    // 1) 생성자 - 기능 : 경매 시간 및 수혜자를 설정합니다.
    // _biddingTime : 현재로 부터 얼마동안 경매를 진행할 것인지 설정하며
    // _beneficiary : 이 경매가 끝났을 때 수혜자를 설정하게 됩니다.
    /// 수혜자의 주소를 대신하여 두번째 가격제시 기간 '_biddingTime'과
    /// 수혜자의 주소 '_beneficiary' 를 포함하는 간단한 옥션을 제작합니다.
    constructor(
        uint biddingTime,
        address payable beneficiaryAddress
    ) {
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;
    }


    /// 경매에 대한 가격제시와 값은 이 transaction과 함께 보내집니다.
    /// 값은 경매에서 이기지 못했을 경우만  반환 받을 수 있습니다.
    // 2) bid() - 기능 : ETH를 이용해 경매에 참여합니다.
    // 그러면 이제 경매에 참여하기 위해서는 bid 라는 함수를 실행함과 동시에, Ether를 전송해야 합니다.
    // 이 거래와 함께 보내진 가격으로 경매에 입찰하세요.
    // 경매에서 낙찰되지 않은 경우에만 가격이 환불됩니다.
    function bid() public payable {
        // 인수가 필요하지 않으므로 모든 정보가 이미 트랜잭션의 일부입니다.
        // Ether를 수신할 수 있으려면 지불 가능한 키워드가 필요합니다.
        // 경매참여자들이 msg.value에 가격을 넣어 보낸다.???

        // 어떤 인자도 필요하지 않음, 모든
        // 모든 정보는 이미 트렌젝션의  일부이다. 'payable' 키워드는
        // 이더를 지급는 것이 가능 하도록 하기 위하여 함수에게 요구됩니다.

        // 입찰 기간이 끝나면 통화를 되돌립니다.
        // 경매가 끝나지 않았는지 확인한다.
        // 현재 시간이 경매가 끝난 시간 이후인지를 확인하는 구문
        // 경매 기간이 끝났으면 되돌아 갑니다.
        if (block.timestamp > auctionEndTime)
            revert AuctionAlreadyEnded();


        // 입찰가가 기존최고 입찰가격을 상회하여야 한다.
        // 입찰가가 높지 않으면 돈을 돌려보내라.(리턴 문은 돈을 받은 경우를 포함하여 이 기능 실행의 모든 변경 사항을 되돌립니다.)
        // 함수를 실행하며 보내는 Ether가 가장 높은 가격인지 확인합니다.
        // 만약 이 가격제시가 더 높지 않다면, 돈을 되돌려 보냅니다.
        if (msg.value <= highestBid)
            revert BidNotHighEnough(highestBid);


        // 기존 최고 입찰가가 0이 아닌 경우 기존 입찰자에게 경매금액을 돌려줄 준비를 한다.
        // 기존 가장 높은 가격을 제시했던 입찰자는 pendingReturns라는 map 자료형에 저장될 것이고,
        // 가장 높은 입찰가와 입찰 가격은 Transaction을 보낸 사람으로 설정될 것입니다.
        if (highestBid != 0) {
            // 단순히 highestBidder.send(highestBid)를 사용하여 돈을 돌려보내는 것은
            // 신뢰할 수 없는 계약을 실행할 수 있기 때문에 보안상의 위험입니다.
            // 받는 사람이 스스로 돈을 인출하도록 하는 것이 항상 더 안전하다.

            // 간단히 highestBidder.send(highestBid)를 사용하여 돈을 돌려 보내는 것은 보안상의 리스크가 있습니다.
            // 그것은 신뢰되지 않은 콘트렉트를 실행 시킬수 있기 때문입니다.
            // 받는 사람이 그들의 돈을 그들 스스로 출금 하도록 하는 것이 항상 더 안전합니다.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;

        // 이제 최고 입찰자와 최고가가 바뀌고 이를 알리는 이벤트를 생성한다.
        emit HighestBidIncreased(msg.sender, msg.value);
    }


    // 4) withdraw() - 기능 : 최고 입찰자가 아닌 경매 참여자들이 ETH를 인출합니다.
    /// 비싸게 값이 불러진 가격제시 출금.
    /// 초과 입찰된 입찰을 철회하십시오.
    // 이후에 최고 입찰자가 아닌 사람들은 withdraw() 함수를 호출할 것입니다.
    // 별도의 시간은 검사하고 있지 않으니, 계약이 계속 지속되는 한 언제든 출금할 수 있습니다.
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];

        // 입찰 취소를 하는 경우입찰자의 입찰가가 0보다 커야하고 이런경우 돌려줄 준비가된 입찰 금액을 함수 호출자에게 돌려준다.
        // 그리고 돌려주어야 할 금액을 0으로 만든다.
        if (amount > 0) {
            // 수신자는 '보내기'가 돌아오기 전에 수신 전화의 일부로
            // 이 기능을 다시 호출할 수 있으므로 이 기능을 0으로 설정하는 것이 중요하다.
            // 받는 사람이 이 `send` 반환 이전에 받는 호출의 일부로써 이 함수를 다시 호출할 수 있기 때문에 이것을 0으로 설정하는 것은 중요하다.
            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                // 여기 전화 던질 필요 없이, 빚진 금액을 재설정하세요.
                // 여기서 throw를 호출할 필요가 없습니다, 빚진 양만 초기화.
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }


    // 3) auctionEnd() - 기능 : 경매 가능한 시간이 지나면 경매를 종료하고 수혜자에게 ETH를 전달합니다.
    // 경매를 끝내고 수익자에게 최고 입찰가를 보내라.
    // 경매가 종료됐다는 가정하에 경매 종료 함수를 호출한다.
    /// 이 경매를 끝내고 최고 가격 제시를 수혜자에게 송금.
    function auctionEnd() public {
        // 다른 계약과 상호작용하는 기능을 구조화하는 것은 좋은 지침이다. (즉, 함수를 호출하거나 에테르를 전송한다)
        // 세 단계로 나누어:
        // 1. 점검 조건
        // 2. 작업 수행(조건이 크게 변경됨)
        // 3. 다른 계약과의 상호 작용
        // 이러한 단계가 혼합된 경우, 다른 계약은 현재 계약으로 다시 요청하여
        // 여러 번 실시되는 상태 또는 원인(에테르 지급)을 수정할 수 있다.

        // 내부적으로 호출되는 기능이 외부 계약과의 상호작용을 포함하는 경우, 외부 계약과의 상호작용도 고려해야 한다.

        // 1. 조건들 - 경매 종료 시간이 지금보다 이전이어야 하고
        if (block.timestamp < auctionEndTime)
            revert AuctionNotYetEnded();
        if (ended) // 종료 플래그가 종료가 아닌경우
            revert AuctionEndAlreadyCalled();

        // 2. 영향들 - 종료 플래그를 종료로 바꾼다.
        ended = true;

        // 경매가 종료됐음을 이벤트로 알리고
        emit AuctionEnded(highestBidder, highestBid);

        // 3. 상호작용 - 출품자에게 최고가를 보낸다.
        // 미리 스마트 컨트랙트에 설정된 수혜자(beneficiary)는 가장 높게 예치된 Ether를 전송받고 해당 계약은 종료됩니다.
        beneficiary.transfer(highestBid);
    }


    /**
     mint :   NFT Token 발행
    // Only incaseof private market, check if caller has a minter role
    function mint(uint256 supply, string memory uri, address creator, uint256 royaltyRatio) public returns(uint256 id) {
        require(supply > 0,"NFTBase/supply_is_0");
        require(!compareStrings(uri,""),"NFTBase/uri_is_empty");
        require(creator != address(0),"NFTBase/createor_is_0_address");
        require(_royaltyMinimum <= royaltyRatio && royaltyRatio <= _royaltyMaximum,"NFTBase/royalty_out_of_range");

        if(_isPrivate)
            require(hasRole(MINTER_ROLE,_msgSender()),"NFTBase/caller_has_not_minter_role");
        id = ++_currentTokenId;

        _tokens[id].supply  = supply;
        _tokens[id].uri     = uri;
        _tokens[id].creator = creator;
        _tokens[id].royaltyRatio = royaltyRatio;

        ERC1155._mint(_msgSender(),id,supply,"");    // TransferSingle Event

        emit Mint(id,supply,uri,creator,royaltyRatio);
    }

    // tokenURI : NFT Token uri 조회 MI
    function tokenURI(uint256 id) external view returns (string memory) {
        return  _tokens[id].uri;
    }

    // getCreator : NFT Creator조회
    function getCreator(uint256 id) external view returns (address) {
        return _tokens[id].creator;
    }

    // getRoyaltyRatio : NFT RoyaltyRatio 조회
    function getRoyaltyRatio(uint256 id) external view returns (uint256) {
        return _tokens[id].royaltyRatio;
    }
*/
}