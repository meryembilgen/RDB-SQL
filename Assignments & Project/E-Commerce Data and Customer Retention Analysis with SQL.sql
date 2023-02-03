
USE E_COMMERCE

SELECT * FROM dbo.e_commerce_data;

----1. Find the top 3 customers who have the maximum count of orders.

SELECT   TOP 3 SUM(Order_Quantity) count_of_orders
FROM     dbo.e_commerce_data
GROUP BY Cust_ID 
ORDER BY SUM(Order_Quantity) desc;


----2. Find the customer whose order took the maximum time to get shipping.

SELECT  Order_Date, Ship_Date, daystakenforshipping,
        DATEDIFF(DAY, Order_Date, Ship_Date) day_diff, daystakenforshipping - DATEDIFF(DAY, Order_Date, Ship_Date) 
FROM    dbo.e_commerce_data
WHERE   daystakenforshipping - DATEDIFF(DAY, Order_Date, Ship_Date) > 0 ;    -- daystakenforshipping de hata olmadýðýný kontrol ettik

 --1.yol
SELECT   TOP 1 Order_Date, Ship_Date, Cust_ID,
         DATEDIFF(DAY, Order_Date, Ship_Date) day_diff
FROM     dbo.e_commerce_data
ORDER BY day_diff desc;

--2.yol
SELECT   TOP 1 daystakenforshipping,Cust_ID, Customer_Name
FROM     dbo.e_commerce_data  
ORDER BY daystakenforshipping desc;


----3. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
SELECT	MONTH(order_date) Months , count(distinct Cust_ID) Number_of_Customers
FROM	dbo.e_commerce_data
WHERE   YEAR(Order_Date) = 2011 and cust_ID in
	(
	SELECT  DISTINCT Cust_ID
    FROM    dbo.e_commerce_data
    WHERE   Order_Date BETWEEN '2011-01-01' AND '2011-01-31'
	)
GROUP BY MONTH(order_date);


----4. Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, in ascending order by Customer ID.
SELECT   Cust_ID,
	     DATEDIFF(DAY, MAX(CASE WHEN seqnum = 1 THEN OT.Order_Date END), MAX(CASE WHEN seqnum = 3 THEN OT.Order_Date END)) Dýfference,
         MAX(CASE WHEN seqnum = 1 THEN OT.Order_Date END) as OrderDate_1,
         MAX(CASE WHEN seqnum = 3 THEN OT.Order_Date END) as OrderDate_3
FROM    (
		   SELECT Cust_ID, Order_Date, ROW_NUMBER() OVER (PARTITION BY o.Cust_ID ORDER BY o.order_date) as seqnum
           FROM dbo.e_commerce_data o
         ) OT 
GROUP BY OT.Cust_ID
ORDER BY Cust_ID;


----5. Write a query that returns customers who purchased both product 11 and  product 14, as well as the ratio of these products to the total number of products purchased by the customer.
--1.yol
WITH cte_11 AS (
				 SELECT *
				 FROM dbo.e_commerce_data
				 WHERE Prod_ID = 'Prod_11'
	           ),
     cte_14 AS (
			   	 SELECT *
				 FROM dbo.e_commerce_data
				 WHERE Prod_ID = 'Prod_14'
	            ),
      cte_a AS (
				 SELECT DISTINCT a.Cust_ID
				 FROM cte_14 a
				 join cte_11 b on 
				 a.Cust_ID = b.Cust_ID
				)
		SELECT Cust_ID, 1.0*2/COUNT(DISTINCT Prod_ID) Ratio_of_Product_id
		FROM dbo.e_commerce_data
		WHERE Cust_ID in (
		SELECT *
		FROM cte_a)
		GROUP BY Cust_ID ;


--2.yol
WITH CTE AS 
(
SELECT   Cust_ID
FROM	 DBO.e_commerce_data
WHERE    Prod_ID = 'Prod_14' OR  Prod_ID = 'Prod_11'
GROUP BY Cust_ID
HAVING   COUNT(DISTINCT Prod_ID) > 1
)

SELECT	Cust_ID, 1.0 * 2 / COUNT(DISTINCT Prod_ID) Ratio_of_Product_id
FROM	DBO.e_commerce_data
WHERE	Cust_ID IN 
						(SELECT * FROM CTE)
GROUP BY Cust_ID
ORDER BY Cust_ID;



------------------Customer Segmentation------------------

----1. Create a “view” that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)

CREATE VIEW Logs AS (
    SELECT   Cust_ID, YEAR(Order_Date) Year,
	         MONTH(Order_Date) Month, 
	         DATENAME(MONTH,Order_Date) Month_name
    FROM     dbo.e_commerce_data
    GROUP BY Ord_ID, Cust_ID, Order_Date
)

SELECT	 * 
FROM     Logs
ORDER BY Cust_ID, Year, Month

----2. Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning business)

CREATE VIEW Visits AS (
SELECT   Cust_ID, YEAR(Order_Date) Year, MONTH(Order_Date) Month, 
         COUNT(*) AS count_of_visits
FROM     dbo.e_commerce_data
GROUP BY Cust_ID, YEAR(Order_Date), MONTH(Order_Date)
)


SELECT   * 
FROM     Visits
ORDER BY Cust_ID, year, month;

----3. For each visit of customers, create the next month of the visit as a separate column.
----4. Calculate the monthly time gap between two consecutive visits by each customer. 
----(Beraber)

WITH CTE AS (
    SELECT   Cust_ID, Order_Date,
             LEAD(Order_Date) OVER (PARTITION BY Cust_ID ORDER BY Order_Date) next_visit
    FROM     dbo.e_commerce_data
    GROUP BY Ord_ID, Cust_ID, Order_Date
)
SELECT *,
       DATEDIFF(MONTH, Order_Date, next_visit) gap
FROM   CTE; 

----5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.

WITH CTE AS (
			  SELECT   Cust_ID, Order_Date,
					   LEAD(Order_Date) OVER (PARTITION BY Cust_ID ORDER BY Order_Date) next_visit
			  FROM     dbo.e_commerce_data
			  GROUP BY Ord_ID, Cust_ID, Order_Date
             ), 
     CTE2 AS (
			  SELECT *,
				     DATEDIFF(MONTH, Order_Date, next_visit) gap
			  FROM   CTE
              ), 
     CTE3 AS (
			  SELECT *, 
				     CASE WHEN gap <=1 THEN 'regular' 
					 WHEN gap <=3 THEN 'mid_regular' 
					 ELSE 'churn' END AS monthly_loss
			  FROM   CTE2
			  WHERE  gap IS NOT NULL
            )
	SELECT *
	FROM CTE3;



------------------Month-Wise Retention Rate------------------

----1. Find the number of customers retained month-wise. (You can use time gaps)

-- Unique customers per month
CREATE VIEW unique_customers_per_month AS(
		SELECT   Year, Month,
		         COUNT(DISTINCT Cust_ID) AS customers
		FROM     visits
		GROUP BY Year, Month
)
 
SELECT   * 
FROM     unique_customers_per_month
ORDER BY Year, Month;

-- Month-wise customer retention rate
CREATE VIEW customer_retention_rate AS(
		SELECT a.Year, a.Month, b.Month AS next_month, CONVERT(DECIMAL(18,2), a.customers * 1.0 / b.customers) AS retention_rate
		FROM   unique_customers_per_month a
		       JOIN unique_customers_per_month b
		       ON a.Year = b.Year AND a.Month + 1 = b.Month
)

SELECT   * 
FROM     customer_retention_rate
ORDER BY Year, Month;

----2. Calculate the month-wise retention rate.

SELECT year, month, 
	   CAST(retention_rate*100 AS INT) AS retention_rate_percent
FROM   customer_retention_rate;
