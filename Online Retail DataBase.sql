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





-- 1. Trigger for Products Table


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

SELECT * FROM Products;
SELECT * FROM  ChangeLog;





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
