// OpenVidu 메소드 및 프론트 백 엔드 통신을 호스팅하는 자바 스크립트 파일

var OV;
var session;

var sessionName;
var token;
var numVideos = 0;

// 유저 정보 생성
function createSession(create_user, board_id) {
	console.log("createSession 실행 : ",create_user);
	console.log("createSession 실행 : ",board_id);
	document.getElementById('create_user').value = create_user;
	document.getElementById('board_id').value = board_id;
}


/* OPENVIDU METHODS */
function joinSession() {

	// --- 0) Change the button ---
	// 1. Join 버튼 비활성화 후 내용 변경
	// document.getElementById("join-btn").disabled = true;
	// document.getElementById("join-btn").innerHTML = "Joining...";


	getToken(function () {

		// --- 1) Get an OpenVidu object ---
		OV = new OpenVidu();

		// --- 2) Init a session ---
		session = OV.initSession();


		// 3. 세션에서 이벤트가 발생할 때 수행할 작업 지정
		session.on('connectionCreated', event => {
			pushEvent(event);
			console.log("connectionCreated");
		});

		session.on('connectionDestroyed', event => {
			pushEvent(event);
			console.log("영상통화 종료");
			if(session.remoteStreamsCreated.size == 0) {
				stopRecording();
			}
		});

		// On every new Stream received...
		session.on('streamCreated', event => {
			pushEvent(event);
			console.log("streamCreated");

			// Subscribe to the Stream to receive it
			// HTML video will be appended to element with 'video-container' id
			var subscriber = session.subscribe(event.stream, 'video-container');

			// When the HTML video has been appended to DOM...
			subscriber.on('videoElementCreated', event => {
				pushEvent(event);
				console.log("videoElementCreated");

				// Add a new HTML element for the user's name and nickname over its video
				updateNumVideos(1);
			});

			// When the HTML video has been appended to DOM...
			subscriber.on('videoElementDestroyed', event => {
				pushEvent(event);
				console.log("videoElementDestroyed");

				// Add a new HTML element for the user's name and nickname over its video
				updateNumVideos(-1);
			});

			// When the subscriber stream has started playing media...
			subscriber.on('streamPlaying', event => {
				pushEvent(event);
				console.log("streamPlaying - 영상통화 시작: ", session);
				if(session.streamManagers[1].lazyLaunchVideoElementCreatedEvent == true) {
					startRecording();
				}
			});
		});

		session.on('streamDestroyed', event => {
			pushEvent(event);
			console.log("streamPlaying");
		});

		session.on('sessionDisconnected', event => {
			pushEvent(event);
			console.log("sessionDisconnected: ",event.reason);

			if (event.reason !== 'disconnect') {
				removeUser();
			}
			if (event.reason !== 'sessionClosedByServer') {
				session = null;
				numVideos = 0;
				// $('#join').show();
				// $('#session').hide();
			}
		});

		session.on('recordingStarted', event => {
			pushEvent(event);
			console.log("recordingStarted");
		});

		session.on('recordingStopped', event => {
			pushEvent(event);
			console.log("recordingStarted");
		});

		// On every asynchronous exception...
		session.on('exception', (exception) => {
			console.warn(exception);
			console.log("exception");
		});

		// --- 4) Connect to the session passing the retrieved token and some more data from
		//        the client (in this case a JSON with the nickname chosen by the user) ---
		session.connect(token)
			.then(() => {

				// --- 5) Set page layout for active call ---
				$('#session-title').text(sessionName);
				// $('#join').hide();
				// $('#session').show();


				// --- 6) Get your own camera stream ---
				var publisher = OV.initPublisher('video-container', {
					audioSource: undefined, // The source of audio. If undefined default microphone
					videoSource: undefined, // The source of video. If undefined default webcam
					publishAudio: true, // Whether you want to start publishing with your audio unmuted or not
					publishVideo: true, // Whether you want to start publishing with your video enabled or not
					resolution: '640x480', // The resolution of your video
					frameRate: 30, // The frame rate of your video
					insertMode: 'APPEND', // How the video is inserted in the target element 'video-container'
					mirror: false // Whether to mirror your local video or not
				});


				// --- 7) Specify the actions when events take place in our publisher ---
				// When the publisher stream has started playing media...
				publisher.on('accessAllowed', event => {
					pushEvent({
						type: 'accessAllowed'
					});
				});

				publisher.on('accessDenied', event => {
					pushEvent(event);
				});

				publisher.on('accessDialogOpened', event => {
					pushEvent({
						type: 'accessDialogOpened'
					});
				});

				publisher.on('accessDialogClosed', event => {
					pushEvent({
						type: 'accessDialogClosed'
					});
				});

				// When the publisher stream has started playing media...
				publisher.on('streamCreated', event => {
					pushEvent(event);
				});

				// When our HTML video has been added to DOM...
				publisher.on('videoElementCreated', event => {
					pushEvent(event);
					updateNumVideos(1);
					$(event.element).prop('muted', true); // Mute local video
				});

				// When the HTML video has been appended to DOM...
				publisher.on('videoElementDestroyed', event => {
					pushEvent(event);
					// Add a new HTML element for the user's name and nickname over its video
					updateNumVideos(-1);
				});

				// When the publisher stream has started playing media...
				publisher.on('streamPlaying', event => {
					pushEvent(event);
				});

				// --- 8) Publish your stream ---
				session.publish(publisher);
			}).catch(error => {
			console.warn('There was an error connecting to the session:', error.code, error.message);
			enableBtn();
		});

		return false;
	});
}

// --- 9) Leave the session by calling 'disconnect' method over the Session object ---
function leaveSession() {
	session.disconnect();
	enableBtn();
}

/* OPENVIDU METHODS */
function enableBtn (){
	document.getElementById("join-btn").disabled = false;
	document.getElementById("join-btn").innerHTML = "Join!";
}

/* APPLICATION REST METHODS */

function getToken(callback) {
	sessionName = $("#sessionName").val(); // Video-call chosen by the user


	httpRequest(
		'POST',
		'api/get-token', {
			sessionName: sessionName
		},
		'Request of TOKEN gone WRONG:',
		res => {
			token = res[0]; // Get token from response
			console.warn('Request of TOKEN gone WELL (TOKEN:' + token + ')');
			callback(token); // Continue the join operation
		}
	);
}

function removeUser() {
	httpRequest(
		'POST',
		'api/remove-user', {
			sessionName: sessionName,
			token: token
		},
		'User couldn\'t be removed from session',
		res => {
			console.warn("You have been removed from session " + sessionName);
		}
	);
}

function closeSession() {
	httpRequest(
		'DELETE',
		'api/close-session', {
			sessionName: sessionName
		},
		'Session couldn\'t be closed',
		res => {
			console.warn("Session " + sessionName + " has been closed");
		}
	);
}

function fetchInfo() {
	httpRequest(
		'POST',
		'api/fetch-info', {
			sessionName: sessionName
		},
		'Session couldn\'t be fetched',
		res => {
			console.warn("Session info has been fetched");
			$('#textarea-http').text(JSON.stringify(res, null, "\t"));
		}
	);
}

function fetchAll() {
	httpRequest(
		'GET',
		'api/fetch-all', {},
		'All session info couldn\'t be fetched',
		res => {
			console.warn("All session info has been fetched");
			$('#textarea-http').text(JSON.stringify(res, null, "\t"));
		}
	);
}

function forceDisconnect() {
	httpRequest(
		'DELETE',
		'api/force-disconnect', {
			sessionName: sessionName,
			connectionId: document.getElementById('forceValue').value
		},
		'Connection couldn\'t be closed',
		res => {
			console.warn("Connection has been closed");
		}
	);
}

function forceUnpublish() {
	httpRequest(
		'DELETE',
		'api/force-unpublish', {
			sessionName: sessionName,
			streamId: document.getElementById('forceValue').value
		},
		'Stream couldn\'t be closed',
		res => {
			console.warn("Stream has been closed");
		}
	);
}

function httpRequest(method, url, body, errorMsg, callback) {
	$('#textarea-http').text('');
	var http = new XMLHttpRequest();
	http.open(method, url, true);
	http.setRequestHeader('Content-type', 'application/json');
	http.addEventListener('readystatechange', processRequest, false);
	http.send(JSON.stringify(body));

	function processRequest() {
		if (http.readyState == 4) {
			if (http.status == 200) {
				try {
					callback(JSON.parse(http.responseText));
				} catch (e) {
					callback(e);
				}
			} else {
				console.warn(errorMsg + ' (' + http.status + ')');
				console.warn(http.responseText);
				$('#textarea-http').text(errorMsg + ": HTTP " + http.status + " (" + http.responseText + ")");
			}
		}
	}
}

// uri
function serverRequest(url, method, body) {
	var http = new XMLHttpRequest();
	http.open(method, url, true);
	http.setRequestHeader('Content-type', 'application/json');
	http.addEventListener('readystatechange', processRequest, false);
	http.send(JSON.stringify(body));

	function processRequest() {
		if (http.readyState == 4) {
			if (http.status == 200) {
				try {
					console.log(JSON.parse(http.responseText));
				} catch (e) {
					console.log(e);
				}
			} else {
				console.warn('serverRequest upload WRONG' + ' (' + http.status + ')');
				console.warn(http.responseText);
			}
		}
	}
}


function startRecording() {
	const outputMode = "COMPOSED";
	const hasAudio = true;
	const hasVideo = true;
	console.log("document.getElementById('create_user').value: ",document.getElementById('create_user').value);
	console.log("document.getElementById('board_id').value: ",document.getElementById('board_id').value);
	
	
	httpRequest(
		'POST',
		'api/recording/start', {
			session: session.sessionId, // 녹음을 시작하려는 세션에 속한 sessionId (필수 문자열)
			/*
			그리드 레이아웃의 단일 파일에 모든 스트림을 기록하거나 각 스트림을 별도의 파일에 기록합니다.
			COMPOSED(기본값) : 세션을 기록할 때 모든 스트림이 그리드 레이아웃의 동일한 파일에 구성됩니다.
			INDIVIDUAL: 세션을 기록할 때 모든 스트림은 자체 파일에 기록됩니다.
			COMPOSED_QUICK_START: 와 동일 COMPOSED하지만 세션 수명 동안 더 높은 CPU 사용량과 교환하여 기록이 훨씬 더 빨리 시작됩니다. 자세한 내용은 작성된 빠른 시작 녹음 을 참조 하세요. 이 출력 모드 는 세션을 초기화defaultRecordingProperties 할 때 개체에 정의된 경우에만 적용
			*/
			outputMode: outputMode,
			hasAudio: hasAudio, // 오디오 녹음 여부. 기본값true
			hasVideo: hasVideo // 비디오 녹화 여부. 기본값true
		},
		'Start recording WRONG',
		res => {
			console.log('api/recording/start - res: ',res);
			console.log('api/recording/start - res.id: ',res.id);
			//document.getElementById('forceRecordingId').value = res.id;
			// checkBtnsRecordings();
			// $('#textarea-http').text(JSON.stringify(res, null, "\t"));
		}
	);
}


function stopRecording() {
	console.log('stopRecording - sessionId: ',session.sessionId);
	// var forceRecordingId = document.getElementById('forceRecordingId').value;
	var forceRecordingId = session.sessionId;
	httpRequest(
		'POST',
		'api/recording/stop', {
			recording: forceRecordingId
		},
		'Stop recording WRONG',
		res => {
			console.log("stopRecording 실행 완료");
			console.log("res: ",res);
			console.log("url: ",res.url);
			// $('#textarea-http').text(JSON.stringify(res, null, "\t"));

			console.log("$(\"#create_user\").val(): ", $("#create_user").val());
			console.log("$(\"#board_id\").val(): ", $("#board_id").val());

			// s3 파일 업로드
			serverRequest(
				'https://www.usedmoa.co.kr/users/vodUpload',
				'POST',
				{
					url : res.url,
					create_user : $("#create_user").val(),
					board_id :  $("#board_id").val()
				}
			);
		}
	);
}

function deleteRecording() {
	var forceRecordingId = document.getElementById('forceRecordingId').value;
	httpRequest(
		'DELETE',
		'api/recording/delete', {
			recording: forceRecordingId
		},
		'Delete recording WRONG',
		res => {
			console.log("DELETE ok");
			$('#textarea-http').text("DELETE ok");
		}
	);
}

function getRecording() {
	var forceRecordingId = document.getElementById('forceRecordingId').value;
	httpRequest(
		'GET',
		'api/recording/get/' + forceRecordingId, {},
		'Get recording WRONG',
		res => {
			console.log(res);
			$('#textarea-http').text(JSON.stringify(res, null, "\t"));
		}
	);
}

function listRecordings() {
	httpRequest(
		'GET',
		'api/recording/list', {},
		'List recordings WRONG',
		res => {
			console.log(res);
			$('#textarea-http').text(JSON.stringify(res, null, "\t"));
		}
	);
}

/* APPLICATION REST METHODS */



/* APPLICATION BROWSER METHODS */

events = '';

window.onbeforeunload = function () { // Gracefully leave session
	if (session) {
		removeUser();
		leaveSession();
	}
}

function updateNumVideos(i) {
	numVideos += i;
	$('video').removeClass();
	switch (numVideos) {
		case 1:
			$('video').addClass('two');
			break;
		case 2:
			$('video').addClass('two');
			break;
		case 3:
			$('video').addClass('three');
			break;
		case 4:
			$('video').addClass('four');
			break;
	}
}

function checkBtnsForce() {
	if (document.getElementById("forceValue").value === "") {
		document.getElementById('buttonForceUnpublish').disabled = true;
		document.getElementById('buttonForceDisconnect').disabled = true;
	} else {
		document.getElementById('buttonForceUnpublish').disabled = false;
		document.getElementById('buttonForceDisconnect').disabled = false;
	}
}

function checkBtnsRecordings() {
	if (document.getElementById("forceRecordingId").value === "") {
		document.getElementById('buttonGetRecording').disabled = true;
		document.getElementById('buttonStopRecording').disabled = true;
		document.getElementById('buttonDeleteRecording').disabled = true;
	} else {
		document.getElementById('buttonGetRecording').disabled = false;
		document.getElementById('buttonStopRecording').disabled = false;
		document.getElementById('buttonDeleteRecording').disabled = false;
	}
}

function pushEvent(event) {
	events += (!events ? '' : '\n') + event.type;
	$('#textarea-events').text(events);
}

function clearHttpTextarea() {
	$('#textarea-http').text('');
}

function clearEventsTextarea() {
	$('#textarea-events').text('');
	events = '';
}

/* APPLICATION BROWSER METHODS */