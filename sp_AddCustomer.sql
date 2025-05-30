
--新增客戶

CREATE PROCEDURE sp_AddCustomer
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    INSERT INTO Customers (Name, Email, Phone)
    VALUES (@Name, @Email, @Phone);
END