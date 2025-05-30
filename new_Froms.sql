-- 客戶資料
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(20)
); 
-- 房型資料
CREATE TABLE RoomTypes (
    RoomTypeID INT PRIMARY KEY IDENTITY,
    TypeName NVARCHAR(100),
    Description NVARCHAR(255),
    PricePerNight DECIMAL(10,2)
);
-- 房間資料
CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY IDENTITY,
    RoomTypeID INT,
    RoomNumber NVARCHAR(10),
    Status NVARCHAR(20), -- Available, Reserved, Maintenance
    FOREIGN KEY (RoomTypeID) REFERENCES RoomTypes(RoomTypeID)
);
-- 訂房資料
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY IDENTITY,
    CustomerID INT,
    RoomID INT,
    CheckInDate DATE,
    CheckOutDate DATE,
    BookingDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(20), -- Booked, Cancelled, CheckedIn, CheckedOut
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);