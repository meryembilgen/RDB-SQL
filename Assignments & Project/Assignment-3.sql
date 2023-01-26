-- Assignment-3

USE SampleRetail


 WITH cte as (
			   SELECT    product_id, discount, SUM(quantity) as total_quantity 
			   FROM      sale.order_item
			   GROUP BY  product_id, discount 
),
 T1 as (
         SELECT *, total_quantity as lowest_quantity 
         FROM cte 
         WHERE discount= 0.05 
),
T2 as (
		SELECT *, total_quantity as highest_quantity 
		FROM cte 
		WHERE discount= 0.20
)
SELECT t1.Product_id, CASE WHEN lowest_quantity < highest_quantity THEN 'Positive' 
                           WHEN lowest_quantity > highest_quantity THEN 'Negative'
                           ELSE 'Neutral' END  Discount_Effect
FROM   t1 LEFT JOIN t2 on t1.product_id = t2.product_id

