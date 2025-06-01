--查詢某期間可用房型與房間

CREATE PROCEDURE sp_GetAvailableRooms
    @RoomTypeID INT,
    @CheckInDate DATE,
    @CheckOutDate DATE
AS
BEGIN
    SELECT R.RoomID, R.RoomNumber
    FROM Rooms R
    WHERE R.RoomTypeID = @RoomTypeID    
        AND R.Status <> 'Occupied'
        AND NOT EXISTS (
                --用來檢查某個條件「不存在」。
                --如果括號內的查詢回傳任何結果，NOT EXISTS 就是 false，
                --表示該房間 有衝突預約，不該列入查詢結
            SELECT 1 FROM Bookings B
                --查詢 Bookings 預約資料表。
                --SELECT 1 是為了表示「只要存在一筆就好了」，不需回傳資料內容。
                --使用別名 B 是為了與外層 Rooms R 做連結。
            WHERE B.RoomID = R.RoomID --條件是「這筆預約的房間，就是我們正在檢查的那個房間」
                AND B.Status = 'Booked'--這筆預約是「已成立的預約」，不是取消或結束的預約。
                AND (
                B.CheckInDate < @CheckOutDate AND B.CheckOutDate > @CheckInDate
                    -- 在訂房邏輯中，每筆預約都有：
                        -- B.CheckInDate：已存在預約的入住日
                        -- B.CheckOutDate：已存在預約的退房日
                    -- 使用者輸入的查詢時間是：
                        -- @CheckInDate：想查的入住日
                        -- @CheckOutDate：想查的退房日
                )
        );
END