-- top 10 highest revenue genrating produc --
SELECT * FROM orders;

SELECT TOP 10
	product_id, 
	category, 
	SUM(sales_price) AS revenue
FROM orders
GROUP BY
	product_id,
	category
ORDER BY revenue DESC;

-- TOP 5 HIGHEST SELLING PRODUCT IN EACH REGION --
WITH total_sales AS (
	SELECT 
		product_id,
		region,
		SUM(sales_price) AS total
	FROM 
		orders
	GROUP BY
		product_id,
		region
)
SELECT * 
FROM 
	(SELECT 
		*, 
		RANK() OVER(PARTITION BY REGION ORDER BY total DESC) AS rank FROM total_sales) AS ranked
WHERE rank <= 5;


-- MoM GROWTH FROM 2022 TO 2023 SALES --
WITH monthlytotals AS (
	SELECT
		YEAR(order_date) year,
		MONTH(order_date) AS month,
		SUM(sales_price) AS total_sales
	FROM orders
	WHERE YEAR(order_date) = 2022 OR YEAR(order_date) = 2023	
	GROUP BY
		MONTH(order_date),
		YEAR(order_date)
)
SELECT 
	month,
	total_sales,
	LAG(total_sales) OVER (ORDER BY month) AS prev_sales,
	CASE 
		WHEN LAG(total_sales) OVER (ORDER BY month) = 0 THEN NULL
		ELSE ROUND(((total_sales - LAG(total_sales) OVER (ORDER BY month)) / LAG(total_sales) OVER (ORDER BY month)) * 100,2)
	END AS mom_change_perc
FROM monthlytotals
ORDER BY year DESC, month ;

-- MoM GROWTH COMAPARISON FOR 2022 TO 2023 SALES --
WITH monthlytotals AS (
	SELECT
		YEAR(order_date) sales_year,
		MONTH(order_date) AS sales_month,
		SUM(sales_price) AS total_sales
	FROM orders
--	WHERE YEAR(order_date) = 2022 OR YEAR(order_date) = 2023	
	GROUP BY
		MONTH(order_date),
		YEAR(order_date)
)
SELECT
	sales_month,
	SUM(CASE WHEN sales_year = 2022 THEN total_sales ELSE 0 END) AS 2022,
	SUM(CASE WHEN sales_year = 2023 THEN total_sales ELSE 0 END) AS 2023
FROM monthlytotals
GROUP BY 
	sales_month
ORDER BY 
	sales_month;

-- Created by GitHub Copilot in SSMS - review carefully before executing
WITH monthlytotals AS (
	SELECT
		YEAR(order_date) AS sales_year,
		MONTH(order_date) AS sales_month,
		SUM(sales_price) AS total_sales
	FROM orders
	WHERE order_date >= '2022-01-01' AND order_date < '2024-01-01'
	GROUP BY
		YEAR(order_date),
		MONTH(order_date)
)
SELECT
	sales_month,
	SUM(CASE WHEN sales_year = 2022 THEN total_sales ELSE 0 END) AS [2022],
	SUM(CASE WHEN sales_year = 2023 THEN total_sales ELSE 0 END) AS [2023]
FROM monthlytotals
GROUP BY 
	sales_month
ORDER BY 
	sales_month;