create database temp;
use temp;

CREATE TABLE transactions (
    buyer_id INT,
    purchase_time TIMESTAMP,
    refund_item TIMESTAMP NULL,
    store_id VARCHAR(10),
    item_id VARCHAR(10),
    gross_transaction_value DECIMAL(10,2)
)
 INSERT INTO transactions (buyer_id, purchase_time, refund_item, store_id, item_id, gross_transaction_value) 
VALUES 
    (3, '2019-09-19 21:19:06.544',NULL , 'a', 'a1', 58),
    (12, '2019-12-10 20:10:14.324','2019-12-15 23:19:06.544', 'b', 'b2', 475),
    (3, '2020-09-01 23:59:46.561', '2020-09-02 21:22:06.331', 'f', 'f9', 33),
    (2, '2020-04-30 21:19:06.544', NULL, 'd', 'd3', 250),
    (1,'2020-10-22 22:20:06.531', NULL,'f','f2',91),
    (8, '2020-04-16 21:10:22.214', NULL, 'e', 'e7', 24),
    (5, '2019-09-23 12:09:35.542', '2019-09-27 02:55:02.114', 'g', 'g6', 61);
    
    CREATE TABLE items (
    store_id VARCHAR(10),
    item_id VARCHAR(10),
    item_category VARCHAR(50),
    item_name VARCHAR(50)
);
INSERT INTO items (store_id, item_id, item_category, item_name) 
VALUES 
    ('a', 'a1', 'pants', 'denim pants'),
    ('a', 'a2', 'tops', 'blouse'),
    ('f', 'f1', 'table', 'coffee table'),
    ('f', 'f5', 'chair', 'lounge chair'),
    ('f', 'f6', 'chair', 'armchair'),
    ('d', 'd2', 'jewelry', 'bracelet'),
    ('b', 'b4', 'earphone', 'airpods');
    --
    
/*1. What is the count of purchases per month (excluding refunded purchases)?*/
    
    SELECT 
    DATE_FORMAT(purchase_time, '%Y-%m') AS month, 
    COUNT(*) AS purchase_count
FROM transactions
WHERE refund_item IS NULL
GROUP BY month
ORDER BY month;


/*2. How many stores receive at least 5 orders/transactions in October 2020?*/

SELECT store_id, COUNT(*) AS total_orders
FROM transactions
WHERE DATE_FORMAT(purchase_time, '%Y-%m') = '2020-10'
GROUP BY store_id
HAVING total_orders >= 5;


/*3. For each store, what is the shortest interval (in min) from purchase to refund time?*/




SELECT store_id, 
       MIN(TIMESTAMPDIFF(MINUTE, purchase_time, refund_item)) AS min_refund_time
FROM transactions
WHERE refund_item IS NOT NULL
GROUP BY store_id;



/*4. What is the gross_transaction_value of every store’s first order?*/

WITH FirstOrder AS (
    SELECT store_id, MIN(purchase_time) AS first_order_time
    FROM transactions
    GROUP BY store_id
)
SELECT t.store_id, t.gross_transaction_value
FROM transactions t
JOIN FirstOrder f ON t.store_id = f.store_id AND t.purchase_time = f.first_order_time;



/*5. What is the most popular item name that buyers order on their first purchase?*/

WITH FirstPurchase AS (
    SELECT buyer_id, MIN(purchase_time) AS first_purchase_time
    FROM transactions
    GROUP BY buyer_id
)
SELECT i.item_name, COUNT(*) AS order_count
FROM transactions t
JOIN FirstPurchase f ON t.buyer_id = f.buyer_id AND t.purchase_time = f.first_purchase_time
JOIN items i ON t.item_id = i.item_id
GROUP BY i.item_name
ORDER BY order_count DESC
LIMIT 1;

/*Finding the moat popular item will help the shopkeeper which product attracts the customer at the first glance and the shopkeeper can invest RnD to improve the product even more.*/




/*6. Create a flag in the transaction items table indicating whether the refund can be processed or not. 
The condition for a refund to be processed is that it has to happen within 72 of Purchase time.*/

SELECT buyer_id, purchase_time, refund_item,
       CASE 
           WHEN refund_item IS NOT NULL AND TIMESTAMPDIFF(HOUR, purchase_time, refund_item) <= 72 
           THEN 'Processed' 
           ELSE 'Not Processed' 
       END AS refund_status
FROM transactions;
/* This will automate the task of refunding */




/*7. Create a rank by buyer_id column in the transaction items table and filter for only the second purchase per buyer. */

WITH RankedPurchases AS (
    SELECT 
        buyer_id,
        purchase_time,
        ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time) AS purchase_rank
    FROM 
        transactions
    
)
SELECT 
    buyer_id,
    purchase_time
FROM 
    RankedPurchases
WHERE 
    purchase_rank = 2;




/*8. How will you find the second transaction time per buyer (don’t use min/max; assume there were more transactions per buyer in the table)*/
WITH RankedPurchases AS (
    SELECT 
        buyer_id, 
        purchase_time, 
        ROW_NUMBER() OVER  (PARTITION BY buyer_id ORDER BY purchase_time ) AS r_ank
    FROM transactions
)
SELECT buyer_id, purchase_time
FROM RankedPurchases
WHERE r_ank = 2;