# 중고모아 (Usedmoa)


### 프로젝트 개요

- 서비스 소개
	- 블록체인 기반 중고거래 플랫폼 서비스

- 개발 인원
	- 1명

- 개발 기간
	- 2021.08.06 ~ 진행중


### 사용 기술
- 언어
	- Dart, JavaScript, Solidity

- 프로토콜
	- HTTPS, WebRTC, WebSocket, IPFS

- 서버
	- Nginx, Nodejs

- 데이터베이스
	- MariaDB

- 프레임워크
	- Flutter, Expressjs

- 라이브러리
	- Web3.js, Ipfs, OpenZepplin, Jsonwebtoken, Mp2, OpenVidu, Axios, Cors, Dotenv ..,

- 사용한 디자인 패턴
	- MVC, BLOC 패턴


### 서비스 구성도

![중고모아_아키텍처](https://user-images.githubusercontent.com/24368929/138834802-d46aa00f-15ed-458e-9ed1-b0db72f60874.PNG)

### 주요 기능
- 로그인 / 회원가입 : 로그인 API를 사용한 JWT 방식의 로그인

- 상품 게시판 : 상품 등록, 수정, 삭제 기능

- 1대1 영상통화 : OpenViup 서버를 이용한 MCU 방식의 WebRTC 영상 통화

- VOD 다시보기 : 1대1 영상통화 내용을 자동으로 녹화하여 다시보기 기능 제공

- 결제 기능 : ERC-1155 토큰을 사용하여 중고 물품 결제

- 경매 기능 : NFT 기술을 사용하여 경매 이력을 이더리움 네트워크에 공개

![경매사진](https://user-images.githubusercontent.com/24368929/140262741-5cbbd29f-246f-46bb-ac1e-cda7982e268e.PNG)
