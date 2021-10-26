const mysql = require('mysql'); // #1 : mysql 드라이버를 불러옵니다.


const mysqlConnection = {
    init: function() { // #2 : DB와 연결하는 객체를 생성합니다.
        return mysql.createConnection({
            host: process.env.host,
            port: process.env.port,
            user: process.env.user,
            password: process.env.password,
            database: process.env.database
        });
    },
    // #3: 생성된 커넥션 객체를 DB와 연결합니다.
    open: function(con) {
        con.connect(err => { 
            if(err) { 
                console.log("MySQL 연결 실패 : ", err); 
            } else { 
                console.log("MySQL Connected!!!"); 
            } 
        }); 
    },
    // #4 : DB와 연결을 종료합니다.
    close: function(con) {
        con.end(err => {
            if(err) {
                console.log("MySQL 종료 실패 : ", err); 
            } else {
                console.log("MySQL Terminated..."); 
            } 
        })
    }
}


// #5 : 생성한 mysqlConnection 객체를 모듈화하여 외부 파일에서 불러와 사용할 수 있도록 export 합니다.
module.exports = mysqlConnection;