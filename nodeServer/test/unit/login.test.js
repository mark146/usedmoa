// 단위 테스트를 위한 unit 폴더
// 단위 테스트 파일 [대상 이름].test.js
const {userController} = require("../../controllers");
const {userService} = require("../../services");
const {userModel} = require("../../models");
const httpMocks = require('node-mocks-http');

// Mock 함수 생성
userService.kakaoTokenCheck = jest.fn();

// beforeEach는 전체 테스트 코드에 적용되는 경우에는 describe들 밖에 선언하고, 특정 describe 내에서만 사용되면 describe 내에 선언,
// 참고 : https://github.com/howardabrams/node-mocks-http
let req, res, next;
beforeEach(() => {
    req = httpMocks.createRequest();
    res = httpMocks.createResponse();
    next = null;
});


// describe : 안에 있는 모든 테스트를 테스트하겠음을 의미
describe("UserController Create", () => {

    // expect("예상할부분").toBe("예상값")
    it("userController.login 함수 존재 여부 확인", () => {

        // userController에 login 함수가 있는지 여부를 확인하기 위한 테스트 코드
        expect(typeof userController.login).toBe("function");
    })

    /*
    Kakao_Login_accessToken: Gbeu-Tq75dmV17w-zhp7WEk09wTsYQxpOH5qzwo9c00AAAF80LOzFg
    Kakao_Login_refreshToken: K_eR37RNVJPe2T_IpU76WUQeQ1__5fVw1Eyh2wo9c00AAAF80LOzFA
    */
    // Mock 데이터 넣어주기
    beforeEach(() => {
        req.headers = {
            "authorization" : "Bearer Gbeu-Tq75dmV17w-zhp7WEk09wTsYQxpOH5qzwo9c00AAAF80LOzFg"
        }
        req.body = {
            "email": "test"
        };
    });


    //createProduct 함수를 호출할 때 Product Model의 Create 메소드가 호출이 되는지를 확인 해주기 위한 테스트 코드
    it('should call userService.kakaoTokenCheck', () => {
        userController.login(req, res, next); // userController.login()이 호출 될 때,
        expect(userService.kakaoTokenCheck).toBeCalled(); // userService.kakaoTokenCheck 가 호출되는지 확인
    });
})