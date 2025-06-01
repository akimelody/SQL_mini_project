
--新增客戶

CREATE PROCEDURE sp_AddCustomer
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- 防止 Email + Phone 重複（可自行根據規則調整）
    IF EXISTS (SELECT 1 FROM UserInfo1 WHERE Email = @Email AND Phone = @Phone)
    BEGIN
        RAISERROR('此顧客資料已存在，請確認輸入是否正確。', 16, 1);
        RETURN;
    END

    INSERT INTO Customers (Name, Email, Phone)
    VALUES (@Name, @Email, @Phone);

    PRINT '顧客資料已成功儲存';
END