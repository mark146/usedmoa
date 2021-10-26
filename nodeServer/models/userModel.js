const pool = require("../utils/mariadb");
require('date-utils')


// 유저 정보 조회
const findUser = async (userInfo) => {
  console.log("userMedel - findUser 실행")
  let conn;
  let rows;
  try {
    conn = await pool.getConnection();
    let email = userInfo.get("email").trim()

    sql = `SELECT * FROM user where email = '${email}'`;
    rows = await conn.query(sql);

    // 조회한 정보 저장
    for(var i = 0; i < rows.length ; i++){
      userInfo.set('user_id', rows[i].id);
      userInfo.set('nickname', rows[i].nickname);
      userInfo.set('email', rows[i].email);
    }

    return rows;
  } catch (err) {
    // next(err)
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
  try {
    conn = await pool.getConnection();

    sql = "SELECT * FROM user where email";
    rows = await conn.query(sql);

    let newDate = new Date();
    let time = newDate.toFormat('YYYY-MM-DD HH24:MI:SS');
    let nickname = userInfo.get("nickname").trim()
    let refreshToken = userInfo.get("refreshToken").trim()
    let email = userInfo.get("email").trim()

    sql = "INSERT INTO user (refresh_token, nickname, email, create_date) "+
        `VALUES ('${refreshToken}', '${nickname}', '${email}', '${time}')`;

    rows = await conn.query(sql);
    console.log("SQL rows: ", rows);
    userInfo.set("user_id" , rows.insertId);

    return rows;
  } catch (err) {
    // next(err)
    console.log("SQL error: ", err);
  } finally {
    // Close Connection
    if (conn) conn.end();
  }
}


// 유저 정보 수정
const userUpdate = async (userInfo) => {
  console.log("userMedel - userUpdate 실행: ",userInfo)
  let conn;
  let rows;
  try {
    conn = await pool.getConnection();

    let newDate = new Date();
    let time = newDate.toFormat('YYYY-MM-DD HH24:MI:SS');
    let refreshToken = userInfo.get("refreshToken").trim()
    let user_id = userInfo.get("user_id");


    sql = `UPDATE user SET refresh_token='${refreshToken}', update_date= '${time}' where id = '${user_id}'`;
    rows = await conn.query(sql);


    return rows;
  } catch (err) {
    // next(err)
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
}