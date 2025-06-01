CREATE PROCEDURE sp_CancelBooking
    @BookingID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @RoomID INT;

        SELECT @RoomID = RoomID FROM Bookings WHERE BookingID = @BookingID;

        IF @RoomID IS NULL
        BEGIN
            RAISERROR('找不到該訂房記錄', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE Bookings SET Status = 'Cancelled' WHERE BookingID = @BookingID;
        UPDATE Rooms SET Status = 'Available' WHERE RoomID = @RoomID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END
