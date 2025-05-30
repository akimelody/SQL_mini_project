--入住登記

CREATE PROCEDURE sp_CheckIn
    @BookingID INT
AS
BEGIN
    UPDATE Bookings SET Status = 'CheckedIn' WHERE BookingID = @BookingID;

    UPDATE Rooms
    SET Status = 'Occupied'
    WHERE RoomID = (SELECT RoomID FROM Bookings WHERE BookingID = @BookingID);
END