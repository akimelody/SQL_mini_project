CREATE PROCEDURE sp_AddBooking
    @CustomerID INT,
    @RoomTypeID INT,
    @CheckInDate DATE,
    @CheckOutDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 驗證輸入日期
    IF @CheckInDate >= @CheckOutDate
    BEGIN
        RAISERROR('Check-in date must be before check-out date.', 16, 1);
        RETURN;
    END

    DECLARE @RoomID INT; --宣告一個變數，用來儲存挑選出來的可用房間 ID。

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 找出第一間在日期區間內沒有被訂走的房間
        SELECT TOP 1 @RoomID = R.RoomID
        FROM Rooms R
        WHERE R.RoomTypeID = @RoomTypeID
          AND R.Status = 'Available'  -- 可保留這條，作為維修/停用用途
          AND NOT EXISTS (
              SELECT 1 FROM Bookings B
              WHERE B.RoomID = R.RoomID
                AND B.Status = 'Booked'
                AND NOT (
                    B.CheckOutDate <= @CheckInDate OR B.CheckInDate >= @CheckOutDate
                )
          );

        IF @RoomID IS NOT NULL
        BEGIN
            INSERT INTO Bookings (CustomerID, RoomID, CheckInDate, CheckOutDate, Status)
            VALUES (@CustomerID, @RoomID, @CheckInDate, @CheckOutDate, 'Booked');
            
            
            --UPDATE Rooms SET Status = 'Reserved' WHERE RoomID = @RoomID;
            -- 若找到可用房間，則建立一筆預訂資料並將該房間狀態設為 Reserved。
            -- 可以視情況移除這段，讓房間狀態與實際入住同步（例如入住時才設為 Occupied）
            COMMIT;

            -- 回傳房號給前端或 API
            SELECT @RoomID AS RoomID;
        END
        ELSE
        BEGIN
            ROLLBACK; --用來回復（取消）一筆交易（Transaction）內所做的所有變更，讓資料回到交易開始之前的狀態。
            RAISERROR('No available rooms found.', 16, 1); --否則使用 RAISERROR 回報錯誤。
        END
    END TRY
    BEGIN CATCH
        ROLLBACK;
        RAISERROR('Error occurred while booking.', 16, 1);
            -- 16	錯誤屬於「使用者層級錯誤」
            -- 1	自訂狀態碼，可用於除錯識別
    END CATCH
END
