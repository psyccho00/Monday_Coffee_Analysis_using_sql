
CREATE TABLE IF NOT EXISTS city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);


CREATE TABLE IF NOT EXISTS customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);


CREATE TABLE IF NOT EXISTS products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);


CREATE TABLE IF NOT EXISTS sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);




-- Q.1 
-- Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT 
	city_name,
	population * 0.25 as coffee_consumers,
	city_rank
FROM city
ORDER BY 2 DESC;


-- Q.2 
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT
	SUM(total) AS total_revenue
FROM sales
WHERE 
	EXTRACT(YEAR FROM sale_date) = 2023
	AND
	EXTRACT(QUARTER FROM sale_date) = 4;


SELECT
	ci.city_name AS city,
	SUM(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city as ci
On c.city_id = ci.city_id
WHERE 
	EXTRACT(YEAR FROM sale_date) = 2023
	AND
	EXTRACT(QUARTER FROM sale_date) = 4
GROUP BY 1
ORDER BY 2 DESC;	


-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
SELECT 
	p.product_name,
	s.product_id,
	SUM(s.total) AS total_revenue,
	count(s.total) AS units_sold
FROM sales AS s
JOIN products AS p
ON s.product_id = p.product_id
GROUP BY 1,2
ORDER BY 2;


-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
SELECT
	ci.city_name AS city,
	SUM(s.total) AS total_revenue,
	COUNT(DISTINCT s.customer_id) AS customers,
	ROUND( SUM(s.total)::numeric / COUNT(DISTINCT s.customer_id)::numeric ,2 ) AS avg_sale_per_customer
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city as ci
On c.city_id = ci.city_id
GROUP BY 1
ORDER BY 2 DESC;


-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current customers, estimated coffee consumers (25%)
WITH 
	city_table AS
(
	SELECT 
		city_name,
		population * 0.25 as coffee_consumers,
		city_rank
	FROM city
	ORDER BY 2 DESC
),
customer_table AS
(
	SELECT
		ci.city_name,
		COUNT(DISTINCT s.customer_id) AS customers
	FROM sales AS s
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	On c.city_id = ci.city_id
	GROUP BY 1
	ORDER BY 2 DESC
)
SELECT
	ct.city_name,
	ct.coffee_consumers AS estimated_coffee_consumers,
	cut.customers AS total_current_customers
FROM city_table AS ct
JOIN customer_table AS cut
ON ct.city_name = cut.city_name
ORDER BY 1;


-- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
SELECT 
	*
FROM
(
	SELECT
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) AS total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC ) AS rank
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1,2
) AS t1
WHERE rank <=3;


-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
SELECT 
	c.city_name,
	COUNT(DISTINCT s.customer_id) AS unique_customer
FROM sales AS s
JOIN customers AS cu
ON s.customer_id = cu.customer_id
JOIN city AS c
ON cu.city_id = c.city_id
WHERE s.product_id <=14
GROUP BY 1
ORDER BY 1;


-- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
WITH city_table AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as unique_customer,
		ROUND(
				SUM(s.total)::numeric / COUNT(DISTINCT s.customer_id)::numeric
				,2) as avg_sale_pr_cx		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent AS 
(
	SELECT 
		city_name, 
		estimated_rent
	FROM city
)
SELECT 
	cr.city_name,
	cr.estimated_rent,
	ct.unique_customer,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric / ct.unique_customer::numeric
		, 2) as avg_rent_per_cx
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 4 DESC;


-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

WITH monthly_sale AS
(
	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM s.sale_date) AS months,
		EXTRACT(YEAR FROM s.sale_date) AS years,
		SUM(s.total) AS total_sale
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1,2,3 
	ORDER BY 1,3,2
),
growth_ratio AS
(
	SELECT 
		city_name,
		months,
		years,
		total_sale AS cr_month_sale,
		LAG (total_sale, 1) OVER (PARTITION BY city_name ORDER BY years, months) AS last_month_sale
		FROM monthly_sale	
)
SELECT
	city_name,
	months,
	years,
	cr_month_sale,
	last_month_sale,
	ROUND(
		(cr_month_sale-last_month_sale)::numeric/last_month_sale::numeric * 100
		, 2
		) as growth_ratio
FROM growth_ratio
WHERE 
	last_month_sale IS NOT NULL	;


-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer


select * from sales;
select * from customers;
select * from city;
select * from products;



WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT s.customer_id) AS total_cx,
		ROUND(
				SUM(s.total)::numeric/
					COUNT(DISTINCT s.customer_id)::numeric
				,2) AS avg_sale_pr_cx
		
	FROM sales AS s
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	JOIN city AS ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(
	SELECT 
		city_name, 
		estimated_rent,
		ROUND((population * 0.25)/1000000, 3) AS estimated_coffee_consumer_in_millions
	FROM city
)
SELECT 
	cr.city_name,
	total_revenue,
	cr.estimated_rent AS total_rent,
	ct.total_cx,
	estimated_coffee_consumer_in_millions,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric/
									ct.total_cx::numeric
		, 2) AS avg_rent_per_cx
FROM city_rent AS cr
JOIN city_table AS ct
ON cr.city_name = ct.city_name
ORDER BY 2 DESC;

