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

WITH ranked_products AS (
	SELECT 
		product_id,
		region,
		sales_price,
		ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales_price DESC) AS rank
	FROM orders
)
SELECT * FROM ranked_products WHERE rank <= 5;

-- MoM GROWTH COMAPARISON FOR 2022 AND 2023 SALES --
WITH YearlyTotals AS (
	SELECT 
		MONTH(order_date) AS month,
		SUM(sales_price) AS total_sales
	FROM orders
	GROUP BY month(order_date)
)
SELECT 
	month,
	total_sales,
	LAG(total_sales) OVER (ORDER BY month) AS prev_year_sales,
	CASE 
		WHEN LAG(total_sales) OVER (ORDER BY month) = 0 THEN NULL
		ELSE ((total_sales - LAG(total_sales) OVER (ORDER BY month)) / LAG(total_sales) OVER (ORDER BY month)) * 100
	END AS yoy_change_perc
FROM YearlyTotals
ORDER BY month;
