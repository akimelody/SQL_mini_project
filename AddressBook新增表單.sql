-- 1. 直接使用 AddressBook.dbo.UserInfo 作為顧客資料表

ALTER TABLE AddressBook.dbo.UserInfo
	ADD Email nvarchar(100),
    Phone nvarchar(20);

-- 2. 建立 RoomTypes 表

CREATE TABLE RoomTypes (
    RoomTypeID      INT NOT NULL PRIMARY KEY,
    Description     NVARCHAR(255),
    PricePerNight   DECIMAL(10,2),
    TypeName        NVARCHAR(100)
);

-- 3. 建立 Rooms 表

CREATE TABLE Rooms (
    RoomID          INT NOT NULL PRIMARY KEY,
    RoomNumber      NVARCHAR(100),
    RoomTypeID      INT NOT NULL,
    Status          NVARCHAR(20),
    FOREIGN KEY (RoomTypeID) REFERENCES RoomTypes(RoomTypeID)
);

-- 4. 建立 Bookings 表，CustomerID 改為 uid

CREATE TABLE Bookings (
    BookingID           INT NOT NULL PRIMARY KEY,
    BookingDate         DATETIME,
    CheckInDate         DATE,
    CheckOutDate        DATE,
    uid                 NVARCHAR(20) NOT NULL, -- 取代 CustomerID
    PaymentInformation  VARCHAR(100),
    RoomID              INT NOT NULL,
    Status              NVARCHAR(20),
    FOREIGN KEY (uid) REFERENCES AddressBook.dbo.UserInfo(uid),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);