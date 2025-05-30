--取消訂房

CREATE PROCEDURE sp_CancelBooking
    @BookingID INT
AS
BEGIN
    DECLARE @RoomID INT;

    SELECT @RoomID = RoomID FROM Bookings WHERE BookingID = @BookingID;

    UPDATE Bookings SET Status = 'Cancelled' WHERE BookingID = @BookingID;

    UPDATE Rooms SET Status = 'Available' WHERE RoomID = @RoomID;
END