-- Explanation of Changes:
-- Improved Readability: Used COALESCE to handle potential NULL values.
-- Enhanced Logic: Minor logical improvements to ensure queries handle potential data inconsistencies.

-- 1. Identify products with high inventory but low sales and suggest inventory optimization strategies

SELECT 
    p.productCode, 
    p.productName, 
    p.quantityInStock, 
    COALESCE(SUM(od.quantityOrdered), 0) AS totalOrdered, 
    (p.quantityInStock - COALESCE(SUM(od.quantityOrdered), 0)) AS inventorySurplus
FROM 
    mintclassics.products AS p
LEFT JOIN 
    mintclassics.orderdetails AS od ON p.productCode = od.productCode
GROUP BY 
    p.productCode, p.productName, p.quantityInStock
HAVING 
    inventorySurplus > 0
ORDER BY 
    inventorySurplus DESC;

-- 2. Evaluate the necessity of warehouses based on their inventory levels

-- 2.1. Total inventory by product and warehouse
SELECT
    p.productName,
    w.warehouseName,
    SUM(p.quantityInStock) AS totalInventory
FROM
    mintclassics.products AS p
JOIN
    mintclassics.warehouses AS w ON p.warehouseCode = w.warehouseCode
GROUP BY
    p.productName, w.warehouseName
ORDER BY
    totalInventory ASC;

-- 2.2. Total inventory by warehouse
SELECT 
    w.warehouseCode, 
    w.warehouseName, 
    SUM(p.quantityInStock) AS totalInventory
FROM 
    mintclassics.warehouses AS w
LEFT JOIN 
    mintclassics.products AS p ON w.warehouseCode = p.warehouseCode
GROUP BY 
    w.warehouseCode, w.warehouseName
ORDER BY 
    totalInventory DESC;

-- 3. Analyze the relationship between product prices and sales levels to inform price adjustments

SELECT
    p.productCode,
    p.productName,
    p.buyPrice,
    COALESCE(SUM(od.quantityOrdered), 0) AS totalOrdered
FROM
    mintclassics.products AS p
LEFT JOIN
    mintclassics.orderdetails AS od ON p.productCode = od.productCode
GROUP BY
    p.productCode, p.productName, p.buyPrice
ORDER BY
    p.buyPrice DESC;

-- 4. Identify top customers by sales volume to focus sales efforts

SELECT
    c.customerNumber,
    c.customerName,
    COUNT(o.orderNumber) AS totalSales
FROM
    mintclassics.customers AS c
JOIN
    mintclassics.orders AS o ON c.customerNumber = o.customerNumber
GROUP BY
    c.customerNumber, c.customerName
ORDER BY
    totalSales DESC;

-- 5. Evaluate sales employees' performance using total sales data

SELECT
    e.employeeNumber,
    e.lastName,
    e.firstName,
    e.jobTitle,
    COALESCE(SUM(od.priceEach * od.quantityOrdered), 0) AS totalSales
FROM
    mintclassics.employees AS e
LEFT JOIN
    mintclassics.customers AS c ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN
    mintclassics.orders AS o ON c.customerNumber = o.customerNumber
LEFT JOIN
    mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
GROUP BY
    e.employeeNumber, e.lastName, e.firstName, e.jobTitle
ORDER BY
    totalSales DESC;

-- 6. Analyze customer payment trends and assess credit risks to manage cash flow

SELECT
    c.customerNumber,
    c.customerName,
    p.paymentDate,
    p.amount AS paymentAmount
FROM
    mintclassics.customers AS c
LEFT JOIN
    mintclassics.payments AS p ON c.customerNumber = p.customerNumber
ORDER BY	
    paymentAmount DESC;

-- 7. Compare performance of various product lines to identify successful products and those needing improvement or removal

SELECT
    p.productLine,
    pl.textDescription AS productLineDescription,
    SUM(p.quantityInStock) AS totalInventory,
    COALESCE(SUM(od.quantityOrdered), 0) AS totalSales,
    COALESCE(SUM(od.priceEach * od.quantityOrdered), 0) AS totalRevenue,
    (COALESCE(SUM(od.quantityOrdered), 0) / NULLIF(SUM(p.quantityInStock), 0)) * 100 AS salesToInventoryPercentage
FROM
    mintclassics.products AS p
LEFT JOIN
    mintclassics.productlines AS pl ON p.productLine = pl.productLine
LEFT JOIN
    mintclassics.orderdetails AS od ON p.productCode = od.productCode
GROUP BY
    p.productLine, pl.textDescription
ORDER BY
    salesToInventoryPercentage DESC;

-- 8. Evaluate company's credit policies by identifying customers with credit issues

SELECT
    c.customerNumber,
    c.customerName,
    c.creditLimit,
    COALESCE(SUM(p.amount), 0) AS totalPayments,
    (c.creditLimit - COALESCE(SUM(p.amount), 0)) AS creditLimitDifference
FROM
    mintclassics.customers AS c
LEFT JOIN
    mintclassics.payments AS p ON c.customerNumber = p.customerNumber
GROUP BY
    c.customerNumber, c.creditLimit
HAVING
    totalPayments < c.creditLimit
ORDER BY
    totalPayments ASC;
