CREATE DATABASE OnlineRetailDB;
GO

-- Use the database
USE OnlineRetailDB;
Go

-- Create the Customers table
CREATE TABLE Customers (
	CustomerID INT PRIMARY KEY IDENTITY(1,1),
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	Email NVARCHAR(100),
	Phone NVARCHAR(50),
	Address NVARCHAR(255),
	City NVARCHAR(50),
	State NVARCHAR(50),
	ZipCode NVARCHAR(50),
	Country NVARCHAR(50),
	CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Products table
CREATE TABLE Products (
	ProductID INT PRIMARY KEY IDENTITY(1,1),
	ProductName NVARCHAR(100),
	CategoryID INT,
	Price DECIMAL(10,2),
	Stock INT,
	CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Categories table
CREATE TABLE Categories (
	CategoryID INT PRIMARY KEY IDENTITY(1,1),
	CategoryName NVARCHAR(100),
	Description NVARCHAR(255)
);

-- Create the Orders table
CREATE TABLE Orders (
	OrderID INT PRIMARY KEY IDENTITY(1,1),
	CustomerID INT,
	OrderDate DATETIME DEFAULT GETDATE(),
	TotalAmount DECIMAL(10,2),
	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Alter / Rename the Column Name
EXEC sp_rename 'OnlineRetailDB.dbo.Orders.CustomerId', 'CustomerID', 'COLUMN'; 
EXEC sp_rename 'OnlineRetailDB.dbo.Orders.OrderId', 'OrderID', 'COLUMN'; 


-- Create the OrderItems table
CREATE TABLE OrderItems (
	OrderItemID INT PRIMARY KEY IDENTITY(1,1),
	OrderID INT,
	ProductID INT,
	Quantity INT,
	Price DECIMAL(10,2),
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
	FOREIGN KEY (OrderId) REFERENCES Orders(OrderID)
);

-- Insert sample data into Categories table
INSERT INTO Categories (CategoryName, Description) 
VALUES 
('Electronics', 'Devices and Gadgets'),
('Clothing', 'Apparel and Accessories'),
('Books', 'Printed and Electronic Books');

-- Insert sample data into Products table
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES 
('Smartphone', 1, 699.99, 50),
('Laptop', 1, 999.99, 30),
('T-shirt', 2, 19.99, 100),
('Jeans', 2, 49.99, 60),
('Fiction Novel', 3, 14.99, 200),
('Science Journal', 3, 29.99, 150);

-- Insert sample data into Customers table
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Sameer', 'Khanna', 'sameer.khanna@example.com', '123-456-7890', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak St.', 'Madison', 
'WI', '53703', 'USA'),
('harshad', 'patel', 'harshad.patel@example.com', '345-678-9012', '789 Dalal St.', 'Mumbai', 
'Maharashtra', '41520', 'INDIA');

-- Insert sample data into Orders table
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES 
(1, GETDATE(), 719.98),
(2, GETDATE(), 49.99),
(3, GETDATE(), 44.98);

-- Insert sample data into OrderItems table
INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 4, 1,  49.99),
(3, 5, 1, 14.99),
(3, 6, 1, 29.99);







-- Query 1: Retrieve all orders for a specific customer
SELECT o.OrderID, o.OrderDate, o.TotalAmount, oi.ProductID, p.ProductName, oi.Quantity, oi.Price
FROM Orders o
JOIN OrderItems oi ON  o.OrderID = oi.OrderID
JOIN Products p ON p.ProductID = oi.ProductID
WHERE o.CustomerID = 1 ;


-- Query 2: Find the total sales for each product
SELECT p.ProductName, p.ProductID, SUM(oi.Quantity * oi.Price) as TotalSales
FROM OrderItems oi
JOIN Products p ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSales DESC;


-- Query 3: Calculate the average order value
SELECT AVG(TotalAmount) AS AvgOrderValues FROM Orders;

-- Query 4: List the top 5 customers by total spending
SELECT Top 5 c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpending
FROM Customers c 
JOIN Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID,c.FirstName,c.LastName
ORDER BY TotalSpending DESC;


-- Query 5: Retrieve the most popular product category
SELECT top 1 c.CategoryID, c.CategoryName, SUM(oi.Quantity) TotalQuantitySold
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
Group by c.CategoryID, c.CategoryName
Order by TotalQuantitySold DESC;



------ to insert a product with 0 stock
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES 
('Keyboard', 1, 39.99, 0);

-- Query 6: List all products that are out of the stock
SELECT * FROM Products WHERE Stock = 0;

-- most accurate query 
SELECT ProductID, ProductName, Stock FROM Products WHERE Stock = 0;



-- Query 7: Find customers who placed orders in the last 30 days
SELECT c.CustomerID, c.FirstName, c.LastName, c.Phone, c.Email 
FROM Customers c JOIN Orders o 
ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= DATEADD(DAY, -30, GETDATE()); 

-- Query 8: Calculate the total number of orders placed each month
SELECT 
YEAR(OrderDate) as OrderYear,
MONTH(OrderDate) as OrderMonth,
COUNT(OrderID) AS TotalOrders
FROM Orders o
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;



-- Query 9: Retrieve the details of the most recent order
SELECT top 1 o.OrderID, o.OrderDate, o.TotalAmount, c.FirstName, c.LastName
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate DESC;


-- Query 10: Find the average price of products in each category
SELECT  c.CategoryID, c.CategoryName, AVG(p.Price) AS AvgPrice
FROM Products p 
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY AvgPrice DESC;



----- insert customer that never placed order 
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Ansh', 'Gupta', 'ansh.gupta@example.com', '1234932090', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA');


-- Query 11: List customers who have never placed an order 
SELECT c.CustomerID, c.FirstName, c.LastName, c.Phone, c.Email, o.OrderID, o.TotalAmount
FROM Customers c
FULL JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

SELECT c.CustomerID, c.FirstName, c.LastName, c.Phone, c.Email, o.OrderID, o.TotalAmount
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;



-- Query 12: Retrieve the total quantity sold for each product
SELECT p.ProductID, p.ProductName, COUNT(oi.Quantity) AS TotalQuantity
FROM Products p 
JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalQuantity DESC;


-- Query 13: Calculate the total revenue generated from each category
SELECT c.CategoryID, c.CategoryName, SUM(oi.Price * oi.Quantity)  AS TotalRevenue
FROM Products p 
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalRevenue DESC;


-- Query 14: Find the highest-priced product in each category


SELECT 
    c.CategoryID, c.CategoryName, p.ProductID, p.ProductName, p.Price
FROM Categories c
CROSS APPLY 
    (SELECT TOP 1 
         ProductID, ProductName, Price 
     FROM Products p 
     WHERE p.CategoryID = c.CategoryID 
     ORDER BY Price DESC) p;


------- Highest Priced Product
SELECT TOP 1 c.CategoryID, c.CategoryName, p1.ProductID, p1.ProductName, p1.Price
FROM 
    Categories c
JOIN Products p1 ON c.CategoryID = p1.CategoryID
WHERE 
    p1.Price = (
        SELECT MAX(p2.Price) 
        FROM Products p2 
        WHERE p2.CategoryID = c.CategoryID
    )
ORDER BY 
    p1.Price DESC;



-- Query 15: Retrieve orders with the total amount greater than a specific value ( e.g. 500 RS. )
SELECT o.OrderID, c.CustomerID, c.FirstName, c.LastName, o.TotalAmount
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.TotalAmount > 500
ORDER BY o.TotalAmount DESC;




---- For order counts
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES 
(4, GETDATE(), 3499.95);


INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(4, 1, 5, 699.99);

-- Query 16: List product along with the number of orders they appear in
SELECT p.ProductID, p.ProductName, Count(oi.OrderID) AS OrderCounts
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID,p.ProductName
ORDER BY OrderCounts DESC;


-- Query 17: Find the top 3 most frequently ordered products 
SELECT TOP 3 p.ProductID, p.ProductName, COUNT(oi.OrderID) AS OrderCounts
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY OrderCounts DESC



-- Query 18: Calculate the total number of customers from each country
SELECT Country,  COUNT(CustomerID) AS TotalCustomers
FROM Customers 
GROUP BY Country
ORDER BY TotalCustomers DESC;



-- Query 19: Rretrieve the list of customers along with their total spending
SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpending
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalSpending DESC 



-- Query 20: List orders with more than a specified nmber of items (e.g. 5 items)
SELECT o.OrderID, c.CustomerID, c.FirstName, c.LastName, COUNT(oi.OrderItemID) AS NumberOfItems
FROM Orders o JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID 
GROUP BY o.OrderID, c.CustomerID, c.FirstName ,c.LastName
HAVING COUNT(oi.OrderID) > 1
ORDER BY NumberOfItems DESC;



/*
=================================
Implementing Triggers
=================================
*/

---- Create a Log Table
---- Create Trigger for each Table


-- Create a Log Table
CREATE TABLE ChangeLog(
    LogID INT PRIMARY KEY IDENTITY(1,1),
	TableName NVARCHAR(50),
	Operation NVARCHAR(10),
	RecordID INT,
	ChangeDate DATETIME DEFAULT GETDATE(),
	ChangedBy NVARCHAR(100)
)


------------------------- 1.Trigger for Products Table -------------------------------

-- Trigger for INSERT on Products table

CREATE OR ALTER TRIGGER trg_Insert_Product
ON Products
AFTER INSERT
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'Products', 'INSERT', inserted.ProductID, SYSTEM_USER
	 FROM inserted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'INSERT operation logged for Products Table.';
END;
GO

   -- Try to Insert one record into the Products table
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES ('Wireless Mouse', 1, 4.99, 20);

INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES ('Spiderman Multiverse Comic', 3, 2.50, 150);


SELECT * FROM Products;
SELECT * FROM  ChangeLog;


-- Trigger for UPDATE on Products table
CREATE OR ALTER TRIGGER trg_Update_Products
ON Products
AFTER UPDATE 
AS
BEGIN

    INSERT INTO ChangeLog(TableName, Operation, RecordID, ChangedBY)
	SELECT 'Products', 'UPDATE', inserted.ProductID, SYSTEM_USER
	FROM inserted;

	PRINT 'UPDATE operation logged for Products Table.'
END;
GO

------- Try to update any record from Products table
UPDATE Products SET Price = Price - 300 WHERE ProductID = 2;


-- Trigger for DELETE on Products table

CREATE OR ALTER TRIGGER trg_Delete_Products
ON Products
AFTER DELETE 
AS
BEGIN

    INSERT INTO ChangeLog(TableName, Operation, RecordID, ChangedBY)
	SELECT 'Products', 'DELETE', deleted.ProductID, SYSTEM_USER
	FROM deleted;

	PRINT 'DELETE operation logged for Products Table.'
END;
GO
------- Try to Delete any record from Products table
DELETE FROM Products WHERE ProductID = 9;



-------------------- 2.Trigger for Orders Table ------------------------------

-- Trigger for INSERT on Orders table

CREATE OR ALTER TRIGGER trg_Insert_Orders
ON Orders
AFTER INSERT
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'Orders', 'INSERT', inserted.OrderID, SYSTEM_USER
	 FROM inserted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'INSERT operation logged for Orders Table.';
END;
GO

-- Trigger for UPDATE on Orders table

CREATE OR ALTER TRIGGER trg_Update_Orders
ON Orders
AFTER UPDATE
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'Orders', 'UPDATE', inserted.OrderID, SYSTEM_USER
	 FROM inserted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'UPDATE operation logged for Orders Table.';
END;
GO

-- Trigger for DELETE on Orders table

CREATE OR ALTER TRIGGER trg_Delete_Orders
ON Orders
AFTER DELETE
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'Orders', 'DELETE', deleted.OrderID, SYSTEM_USER
	 FROM deleted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'DELETE operation logged for Orders Table.';
END;
GO



--- Try to Insert, Update and Delete any record 
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES 
(2, GETDATE(), 71.98);

UPDATE Orders SET OrderDate = SYSDATETIME() WHERE OrderID = 5;

DELETE FROM Orders WHERE OrderID = 5;

SELECT * FROM Orders;
SELECT * FROM ChangeLog;


----------------------------- 3.Trigger for customers Table --------------------------------------

-- Trigger for INSERT on customers table

CREATE OR ALTER TRIGGER trg_Insert_Customers
ON Customers
AFTER INSERT
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'Customers', 'INSERT', inserted.CustomerID, SYSTEM_USER
	 FROM inserted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'INSERT operation logged for Orders Table.';
END;
GO

-- Trigger for UPDATE on Orders table

CREATE OR ALTER TRIGGER trg_Update_Customers
ON Customers
AFTER UPDATE
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'Customers', 'UPDATE', inserted.CustomerID, SYSTEM_USER
	 FROM inserted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'UPDATE operation logged for Orders Table.';
END;
GO

-- Trigger for DELETE on Orders table

CREATE OR ALTER TRIGGER trg_Delete_Customers
ON Customers
AFTER DELETE
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'Customers', 'DELETE', deleted.CustomerID, SYSTEM_USER
	 FROM deleted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'DELETE operation logged for Orders Table.';
END;
GO


--- Try to Insert, Update and Delete any record 
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Ankit', 'Kumar', 'ankit.kumar@example.com', '12345677890', '123 Elm St.', 'Springfield', 
'IL', '62701', 'IND');

UPDATE Customers SET Email = 'gupta.ansh@example.com' WHERE CustomerID = 4;

DELETE FROM Customers WHERE CustomerID = 5;

SELECT * FROM Customers;
SELECT * FROM ChangeLog;




------------------------ 4.Trigger for OrderItems Table ------------------------------------

-- Trigger for INSERT on customers table

CREATE OR ALTER TRIGGER trg_Insert_OrderItems
ON OrderItems
AFTER INSERT
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'OrderItems', 'INSERT', inserted.OrderItemID, SYSTEM_USER
	 FROM inserted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'INSERT operation logged for Orders Table.';
END;
GO

-- Trigger for UPDATE on Orders table

CREATE OR ALTER TRIGGER trg_Update_OrderItems
ON OrderItems
AFTER UPDATE
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'OrderItems', 'UPDATE', inserted.OrderItemID, SYSTEM_USER
	 FROM inserted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'UPDATE operation logged for Orders Table.';
END;
GO

-- Trigger for DELETE on Orders table

CREATE OR ALTER TRIGGER trg_Delete_OrderItems
ON OrderItems
AFTER DELETE
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'OrderItems', 'DELETE', deleted.OrderItemID, SYSTEM_USER
	 FROM deleted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'DELETE operation logged for Orders Table.';
END;
GO


--- Try to Insert, Update and Delete any record 
INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(1, 1, 1, 699.99);

UPDATE OrderItems SET Quantity = 4 WHERE OrderItemID = 6;
UPDATE OrderItems SET Price = Price - 139.998 WHERE OrderItemID = 6;

DELETE FROM OrderItems WHERE OrderItemID = 7;

SELECT * FROM OrderItems;
SELECT * FROM ChangeLog;


------------------------------- 4.Trigger for Categories Table --------------------------------------

-- Trigger for INSERT on Cusomters table

CREATE OR ALTER TRIGGER trg_Insert_Categories
ON Categories
AFTER INSERT
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'Categories', 'INSERT', inserted.CategoryID, SYSTEM_USER
	 FROM inserted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'INSERT operation logged for Orders Table.';
END;
GO

-- Trigger for UPDATE on Customers table

CREATE OR ALTER TRIGGER trg_Update_Categories
ON Categories
AFTER UPDATE
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'Categories', 'UPDATE', inserted.CategoryID, SYSTEM_USER
	 FROM inserted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'UPDATE operation logged for Orders Table.';
END;
GO

-- Trigger for DELETE on Customers table

CREATE OR ALTER TRIGGER trg_Delete_Categories
ON Categories
AFTER DELETE
AS
BEGIN
----------- Insert a record into the change log table 
     INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	 SELECT 'Categories', 'DELETE', deleted.CategoryID, SYSTEM_USER
	 FROM deleted;

	 -- Display a message indicating that the trigger has fired.
	 PRINT 'DELETE operation logged for Orders Table.';
END;
GO


--- Try to Insert, Update and Delete any record 
INSERT INTO Categories(CategoryName, Description)
VALUES 
('vehicles','Electric scooters & motorbikes');

UPDATE Categories SET CategoryName = 'Gaming & Toys' WHERE CategoryID = 4;

DELETE FROM Categories WHERE CategoryID = 4;

SELECT * FROM Categories;
SELECT * FROM ChangeLog;




/*
=================================
Implementing Indexes
=================================
*/



---------------------------- 1. Indexes on Category Table -----------------------------------

--- Clustered Index on Category Table (CategoryID)
CREATE CLUSTERED INDEX IDX_Category_CategoryID
ON Categories(CategoryID);
GO




---------------------------- 2. Indexes on Products Table -----------------------------------

-- 1. Remove Foreign Constraint of that Table
-- 2. Remove Primary Key of Products Table
-- 3. Create indexes 
-- 4. Recreate Foreign Contraint of that Table

-- Drop Foregin Key Constraint from OrderItems Table (ProductID)
ALTER TABLE OrderItems DROP CONSTRAINT FK__OrderItem__Produ__4316F928;

-- Create Clustered Indexes
CREATE CLUSTERED INDEX IDX_Products_ProductID
ON Products(ProductID);
GO

-- Non-Clustered Indexe on CategoryID : To Speed up queries Filtering by CategoryID.
CREATE NONCLUSTERED INDEX IDX_Products_CategoryID
ON Products(CategoryID);
GO
-- Non-Clustered Indexe on Price : To Speed up queries Filtering or Sorting by Price.
CREATE NONCLUSTERED INDEX IDX_Products_Price 
ON Products(Price);
GO

-- Recreate Foregin Key Constraint from OrderItems Table (ProductID)
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_Products
FOREIGN KEY (ProductID) REFERENCES Products(ProductID);
GO


---------------------------- 3. Indexes on Orders Table -----------------------------------

-- Drop Foregin Key Constraint from OrderItems Table (OrderID)
ALTER TABLE OrderItems DROP CONSTRAINT FK__OrderItem__Order__440B1D61;

-- Create Clustered Indexes
CREATE CLUSTERED INDEX IDX_Orders_OrderID
ON Orders(OrderID);
GO

-- Non-Clustered Indexe on CustomerID : To Speed up queries Filtering by CustomerID.
CREATE NONCLUSTERED INDEX IDX_Orders_CustomerID
ON Orders(CustomerID);
GO
-- Non-Clustered Indexe on OrderDate : To Speed up queries Filtering or Sorting by OrderDate.
CREATE NONCLUSTERED INDEX IDX_Products_OrderDate 
ON Orders(OrderDate);
GO

-- Recreate Foregin Key Constraint from OrderItems Table (ProductID)
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_Orders
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID);
GO

---------------------------- 3. Indexes on OrderItems Table -----------------------------------

-- Create Clustered Indexes
CREATE CLUSTERED INDEX IDX_OrderItems_OrderItemID
ON OrderItems(OrderItemID);
GO

-- Non-Clustered Indexe on OrderID : To Speed up queries Filtering by OrderID.
CREATE NONCLUSTERED INDEX IDX_OrderItems_OrderID
ON OrderItems(OrderID);
GO
-- Non-Clustered Indexe on ProductID : To Speed up queries Filtering or Sorting by ProductID.
CREATE NONCLUSTERED INDEX IDX_OrderItems_ProductID 
ON OrderItems(ProductID);
GO


---------------------------- 4. Indexes on Customers Table -----------------------------------

-- Drop Foregin Key Constraint from Orders Table (CustomerID)
ALTER TABLE Orders DROP CONSTRAINT FK__Orders__Customer__403A8C7D;

-- Create Clustered Indexes
CREATE CLUSTERED INDEX IDX_Customers_CustomerID
ON Customers(CustomerID);
GO

-- Non-Clustered Indexe on Email : To Speed up queries Filtering by Email.
CREATE NONCLUSTERED INDEX IDX_OrderItems_OrderID
ON Customers(Email);
GO
-- Non-Clustered Indexe on Country : To Speed up queries Filtering or Sorting by Country.
CREATE NONCLUSTERED INDEX IDX_OrderItems_ProductID 
ON Customers(Country);
GO

-- Recreate Foregin Key Constraint from Orders Table (CustomerID)
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_CustomerID
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);
GO

/*

====================================================
Implementing Views
====================================================

*/


-- View for Product details : A view combining product detail with category names
CREATE VIEW vw_ProductDetails AS
SELECT p.ProductID, p.ProductName, p.Price, p.Stock, c.CategoryName
From Products p INNER JOIN Categories c 
ON p.CategoryID = c.CategoryID;
GO
--- Display product details with category names using view
SELECT * FROM vw_ProductDetails;


--IMP
-- View for Customer Orders : A view to get summarry of orders placed by each customer
CREATE VIEW vw_CustomerOrders 
AS
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(o.OrderID) AS TotalOrders, SUM(oi.Quantity * oi.Price) AS TotalAmount
FROM Customers c 
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY c.CustomerID, c.FirstName, c.LastName;
GO
--- Display view vw_CustomerOrders
SELECT * FROM vw_CustomerOrders;

-- View for Recent Orders   : A view to display orders placed in last 30 days
CREATE VIEW vw_RecentOrders 
AS
SELECT o.OrderID, o.OrderDate, c.CustomerID, c.FirstName, c.LastName,
SUM(oi.Quantity * oi.Price) AS OrderAmount
FROM Customers c 
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, o.OrderDate, c.CustomerID, c.FirstName, c.LastName;
GO



-- Query 31: Retrieve All Products with Category Names
-- Using the vw_ProductDetails view to get a list of all Products along with their category names
SELECT * FROM vw_ProductDetails;

-- Query 32: Retrieve Product with a Specific Priced Range 
--Using the vw_ProductDetails view to find products priced between $10 and $500
SELECT * FROM vw_ProductDetails WHERE Price BETWEEN 10 AND 500;

-- Query 33: Count the Number of products in each category
-- Using vw_ProductDetails to Count the Number of products in each category
SELECT CategoryName, COUNT(ProductID) AS ProductNumbers FROM vw_ProductDetails
GROUP BY CategoryName
ORDER BY ProductNumbers DESC;

-- Query 34: Retrieve Customers With More than 5 Order
-- Using vw_CustomerOrders Retrieve Customers With More than 5 Order
SELECT * FROM vw_CustomerOrders WHERE TotalOrders > 1;

-- Query 35: Retrieve the total Aomunt Spent By Each Customer
-- Using vw_CustomerOrders Retrieve the total Aomunt Spent By Each Customer
SELECT CustomerID, FirstName, LastName, TotalAmount FROM vw_CustomerOrders
ORDER BY TotalAmount DESC;

-- Query 36: Retrieve Recent orders Above a Certain Amount
--Using vw_RecentOrders to Retrieve Recent orders Above a Certain Amount (e.g. $500 )
SELECT * FROM vw_RecentOrders WHERE OrderAmount > 500
ORDER BY OrderAmount DESC;

-- Query 37: Retrieve the Latest order for each customers
--Using vw_RecentOrders view to find the Latest order for each customers
SELECT ro.OrderID, ro.OrderDate, ro.CustomerID, ro.FirstName, ro.LastName, ro.OrderAmount 
FROM vw_RecentOrders ro 
INNER JOIN (SELECT CustomerID, MAX(OrderDate) as LatestOrderDate FROM vw_RecentOrders GROUP BY CustomerID 
) AS Latest
ON ro.CustomerID = Latest.CustomerID AND ro.OrderDate = Latest.LatestOrderDate
ORDER BY ro.OrderDate DESC;
GO


-- Query 38: Retrieve Products in a Specific Category
-- Using the vw_ProductDetails view to get all products in a specific Category, such as 'Electronics'.
SELECT * FROM vw_ProductDetails WHERE CategoryName = 'Electronics';


-- Query 39: Retrieve Total Sales For Each category
-- Using the vw_productDetails and vw_CustomerOrders views to calculate the total sales for each category. 
SELECT pd.CategoryName, SUM(oi.Quantity * oi.Price) AS TotalSales
FROM  vw_ProductDetails pd
INNER JOIN OrderItems oi ON pd.ProductID = oi.ProductID
GROUP BY pd.CategoryName
ORDER BY TotalSales DESC;



-- Query 40: Retrieve Customers orders with product details
-- Using the vw_CustomerOrders and vw_ProductDetails views to get customer orders along with the details of the products
SELECT co.CustomerID, co.FirstName, co.LastName, o.OrderID, o.OrderDate, 
pd.ProductName, oi.Quantity, oi.Price
FROM Orders o
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
INNER JOIN vw_ProductDetails pd ON oi.ProductID = pd.ProductID
INNER JOIN vw_CustomerOrders co ON o.CustomerID = co.CustomerID
ORDER BY OrderDate DESC;


-- Query 41: Retrieve  Top 5 Customers by total Spending
-- Using the vw_CustomerOrders to find top 5 customers based on their total spending.
SELECT Top 5 CustomerID, FirstName, LastName, TotalAmount
FROM vw_CustomerOrders ORDER BY TotalAmount DESC;


-- Query 42: Rretrieve Products with Low Stock
-- Using the vw_ProductDetails view to find products with stock below a certain threshold, such as 10 units.
SELECT ProductName, Stock FROM Products Order by Stock ;

SELECT ProductName, Stock FROM Products WHERE Stock < 50  ORDER BY Stock;


-- Query 43: Retrieve Orders Placed in the last 7 day.
-- Using vw_RecentOrders view to find Orders placed in last 7 days.
SELECT * FROM vw_RecentOrders WHERE OrderDate >= DATEADD(DAY, -7, GETDATE())


-- Query 44: Retrieve Products sold in last Month
-- Using vw_RecentOrders view to find Products sold in last month.
SELECT pd.ProductID, pd.ProductName, SUM(oi.Quantity) AS TotalSales
FROM vw_RecentOrders ro
INNER JOIN OrderItems oi ON ro.OrderID = oi.OrderID
INNER JOIN vw_ProductDetails pd ON oi.ProductID = pd.ProductID
WHERE ro.OrderDate >= DATEADD(MONTH, -1, GETDATE())
GROUP BY pd.ProductID, pd.ProductName
ORDER BY TotalSales DESC;





/*
=============================================================
Implementing Security / Role-Based Access Control (RBAC)
=============================================================

Step 1: Create Logins
Step 2: Create Users
Step 3: Create Roles
Step 4: Assign Users to Roles
Step 5: Grant Permissions
Step 5: Revok Permissions (If Needed)

*/

/*
### Step 1: Create Logins
----------------------
*/
--Create a login with SQL Server Authentication 
CREATE LOGIN SalesUser WITH PASSWORD = 'strongpassword';


/*
### Step 2: Create Users
----------------------
            Create Users in the `OnlineRetailsDB` database for each login
			User are associated with logins and used to grant access to the database
*/
USE OnlineRetailDB;
GO 

-- Create a User In the database for SQL Server Login
CREATE USER SalesUser FOR LOGIN SalesUser;



/*
### Step 3: Create Roles
----------------------
            Define roles in the database that will be used to group users with similar permissions.
			This helps simlify permisson management.
*/
-- Create Roles in the database
CREATE ROLE SalesRole;
CREATE ROLE MarketingRole;




/*
### Step 4: Assign Users to Roles
---------------------------------
            Add the users to the appropriate roles
*/
-- Add users to roles
EXEC sp_addrolemember 'SalesRole' , 'SalesUser';




/*
### Step 5: Grant Permissions
---------------------------------
            Grant the necessary permissions to the roles, based on the access requirements.
*/
-- GRANT SELECT premissoin on the Customers Table to the SalesRole 
GRANT SELECT ON Customers TO SalesRole;

-- GRANT INSERT premissoin on the Orders Table to the SalesRole 
GRANT INSERT ON Orders TO SalesRole;

-- GRANT UPDATE premissoin on the Orders Table to the SalesRole 
GRANT UPDATE ON Orders TO SalesRole;

-- GRANT SELECT premissoin on the Products Table to the SalesRole 
GRANT SELECT ON Products TO SalesRole;



/*
### Step 6: Revoke Permissions if needed
----------------------------------------
*/

-- Revoke INSERT Permissions on the orders to the SalesRole
REVOKE INSERT ON Orders FROM SalesRole;



/*
### Step 7: View Effective Permissions
----------------------------------------
                  You can view the effective permissions for a user using the query
*/
SELECT * FROM fn_my_permissions(NULL, 'DATABASE');



-- Scenario 1: Read-Only Access to all Tables
CREATE ROLE ReadOnlyRole;
GRANT SELECT ON SCHEMA::dbo TO ReadOnlyRole;

-- Scenario 2: Data Entry Clerk (Insert Only on Orders and OrderItems)
CREATE ROLE DataEntryClerk;
GRANT INSERT ON Orders TO DataEntryClerk;
GRANT INSERT ON OrderItems TO DataEntryClerk;

-- Scenario 3: Product Manager (Full Access to Products and Categories)
CREATE ROLE ProductsManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO ProductsManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Categories TO ProductsManagerRole;


-- Scenario 4: Order Processor (Read and Update Orders)
CREATE ROLE OrderProcessorRole;
GRANT SELECT, UPDATE ON Orders TO OrderProcessorRole;

-- Scenario 5: Customer support (Read Access to Customers and Orders)
CREATE ROLE CustomerSupportRole;
GRANT SELECT ON Customers TO CustomerSupportRole;
GRANT SELECT ON Orders TO CustomerSupportRole;


--IMP
-- Scenario 6: Marketing Analyst (Read Access to All Tables, NO DML)
CREATE ROLE MarketingAnalystRole;
GRANT SELECT ON SCHEMA::dbo TO MarketingAnalystRole;


-- Scenario 7: Sales Analyst (Read access to Orders and OrderItems)
-- Scenario 8: Inventory Manager (Full Access to Products)
-- Scenario 9: Finanace Manager (Read and Update Orders)

-- Scenario 10: Database Backup Operator (Backup Database)
CREATE ROLE BackupOperatorRole;
GRANT BACKUP DATABASE TO BackupOperatorRole;
-- Scenario 11: Database Developer (Full Update to Schema Objects)
-- Scenario 12: Restricted Read Access (Read only spceific columns) 
-- Scenario 13: Reporting User (Read Access to views only)
-- Scenario 14: Temporary Access (Time-Bound Access)
                -- Grant Access
				-- Revoke Access after the specified period
				
				
-- Scenario 15: External Auditor ( Read Access with no Data Changes)
-- Scenario 16: Application Role (Access Based on Applicatopn)
-- Scenario 17: Role-Based Access Control (RBAC) For Multiple Roles
                -- Combine Roles
-- Scenario 18: Sensitive Data Access (Columns Level Permissions)
-- Scenario 19: Developer Role (Full Access to Devvelopment DataBase)
-- Scenario 20: Security Administrator (Manage Security Privileges)





/*
=====================================================================
Backup & Restore
=====================================================================
*/

BACKUP DATABASE [OnlineRetailDB] TO  
DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\OnlineRetailDB.bak' WITH NOFORMAT, NOINIT,  NAME = N'OnlineRetailDB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where 
database_name=N'OnlineRetailDB' and backup_set_id=(select max(backup_set_id) 
from msdb..backupset where database_name=N'OnlineRetailDB' )
if @backupSetId is null 
begin 
raiserror(N'Verify failed. Backup information for database ''OnlineRetailDB'' not found.', 16, 1) end
RESTORE VERIFYONLY 
FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\OnlineRetailDB.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO


--------Tail Log BackUP
USE [master]
BACKUP LOG [OnlineRetailDB] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\OnlineRetailDB_LogBackup_2024-08-22_18-20-21.bak' WITH NOFORMAT, NOINIT,  NAME = N'OnlineRetailDB_LogBackup_2024-08-22_18-20-21', NOSKIP, NOREWIND, NOUNLOAD,  NORECOVERY ,  STATS = 5
RESTORE DATABASE [OnlineRetailDB] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\OnlineRetailDB.bak' WITH  FILE = 2,  NOUNLOAD,  STATS = 5

GO


/*
===================================================
Creating Automated Maintenance Plan
===================================================
*/
