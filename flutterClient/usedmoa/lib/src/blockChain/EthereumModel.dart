import 'dart:convert';

import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/services.dart';
import 'dart:math'; //used for the random number generator
import 'package:http/http.dart' as http;

// ropsten 서버 API 주소
const String rpcUrl =
    'https://eth-ropsten.alchemyapi.io/v2/FcTHGX5ISmTOcsLlJaAFUX6mkQ2zveoa';
const String wsUrl =
    'wss://mainnet.infura.io/ws/v3/4adb7d9a95bf437888c310c2ecf256fe';

// 유저 메타마스크 비공개 키
const String privateKey =
    '5d53c18c1dc07675c7a75cc6e412a21dfcbee6c21e46ec1ce2d85327dd61a195';
const String account1Key =
    '09303a22958160a9aded1393cd879378d1486f00b0e7b057c32dff48f0f69bb0';
const String account2Key =
    '5d53c18c1dc07675c7a75cc6e412a21dfcbee6c21e46ec1ce2d85327dd61a195';
const String account3Key =
    '2f62baf3d52e8a7e0548849225b82875309fe6bed999d45f80fb11d851ec4580';

// 유저 지갑 주소 정보
const myAddress = "0xE868E6018f5c0220fd645e18BC3B222D2fDC8011";
const account1Address = "0x01F932f06415665152aD83728E9E82cD63ba812D";
const account2Address = "0xE868E6018f5c0220fd645e18BC3B222D2fDC8011";
const account3Address = "0xDaAAEB797Fce9BB4CC8f1AED92662fD05e7731b2";

// 이더리움 네트워크에 배포된 ERC-20 코인(UsedMoaToken) Contract 주소 정보
final EthereumAddress _contractAddress = EthereumAddress.fromHex('0x3a79773d8d0b204f8984afd9927f008a05116d59');

class Ethereum {
  // 싱글턴
  static final Ethereum _instance = Ethereum._internal();

  factory Ethereum() {
    return _instance;
  }

  Ethereum._internal() {
    //클래스가 최초 생성될때 1회 발생
    //초기화 코드

    print('Singleton was created.');
  }

  var _client; // Client 변수는 WebSocket의 도움으로 ethereum rpc 노드에 연결하는 데 사용됩니다.
  var _credentials; // Credentials 변수는 스마트 계약 배포자의 자격 증명을 저장합니다.
  var _ownAddress; // EthereumAddress
  var myData;

  // Web3Client - 참고: https://github.com/simolus3/web3dart/blob/development/example/contracts.dart
  // https://medium.com/@dev_89267/develop-blockchain-applications-with-flutter-ethereum-59e846944127
  Future<void> loadContract() async {
    print("loadContract() 실행");

    // 이더리움 rpc 노드에 대한 연결을 설정합니다. 소켓 커넥터
    // 속성은 대신 웹 소켓을 통해 보다 효율적인 이벤트 스트림을 loadContract허용합니다.
    _client = Web3Client(rpcUrl, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });

    // await getCredentials();
    // await getBalance();
    // await getTokenName();
    // var response =  await sendTokens(account3Address, 1);
  }

  // 유저 정보 조회
  Future<void> getCredentials() async {
    _credentials = await _client.credentialsFromPrivateKey(privateKey);
    _ownAddress = await _credentials.extractAddress();

    // Or generate a new key randomly
    var rng = new Random.secure();
    EthPrivateKey credentials = EthPrivateKey.createRandom(rng);

    var address = await credentials.extractAddress();
    print("getCredentials() 실행 - address ${address.hex}");

    // Wallet wallet = await Wallet.createNew(credentials, "!tes1", rng);
    // print("wallet: ${wallet.toJson()}");
  }

  // 코인의 contract 정보 초기화
  Future<DeployedContract> loadedContract() async {
    String abi = await rootBundle.loadString("assets/erc20_abi.json");
    final contract = DeployedContract(ContractAbi.fromJson(abi, "UsedMoaToken"), _contractAddress);
    return contract;
  }

  // 지갑 생성 - 참고: https://github.com/simolus3/web3dart
  // 번호 생성기에서 임의의 새 개인 키를 만듭니다.
  Future<String> createWallet() async {
    // 새로운 EthPrivateKey 랜덤키 생성
    var random = new Random.secure();
    EthPrivateKey credentials = EthPrivateKey.createRandom(random);

    // 지갑 생성 - ciphertext 값으로 메타마스크 지갑 추가 가능
    Wallet wallet = Wallet.createNew(credentials, "password", random);
    print("wallet 생성: ${wallet.toJson()}");
    final data = json.decode(wallet.toJson());
    print("data['crypto']['ciphertext']: ${data['crypto']['ciphertext']}");
    print("data['version']: ${data['version']}");
    print("data['id']: ${data['id']}");

    // 프라이빗키 주소 정보 호출
    var address = await credentials.extractAddress();
    print("getCredentials() 실행 - address ${address.hex}");

    // 보유 이더리움 조회
    // EthereumAddress _contractAddress = EthereumAddress.fromHex(address.hex);
    // List<dynamic> result = await readContract("getBalance", [_contractAddress]);
    //
    // // BigInt 처리 - 참고: https://dart.dev/tools/diagnostic-messages#integer_literal_out_of_range
    // var resultValue = BigInt.parse(result[0].toString());
    // var divValue = BigInt.parse('1000000000000000000');
    //
    // print("createWallet - getBalance() 실행: ${(resultValue / divValue).floor()}");

    return "test";
  }

  /**
   *   토큰 조회
   *   @dev 입력한 지갑 주소의 잔액을 조회
   *   @param wallet 조회할 지갑
   *   @return 해당 지갑 수량 반환
   */
  Future<String> getBalance() async {
    EthereumAddress _contractAddress = EthereumAddress.fromHex(myAddress);
    List<dynamic> result = await readContract("getBalance", [_contractAddress]);

    // BigInt 처리 - 참고: https://dart.dev/tools/diagnostic-messages#integer_literal_out_of_range
    var resultValue = BigInt.parse(result[0].toString());
    var divValue = BigInt.parse('1000000000000000000');

    print("getBalance() 실행 - 잔액: ${(resultValue / divValue).floor()}");

    // 소수점 버리기 참고: https://dev-yakuza.posstree.com/ko/flutter/dart/ceil-floor-round/
    return (resultValue / divValue).floor().toString();
  }

  // 토큰 이름 조회 - 참고: https://www.youtube.com/watch?v=3Eeh3pJ6PeA&t=152s
  Future<void> getTokenName() async {
    List<dynamic> result = await readContract("_token", []);

    print("getTokenName: ${result[0]}");
  }

  // 컨트렉트 조회용 함수
  // 참고: https://github.com/misterkailash/vivo_registry_app/blob/33b56d14ff6250786cd9c0cc25cbf3400ceee31d/lib/config/eth_client.dart
  Future<List<dynamic>> readContract(String functionName, List<dynamic> args) async {
    await loadContract();
    final contract = await loadedContract();
    final ethFunction = contract.function(functionName);
    //
    print("contract: ${contract}, ethFunction: ${ethFunction}");

    var result = await _client.call(
      contract: contract,
      function: ethFunction,
      params: args,
    );

    return result;
  }

  /**
      토큰 전송
   *   @dev 일반 사용자만 토큰을 입력한 주소로 보낸다.
   *   @param _to 보낼 주소를 입력
   *   @param _amount 보낼 토큰의 양을 입력
   */
  Future<String> sendTokens(dynamic money) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    EthereumAddress _targetAdress = EthereumAddress.fromHex(account3Address);
    BigInt mount = BigInt.parse('${money}000000000000000000');

    print("_targetAdress: ${_targetAdress}, money: ${money}, myAddress: ${myAddress}");

    final contract = await loadedContract();
    final ethFunction = contract.function("sendTokens");
    var result = await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: [_targetAdress, mount],
      ),
      chainId: 3,
    );

    print("sendTokens() 실행 - sendTokens: ${result}");

    return result;
  }
}