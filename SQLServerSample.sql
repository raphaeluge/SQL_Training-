

--https://www.youtube.com/watch?v=wK7r0CXC3GY

--How to calculate monthly sales SQL Server

USE AdventureWorks2019;
GO

--SELECT TOP 10 * 
--FROM Purchasing.PurchaseOrderHeader


SELECT 
		YEAR(po.OrderDate) [YEAR],
		MONTH(po.OrderDate) Month_OrderDate,		
		SUM(po.TaxAmt) TaxAmt,
		SUM(po.Freight) Freight,
		SUM(po.TotalDue) TotalDue, 
		SUM(po.SubTotal) Monthly_SubTotal,
		LAG(SUM(po.SubTotal),1) OVER (ORDER BY YEAR(po.OrderDate), MONTH(po.OrderDate))  AS Sales_OneMonthAgo,
		SUM(po.SubTotal) - LAG(SUM(po.SubTotal),1) OVER (ORDER BY YEAR(po.OrderDate), MONTH(po.OrderDate)) DiffMonthlySales,
		SUM(po.SubTotal) - LAG(SUM(po.SubTotal),12) OVER (ORDER BY YEAR(po.OrderDate), MONTH(po.OrderDate)) Diff_12MonthsAgo,
		LAG(SUM(po.SubTotal), MONTH(po.OrderDate) - 1) OVER (ORDER BY YEAR(po.OrderDate), MONTH(po.OrderDate)) FirstmonthComparism
FROM Purchasing.PurchaseOrderHeader po 
GROUP BY  YEAR(po.OrderDate), MONTH(po.OrderDate)
ORDER BY YEAR(po.OrderDate), MONTH(po.OrderDate)



-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

DECLARE @sales as Table
(
	sale_year		int,
	sale_month		int,
	monthly_sales	decimal(11,2),
	end_of_month	date
)

Insert into @sales
(
	sale_year,
	sale_month,
	monthly_sales
)

SELECT --Calculating monthly sales
	YEAR(po.OrderDate),
	MONTH(po.OrderDate),
	SUM(po.SubTotal)
FROM Purchasing.PurchaseOrderHeader po
GROUP BY YEAR(po.OrderDate), MONTH(po.OrderDate)

UPDATE @sales
	SET end_of_month = EOMONTH(DATEFROMPARTS(sale_year, sale_month,1),0)
	

SELECT
	DATEFROMPARTS(sale_year, sale_month,1) AS Start_of_month,
	end_of_month,
	FORMAT(monthly_sales,'C','en-US') Monthly_Sales,
	FORMAT(LAG(monthly_sales, 1) OVER ( ORDER BY sale_month ),'C','en-US') AS SalesDiffFromLastMoth
FROM @sales
ORDER BY sale_year, sale_month


--SELECT t, a, avg(a) OVER (ORDER BY t ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
--FROM data
--ORDER BY t