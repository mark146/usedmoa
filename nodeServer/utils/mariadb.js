const mariadb = require('mariadb');
const dotenv = require('dotenv').config();


let dbConfig = {
    connectionLimit: 10, // default 10
    host: process.env.MARIADB_HOST,
    user: process.env.MARIADB_USER,
    password: process.env.MARIADB_PASSWORD,
    database: process.env.MARIADB_DATABASE
};


// 데이터베이스 연결 풀 생성
// https://mariadb.com/docs/clients/mariadb-connectors/connector-nodejs/promise/connection-pools/
// https://mariadb.com/docs/clients/mariadb-connectors/connector-nodejs/promise/development/
const pool = mariadb.createPool(dbConfig);
const getConnection = () => {
    return new Promise(function (resolve, reject) {
        pool.getConnection()
            .then(function (connection) {
                console.log(`MariaDB pool connected: threadId: ${connection.threadId}`);
                resolve(connection);
            })
            .catch(function (error) {
                console.log(`MariaDB pool error: ${error}`);
                reject(error);
            });
    });
}


module.exports = {
    getConnection,
};