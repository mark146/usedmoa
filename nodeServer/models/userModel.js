const pool = require("../utils/mariadb");
require('date-utils')


// 유저 정보 조회
const findUser = async (userInfo) => {
  console.log("userMedel - findUser 실행")

  let conn;
  try {
    conn = await pool.getConnection();
    let email = userInfo.get("email").trim()

    let sql = `SELECT * FROM user where email = '${email}'`;
    let rows = await conn.query(sql);

    // 조회한 정보 저장
    for(let i = 0; i < rows.length ; i++){
      userInfo.set('user_id', rows[i].id);
      userInfo.set('nickname', rows[i].nickname);
      userInfo.set('email', rows[i].email);
    }

    return rows;
  } catch (err) {
    console.log("SQL error: ", err);
  } finally {
    // Close Connection
    if (conn) conn.end();
  }
}


// 유저 정보 생성
const userCreate = async (userInfo) => {
  console.log("userMedel - userCreate 실행")

  let conn;
  let rows;
  let sql;
  try {
    conn = await pool.getConnection();

    sql = "SELECT * FROM user where email";
    rows = await conn.query(sql);

    // 쿼리 생성
    let newDate = new Date();
    let time = newDate.toFormat('YYYY-MM-DD HH24:MI:SS');
    let nickname = userInfo.get("nickname").trim()
    let refreshToken = userInfo.get("refreshToken").trim()
    let email = userInfo.get("email").trim()
    sql = "INSERT INTO user (refresh_token, nickname, email, create_date) "+
        `VALUES ('${refreshToken}', '${nickname}', '${email}', '${time}')`;

    await conn.beginTransaction() // 트랜잭션 적용 시작

    rows = await conn.query(sql);
    userInfo.set("user_id" , rows.insertId);
    // console.log("SQL rows: ", rows);

    await conn.commit() // 커밋

    return rows;
  } catch (err) {
    console.log("SQL error: ", err);
    await conn.rollback() // 롤백
  } finally {
    // Close Connection
    if (conn) conn.end();
  }
}


// 유저 정보 수정
const userUpdate = async (userInfo) => {
  console.log("userMedel - userUpdate 실행: ",userInfo)

  let conn;
  try {
    conn = await pool.getConnection();

    // 쿼리 생성
    let newDate = new Date();
    let time = newDate.toFormat('YYYY-MM-DD HH24:MI:SS');
    let refreshToken = userInfo.get("refreshToken").trim()
    let user_id = userInfo.get("user_id");
    let sql = `UPDATE user SET refresh_token='${refreshToken}', update_date= '${time}' where id = '${user_id}'`;

    await conn.beginTransaction() // 트랜잭션 적용 시작

    const rows = await conn.query(sql);

    await conn.commit() // 커밋
  } catch (err) {
    await conn.rollback() // 롤백
    console.log("SQL error: ", err);
  } finally {
    // Close Connection
    if (conn) conn.end();
  }
}


// 유저 리프레시 토큰 정보 조회
const refreshVerify = async (userInfo) => {
  console.log("userMedel - refreshVerify 실행")

  let conn;
  try {
    conn = await pool.getConnection();
    let refreshToken = userInfo.get("refreshToken").trim()

    let sql = `SELECT * FROM user where refresh_token = '${refreshToken}'`;
    let rows = await conn.query(sql);

    // 조회한 정보 저장
    for(let i = 0; i < rows.length ; i++) {
      userInfo.set('user_id', rows[i].id);
      console.log('user_id', rows[i].id);
    }
  } catch (err) {
    console.log("SQL error: ", err);
  } finally {
    // Close Connection
    if (conn) conn.end();
  }
}


module.exports = {
  findUser,
  userCreate,
  userUpdate,
  refreshVerify,
}