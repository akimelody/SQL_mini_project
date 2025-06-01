CREATE PROCEDURE sp_CheckOut
    @BookingID INT
AS
BEGIN
    -- 檢查是否存在該訂房
    IF NOT EXISTS (SELECT 1 FROM Bookings WHERE BookingID = @BookingID)
    BEGIN
        RAISERROR('查無此訂房記錄', 16, 1);
        RETURN;
    END

    -- 檢查是否已退房
    IF EXISTS (SELECT 1 FROM Bookings WHERE BookingID = @BookingID AND Status = 'CheckedOut')
    BEGIN
        RAISERROR('該訂房已退房', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Bookings
        SET Status = 'CheckedOut'
        WHERE BookingID = @BookingID;

        UPDATE Rooms
        SET Status = 'Available'
        WHERE RoomID = (SELECT RoomID FROM Bookings WHERE BookingID = @BookingID);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('退房失敗：%s', 16, 1, @ErrMsg);
    END CATCH
END
