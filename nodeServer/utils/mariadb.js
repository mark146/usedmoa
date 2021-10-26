const mariadb = require('mariadb');
const dotenv = require('dotenv').config();


// 데이터베이스 연결 풀 생성 - 참고 : https://mariadb.com/docs/clients/mariadb-connectors/connector-nodejs/promise/connection-pools/
const pool = mariadb.createPool({
  host: process.env.host,
  user: process.env.user,
  password: process.env.password,
  database: process.env.database,
  connectionLimit: 5,
});


module.exports = {
  getConnection() {
    return new Promise(function (res, rej) {
      pool.getConnection()
        .then(function (conn) {
          res(conn);
        })
        .catch(function (error) {
          rej(error);
        });
    });
  }
};