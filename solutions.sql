-- 1. Are there products with high inventory but low sales? How can we optimize the inventory of such products?

SELECT 
    productCode, 
    productName, 
    quantityInStock, 
    totalOrdered, 
    (quantityInStock - totalOrdered) AS inventoryShortage
FROM 
    (
        SELECT 
            p.productCode, 
            p.productName, 
            p.quantityInStock, 
            SUM(od.quantityOrdered) AS totalOrdered
        FROM 
            mintclassics.products AS p
        LEFT JOIN 
            mintclassics.orderdetails AS od ON p.productCode = od.productCode
        GROUP BY 
            p.productCode, 
            p.productName, 
            p.quantityInStock
    ) AS inventory_data
WHERE 
    (quantityInStock - totalOrdered) > 0
ORDER BY 
    inventoryShortage DESC;


-- 2. Are all the warehouses currently in use still necessary? How can we review warehouses that have low or inactive inventory?

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
    totalInventory asc;

SELECT 
    w.warehouseCode, 
    w.warehouseName, 
    SUM(p.quantityInStock) AS totalInventory
FROM 
    mintclassics.warehouses AS w
LEFT JOIN 
    mintclassics.products AS p ON w.warehouseCode = p.warehouseCode
GROUP BY 
    w.warehouseCode, 
    w.warehouseName
ORDER BY
	totalInventory DESC;


-- 3. Is there a relationship between product prices and their sales levels? How can price adjustments impact sales?

SELECT
    p.productCode,
    p.productName,
    p.buyPrice,
    SUM(od.quantityOrdered) AS totalOrdered
FROM
    mintclassics.products AS p
LEFT JOIN
    mintclassics.orderdetails AS od ON p.productCode = od.productCode
GROUP BY
    p.productCode, p.productName, p.buyPrice
ORDER BY
	buyPrice DESC;


-- 4. Who are the customers contributing the most to sales? How can sales efforts be focused on these valuable customers?

SELECT
    c.customerNumber,
    c.customerName,
    count(o.orderNumber) AS totalSales
FROM
    mintclassics.customers AS c
JOIN
    mintclassics.orders AS o ON c.customerNumber = o.customerNumber
GROUP BY
    c.customerNumber, c.customerName
ORDER BY
	totalSales DESC;


-- 5. How can the performance of sales employees be evaluated using sales data?

SELECT
    e.employeeNumber,
    e.lastName,
    e.firstName,
    e.jobTitle,
    SUM(od.priceEach * od.quantityOrdered) AS totalSales
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


-- 6. How can customer payment trends be analyzed? What credit risks need to be considered, and how can cash flow be managed?
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


-- 7. How can the performance of various product lines be compared? Which products are the most successful, and which ones need improvement or removal?

SELECT
    p.productLine,
    pl.textDescription AS productLineDescription,
    SUM(p.quantityInStock) AS totalInventory,
    SUM(od.quantityOrdered) AS totalSales,
    SUM(od.priceEach * od.quantityOrdered) AS totalRevenue,
    (SUM(od.quantityOrdered) / SUM(p.quantityInStock)) * 100 AS salesToInventoryPercentage
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


-- 8. How can the company’s credit policies be evaluated? Are there any customers with credit issues that need to be addressed?

SELECT
    c.customerNumber,
    c.customerName,
    c.creditLimit,
    SUM(p.amount) AS totalPayments,
    (SUM(p.amount) - c.creditLimit) AS creditLimitDifference
FROM
    mintclassics.customers AS c
LEFT JOIN
    mintclassics.payments AS p ON c.customerNumber = p.customerNumber
GROUP BY
    c.customerNumber, c.creditLimit
HAVING
    SUM(p.amount) < c.creditLimit
ORDER BY
	totalPayments ASC;
