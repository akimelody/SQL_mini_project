// 引入需要用的套件
const express = require('express');
const sql = require('mssql');
const path = require('path');

// 建立 Express 應用
const app = express();
const PORT = 3000;

// 讓 Express 能解析 JSON 請求
app.use(express.json());
// 提供靜態檔案（例如 HTML, CSS, JS）
app.use(express.static(path.join(__dirname, 'public')));

// SQL Server 連線設定
const config = {
  user: 'sa',
  password: '631477',
  server: 'localhost',
  database: 'HotelBooking',
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

// ✅ API：查詢可用房間
app.get('/api/available-rooms', async (req, res) => {
  // 1. 取得 URL 查詢參數
  const roomTypeID = req.query.roomTypeID;
  const checkInDate = req.query.checkIn;
  const checkOutDate = req.query.checkOut;
  
  // 2. 簡單驗證
  if (!roomTypeID || !checkInDate || !checkOutDate) {
    return res.status(400).json({ error: '缺少必要參數' });
  }
  
  try {
    // 3. 建立連線
    await sql.connect(config);
    
    // 4. 建立 SQL 請求，並傳入參數給 SP
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('RoomTypeID', sql.Int, parseInt(roomTypeID)) // 把字串轉數字
      .input('CheckInDate', sql.Date, checkInDate)
      .input('CheckOutDate', sql.Date, checkOutDate)
      .execute('sp_GetAvailableRooms'); // 執行 Stored Procedure
    
      // 5. 把結果傳回前端
    res.json(result.recordset);// recordset 是資料表的結果
  } catch (err) {
    console.error('SQL error:', err);// 印出錯誤
    res.status(500).json({ error: '伺服器錯誤' });
  } finally {
    await sql.close();// 確保連線關閉
  }
});

// ✅ API：sp_AddCustomer：新增客戶
app.post('/api/customers', async (req, res) => {
  const { name, email, phone } = req.body;

  if (!name || !email || !phone) {
    return res.status(400).json({ error: '缺少必要欄位' });
  }

  try {
    await sql.connect(config);
    await sql.request()
      .input('Name', sql.NVarChar(100), name)
      .input('Email', sql.NVarChar(100), email)
      .input('Phone', sql.NVarChar(20), phone)
      .execute('sp_AddCustomer');

    res.json({ message: '客戶新增成功！' });
  } catch (err) {
    console.error('SQL error:', err);
    res.status(500).json({ error: '新增失敗' });
  } finally {
    await sql.close();
  }
});

// ✅ sp_AddBooking：新增訂房
app.post('/api/book-room', async (req, res) => {
  const { customerID, roomTypeID, checkInDate, checkOutDate } = req.body;

  if (!customerID || !roomTypeID || !checkInDate || !checkOutDate) {
    return res.status(400).json({ error: '缺少必要欄位' });
  }

  try {
    await sql.connect(config);
    await sql.request()
      .input('CustomerID', sql.Int, customerID)
      .input('RoomTypeID', sql.Int, roomTypeID)
      .input('CheckInDate', sql.Date, checkInDate)
      .input('CheckOutDate', sql.Date, checkOutDate)
      .execute('sp_AddBooking');

    res.json({ message: '訂房成功！' });
  } catch (err) {
    console.error('SQL error:', err);
    res.status(500).json({ error: err.message || '訂房失敗' });
  } finally {
    await sql.close();
  }
});
// ✅ API：sp_CancelBooking：取消訂房
app.post('/api/cancel-booking', async (req, res) => {
  const { bookingID } = req.body;

  if (!bookingID) {
    return res.status(400).json({ error: '缺少訂單編號' });
  }

  try {
    await sql.connect(config);
    await sql.request()
      .input('BookingID', sql.Int, bookingID)
      .execute('sp_CancelBooking');

    res.json({ message: '訂房已取消' });
  } catch (err) {
    console.error('SQL error:', err);
    res.status(500).json({ error: '取消失敗' });
  } finally {
    await sql.close();
  }
});

// ✅ API：sp_CheckIn：入住登記
app.post('/api/check-in', async (req, res) => {
  const { bookingID } = req.body;

  if (!bookingID) {
    return res.status(400).json({ error: '缺少訂單編號' });
  }

  try {
    await sql.connect(config);
    await sql.request()
      .input('BookingID', sql.Int, bookingID)
      .execute('sp_CheckIn');

    res.json({ message: '入住成功' });
  } catch (err) {
    console.error('SQL error:', err);
    res.status(500).json({ error: '入住失敗' });
  } finally {
    await sql.close();
  }
});

// ✅ API：sp_CheckOut：退房登記
app.post('/api/check-out', async (req, res) => {
  const { bookingID } = req.body;

  if (!bookingID) {
    return res.status(400).json({ error: '缺少訂單編號' });
  }

  try {
    await sql.connect(config);
    await sql.request()
      .input('BookingID', sql.Int, bookingID)
      .execute('sp_CheckOut');

    res.json({ message: '退房成功' });
  } catch (err) {
    console.error('SQL error:', err);
    res.status(500).json({ error: '退房失敗' });
  } finally {
    await sql.close();
  }
});



//啟動伺服器
app.listen(PORT, () => {
  console.log(`伺服器啟動：http://localhost:${PORT}`);
});
