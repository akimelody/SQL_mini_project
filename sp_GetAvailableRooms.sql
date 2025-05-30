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
      AND R.Status = 'Available'
      AND NOT EXISTS (
          SELECT 1 FROM Bookings B
          WHERE B.RoomID = R.RoomID
            AND B.Status = 'Booked'
            AND (
                (@CheckInDate BETWEEN B.CheckInDate AND B.CheckOutDate)
                OR
                (@CheckOutDate BETWEEN B.CheckInDate AND B.CheckOutDate)
            )
    );
END