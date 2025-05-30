--建立訂房紀錄（含檢查可用房間）

CREATE PROCEDURE sp_AddBooking
    @CustomerID INT,
    @RoomTypeID INT,
    @CheckInDate DATE,
    @CheckOutDate DATE
AS
BEGIN
    DECLARE @RoomID INT;

    SELECT TOP 1 @RoomID = R.RoomID
    FROM Rooms R
    WHERE R.RoomTypeID = @RoomTypeID
      AND R.Status = 'Available'
      AND NOT EXISTS (
          SELECT 1 FROM Bookings B
          WHERE B.RoomID = R.RoomID
            AND B.Status = 'Booked'
            AND NOT (
                B.CheckOutDate <= @CheckInDate OR B.CheckInDate >= @CheckOutDate
            --判斷兩個區間有無重疊
            )
      );

    IF @RoomID IS NOT NULL
    BEGIN
        INSERT INTO Bookings (CustomerID, RoomID, CheckInDate, CheckOutDate, Status)
        VALUES (@CustomerID, @RoomID, @CheckInDate, @CheckOutDate, 'Booked');

        UPDATE Rooms SET Status = 'Reserved' WHERE RoomID = @RoomID;
    END
    ELSE
    BEGIN
        RAISERROR('No available rooms found.', 16, 1);
    END
END