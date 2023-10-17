-- To view each database

SELECT *
FROM SalesLT.Customer

SELECT *
FROM SalesLT.SalesOrderHeader

SELECT *
FROM SalesLT.SalesOrderDetail

SELECT *
FROM SalesLT.CustomerAddress

SELECT *
FROM SalesLT.Address

-- To view the top 10 customers by revenue, the country they shipped to, the cities and their revenue

SELECT TOP (10)
	CONCAT(C.LastName, ', ', C.FirstName, ' ', C.MiddleName) AS FullName,
	A.City,
	A.CountryRegion,
	SUM(SOD.OrderQty * SOD.UnitPrice) AS Revenue
FROM SalesLT.Customer AS C
	JOIN SalesLT.SalesOrderHeader AS SOH
		ON C.CustomerID = SOH.CustomerID
	JOIN SalesLT.SalesOrderDetail AS SOD
		ON SOD.SalesOrderID = SOH.SalesOrderID
	JOIN SalesLT.CustomerAddress AS CA
		ON C.CustomerID = CA.CustomerID
	JOIN SalesLT.Address AS A
		ON A.AddressID = CA.AddressID
GROUP BY C.LastName, 
		C.FirstName,  
		C.MiddleName, 
		A.City, 
		A.CountryRegion
ORDER BY Revenue DESC;

-- Creating 4 distinct Customer segments using the total Revenue (orderqty * unitprice) by customer. 

SELECT 
	C.CustomerID,
	C.CompanyName,
	SUM(SOD.OrderQty * SOD.UnitPrice) AS TotalRevenue,
		CASE 
			WHEN SUM (SOD.OrderQty * SOD.UnitPrice) > 67500 THEN '15% Discount'
			WHEN SUM (SOD.OrderQty * SOD.UnitPrice) BETWEEN 45000 AND 67500 THEN '10% Discount'
			WHEN SUM (SOD.OrderQty * SOD.UnitPrice) BETWEEN 22500 AND 45000 THEN '5% Discount'
			ELSE 'No Discount'
		END AS 'Customer Segment'
FROM SalesLT.Customer AS C
	JOIN SalesLT.SalesOrderHeader AS SOH
		ON C.CustomerID = SOH.CustomerID
	JOIN SalesLT.SalesOrderDetail AS SOD
		ON SOD.SalesOrderID = SOH.SalesOrderID
GROUP BY C.CompanyName,
	C.CustomerID
ORDER BY TotalRevenue DESC;

-- To view which products with their respective categories, the customers bought on the last day of business?

SELECT
	C.CustomerID, 
	P.ProductID,
	P.Name AS ProductName,
	PC.Name AS ProductCategory,
	SOH.OrderDate AS Date
FROM SalesLT.Customer AS C
	Join SalesLT.SalesOrderHeader AS SOH
		ON C.CustomerID = SOH.CustomerID
	JOIN SalesLT.SalesOrderDetail AS SOD
		ON SOH.SalesOrderID = SOD.SalesOrderID
	JOIN SalesLT.Product AS P
		ON SOD.ProductID = P.ProductID
	JOIN SalesLT.ProductCategory AS PC
		ON P.ProductCategoryID = PC.ProductCategoryID
WHERE OrderDate =
  (SELECT MAX(SOH.OrderDate)
  FROM SalesLT.SalesOrderHeader AS SOH);

-- Creating a View called 'customersegment' that stores the details (id, name, revenue) for customers and their segment?

CREATE VIEW CustomerSegment 
AS
	SELECT 
		C.CustomerID,
		C.CompanyName,
		SUM(SOD.OrderQty * SOD.UnitPrice) AS TotalRevenue,
			CASE 
				WHEN SUM (SOD.OrderQty * SOD.UnitPrice) > 67500 THEN '15% Discount'
				WHEN SUM (SOD.OrderQty * SOD.UnitPrice) BETWEEN 45000 AND 67500 THEN '10% Discount'
				WHEN SUM (SOD.OrderQty * SOD.UnitPrice) BETWEEN 22500 AND 45000 THEN '5% Discount'
				ELSE 'No Discount'
			END AS 'Customer Segment'
	FROM SalesLT.Customer AS C
		JOIN SalesLT.SalesOrderHeader AS SOH
			ON C.CustomerID = SOH.CustomerID
		JOIN SalesLT.SalesOrderDetail AS SOD
			ON SOD.SalesOrderID = SOH.SalesOrderID
	GROUP BY C.CompanyName,
		C.CustomerID;

	--- To query the view
	
			SELECT *
			FROM CustomerSegment
			ORDER BY TotalRevenue DESC;


-- To view the top 3 selling product in each category  by revenue

SELECT *
FROM
	(SELECT 
			P.Name AS ProductName, 
			PC.Name AS ProductCategory,
			SUM(SOD.OrderQty*SOD.UnitPrice) AS Revenue,
			RANK() OVER (PARTITION BY PC.Name ORDER BY SUM(SOD.OrderQty * SOD.UnitPrice) DESC) AS ProductRank
		FROM SalesLT.Product AS P
			JOIN SalesLT.ProductCategory AS PC
				ON P.ProductCategoryID = PC.ProductCategoryID
			JOIN SalesLT.SalesOrderDetail AS SOD
				ON P.ProductID = SOD.ProductID
		GROUP BY 
			SOD.ProductID,
			P.Name,
			PC.Name) AS Product
WHERE ProductRank <=3
ORDER BY ProductCategory,
	Revenue DESC;
