const pool = require("../utils/mariadb");
require('date-utils')


// 글 생성
const auctionCreate = async (userInfo) => {
    console.log("boardMedel - boardCreate 실행", userInfo)
    let conn;
    let rows;
    try {
        conn = await pool.getConnection();

        let newDate = new Date();
        let time = newDate.toFormat('YYYY-MM-DD HH24:MI:SS');

        sql = "INSERT INTO board (user_id, title, image_url, product_name, product_price, content, status, create_date) "+
            `VALUES ('${userInfo.get("user_id")}','${userInfo.get("title")}', '${userInfo.get("downloadUrl")}', '${userInfo.get("product_name").trim()}', 
            '${userInfo.get("product_price")}', '${userInfo.get("content")}', '판매중', '${time}')`;
        rows = await conn.query(sql);

        console.log("SQL rows: ", rows);
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
    auctionCreate,
}