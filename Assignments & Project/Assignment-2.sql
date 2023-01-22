-- Assignment-2

--1. Product Sales
USE SampleRetail


SELECT  c.customer_id, c.first_name, c.last_name,CASE WHEN c.customer_id IN (
    SELECT c1.customer_id
    FROM   sale.customer c1
           inner join sale.orders o on c1.customer_id=o.customer_id
           inner join sale.order_item oi on o.order_id=oi.order_id
           inner join product.product p on oi.product_id=p.product_id
    WHERE product_name = 'Polk Audio - 50 W Woofer - Black'
) THEN 'YES' ELSE 'NO' END AS Other_Product
FROM   sale.customer c
    inner join sale.orders o on c.customer_id=o.customer_id
    inner join sale.order_item oi on o.order_id=oi.order_id
    inner join product.product p on oi.product_id=p.product_id
WHERE  product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
ORDER BY customer_id ;


--2. Conversion Rate
--a.
CREATE TABLE ECommerce (	Visitor_ID INT IDENTITY (1, 1) PRIMARY KEY,	Adv_Type VARCHAR (255) NOT NULL,	Action1 VARCHAR (255) NOT NULL);
INSERT INTO ECommerce (Adv_Type, Action1)VALUES ('A', 'Left'),('A', 'Order'),('B', 'Left'),('A', 'Order'),('A', 'Review'),('A', 'Left'),('B', 'Left'),('B', 'Order'),('B', 'Review'),('A', 'Review');
--b.
SELECT Adv_Type, count(Action1) as Action
FROM ECommerce
GROUP BY Adv_Type;
---c. 
SELECT Adv_Type,
CONVERT(DECIMAL(18,2),SUM(CASE WHEN Action1 = 'Order' then 1 else 0 end)* 1.0 / count(*)) AS Conversion_Rate
FROM ECommerce
GROUP BY Adv_Type;

