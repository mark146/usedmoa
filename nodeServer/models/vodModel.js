const pool = require("../utils/mariadb");
require('date-utils')


// 영상통화 목록 조회
const vodList = async (userInfo) => {
    console.log("boardMedel - vodList 실행", userInfo)

    let conn;
    try {
        conn = await pool.getConnection();
        let sql = `SELECT video_call.id AS video_id, board.title, board.image_url, video_call.video_url, video_call.create_date FROM board INNER JOIN video_call ON board.id = video_call.board_id WHERE video_call.join_user_id = '${userInfo.get("user_id")}' order by video_id desc`;
        const rows = await conn.query(sql);
        // console.log("SQL rows: ", rows);
        return rows;
    } catch (err) {
        console.log("SQL error: ", err);
    } finally {
        if (conn) conn.end();
    }
}


// 영상통화 내용 생성
const videoCallCreate = async (userInfo) => {
    console.log("boardMedel - videoCallCreate 실행", userInfo)

    let conn;
    try {
        conn = await pool.getConnection();

        // 쿼리 생성
        let newDate = new Date();
        let time = newDate.toFormat('YYYY-MM-DD HH24:MI:SS');
        let sql = "INSERT INTO video_call (board_id, join_user_id, video_url, create_date) "+
            `VALUES ('${userInfo.get("board_id")}','${userInfo.get("create_user")}', '${userInfo.get("video_url")}', '${time}')`;

        await conn.beginTransaction() // 트랜잭션 적용 시작

        const rows = await conn.query(sql);

        await conn.commit() // 커밋

        // console.log("SQL rows: ", rows);
        return rows;
    } catch (err) {
        await conn.rollback() // 롤백
        console.log("SQL error: ", err);
    } finally {
        // Close Connection
        if (conn) conn.end();
    }
}


module.exports = {
    vodList,
    videoCallCreate,
}