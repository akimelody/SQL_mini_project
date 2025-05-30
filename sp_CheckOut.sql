--退房登記

CREATE PROCEDURE sp_CheckOut
    @BookingID INT
AS
BEGIN
    UPDATE Bookings SET Status = 'CheckedOut' WHERE BookingID = @BookingID;

    UPDATE Rooms
    SET Status = 'Available'
    WHERE RoomID = (SELECT RoomID FROM Bookings WHERE BookingID = @BookingID);
END