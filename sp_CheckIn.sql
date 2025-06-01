CREATE PROCEDURE sp_CheckIn
    @BookingID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 檢查訂房是否存在且尚未入住
    IF NOT EXISTS (
        SELECT 1
        FROM Bookings
        WHERE BookingID = @BookingID AND Status = 'Booked'
    )
    BEGIN
        RAISERROR(N'無效的訂房 ID 或已辦理入住/取消', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 更新訂房狀態為 CheckedIn
        UPDATE Bookings
        SET Status = 'CheckedIn'
        WHERE BookingID = @BookingID;

        -- 更新對應房間狀態為 Occupied
        UPDATE Rooms
        SET Status = 'Occupied'
        WHERE RoomID = (
            SELECT RoomID FROM Bookings WHERE BookingID = @BookingID
        );

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END
