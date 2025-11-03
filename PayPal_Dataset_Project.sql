SHOW DATABASES;
USE paypal;
SHOW TABLES;
DESCRIBE countries;
DESCRIBE currencies;
DESCRIBE merchants;
DESCRIBE transactions;
DESCRIBE users;
-- Total_sent--
SELECT 
    co.country_name,
    ROUND(SUM(t.transaction_amount), 2) AS total_sent
FROM 
    transactions t 
INNER JOIN users u 
ON t.sender_id=u.user_id
INNER JOIN countries  co
ON  u.country_id=co.country_id
WHERE 
     t.transaction_date >= '2023-10-01' AND     t.transaction_date < '2024-01-01'
GROUP BY 
    co.country_name
ORDER BY 
    total_sent DESC
LIMIT 5;
-- Total_received--
SELECT 
    co.country_name,
    ROUND(SUM(t.transaction_amount), 2) AS total_received
FROM 
    transactions t 
INNER JOIN users u 
ON t.recipient_id=u.user_id
INNER JOIN countries  co
ON  u.country_id=co.country_id
WHERE 
     t.transaction_date >= '2023-10-01' AND     t.transaction_date < '2024-01-01'
GROUP BY 
    co.country_name
ORDER BY 
    total_received DESC
LIMIT 5;
-- High_Value_transaction--
SELECT 
    transaction_id, sender_id, recipient_id, transaction_amount, currency_code
FROM 
    transactions 
WHERE 
     transaction_amount>10000 
     AND transaction_date > '2022-12-31' AND transaction_date< '2024-01-01'
ORDER BY 
    transaction_id, sender_id, recipient_id, transaction_amount, currency_code;
-- Merchant Performance--
        SELECT m.merchant_id, m.business_name, 
        SUM(t.transaction_amount) AS total_received,
        AVG(t.transaction_amount) AS average_transaction
        FROM 
                transactions t 
                INNER JOIN merchants m 
        ON t.recipient_id=m.merchant_id
        WHERE t.transaction_date> '2023-10-31' AND t.transaction_date<'2024-05-01'
        GROUP BY m.merchant_id, m.business_name
        ORDER BY total_received DESC, average_transaction DESC
        LIMIT 10;
-- Conversions Trends--
SELECT currency_code, 
SUM(transaction_amount) AS total_converted
FROM transactions 
WHERE transaction_date BETWEEN '2023-05-22' AND '2024-05-22'
GROUP BY currency_code
ORDER BY total_converted DESC
LIMIT 3;
-- Transaction Classification--
SELECT 
CASE WHEN transaction_amount>10000 THEN 'High Value'
         ELSE 'Regular'
         END AS transaction_category,
SUM(transaction_amount) AS total_amount
FROM transactions
WHERE transaction_date >= '2023-01-01' AND transaction_date < '2024-01-01'
GROUP BY transaction_category;
-- Nature of Transactions---
SELECT 
CASE WHEN u1.country_id=u2.country_id THEN 'Domestic'
        ELSE 'International' 
        END AS transaction_type,
COUNT(t.transaction_amount)AS transaction_count
FROM transactions t 
INNER JOIN users u1 
ON t.sender_id=u1.user_id
INNER JOIN users u2 
ON t.recipient_id=u2.user_id
WHERE t.transaction_date> '2024-01-01' AND t.transaction_date< '2024-04-01'
GROUP BY transaction_type; 
-- Transaction Behaviour--
SELECT
    u.user_id,
    u.email,
    avg_stats.avg_amount
FROM
    (
        SELECT
            t.sender_id,
            ROUND(AVG(t.transaction_amount), 2) AS avg_amount
        FROM
            transactions t
        WHERE
            t.transaction_date >= '2023-11-01'
            AND t.transaction_date < '2024-05-01'
        GROUP BY
            t.sender_id
        HAVING
            avg_amount > 5000
    ) AS avg_stats
JOIN users u 
ON avg_stats.sender_id = u.user_id
ORDER BY
    u.user_id ASC;
-- Monthly Transaction--
SELECT
    YEAR(transaction_date) AS transaction_year,
    MONTH(transaction_date) AS transaction_month,
    SUM(transaction_amount) AS total_amount
FROM
    transactions
WHERE transaction_date >= '2023-01-01' AND transaction_date< '2024-01-01'
GROUP BY YEAR(transaction_date), MONTH(transaction_date)
ORDER BY transaction_year ASC, transaction_month ASC;
-- Loyal Customer--
SELECT u.user_id, u.email, u.name, 
ROUND(SUM(t.transaction_amount),2) AS total_amount
FROM transactions t 
INNER JOIN users u 
ON t.sender_id=u.user_id
WHERE t.transaction_date BETWEEN '2023-05-22' AND '2024-05-22'
GROUP BY u.user_id, u.email, u.name
ORDER BY total_amount DESC
LIMIT 1;
-- Highest Transaction currency--
SELECT currency_code, 
SUM(transaction_amount) AS total_amount
FROM transactions
WHERE transaction_date BETWEEN '2023-05-22' AND '2024-05-22'
GROUP BY currency_code
ORDER BY total_amount DESC
LIMIT 1;
-- Top Performing Merchent--
SELECT m.business_name, 
SUM(t.transaction_amount) AS total_amount
FROM transactions t 
INNER JOIN merchants m 
ON t.recipient_id=m.merchant_id
WHERE t.transaction_date>= '2023-11-01' AND t.transaction_date< '2024-05-01'
GROUP BY m.business_name
ORDER BY total_amount DESC
LIMIT 1;
-- Count of transaction by transaction category---
SELECT
    CASE
        WHEN t.transaction_amount > 10000 AND u1.country_id <> u2.country_id THEN 'High Value International'
        WHEN t.transaction_amount > 10000 AND u1.country_id = u2.country_id THEN 'High Value Domestic'
        WHEN t.transaction_amount <= 10000 AND u1.country_id <> u2.country_id THEN 'Regular International'
        ELSE 'Regular Domestic'
    END AS transaction_category,
    COUNT(*) AS transaction_count
FROM
    transactions t
    JOIN users u1 ON t.sender_id = u1.user_id
    JOIN users u2 ON t.recipient_id = u2.user_id
WHERE
    YEAR(t.transaction_date) = 2023
GROUP BY
    transaction_category
ORDER BY
    transaction_count DESC;
-- GROUP-WISE TRANSACTIONS ---
SELECT 
YEAR(t.transaction_date) AS transaction_year,
MONTH(t.transaction_date) AS transaction_month, 
CASE WHEN t.transaction_amount>10000 THEN 'High Value'
         WHEN t.transaction_amount<10000 THEN 'Regular'
         END AS value_category,
CASE WHEN u1.country_id <> u2.country_id THEN 'International'
         ELSE 'Domestic'
         END AS location_category,
ROUND(SUM(t.transaction_amount),2) AS total_amount,
ROUND(AVG(t.transaction_amount),2) AS average_amount
FROM
    transactions t
    JOIN users u1 ON t.sender_id = u1.user_id
    JOIN users u2 ON t.recipient_id = u2.user_id
WHERE 
    YEAR(t.transaction_date)=2023
GROUP BY
     YEAR(t.transaction_date),
     MONTH(t.transaction_date),
     value_category,
     location_category
ORDER BY 
     transaction_year ASC,
     transaction_month ASC,
     value_category ASC,
     location_category ASC;
-- Average Amount--
SELECT m.merchant_id, m.business_name, 
ROUND(SUM(t.transaction_amount),2) AS total_received,
CASE WHEN ROUND(SUM(t.transaction_amount),2)>50000 THEN 'Excellent'
         WHEN ROUND(SUM(t.transaction_amount),2)>20000 AND ROUND(SUM(t.transaction_amount),2)<=50000 THEN 'Good'
         WHEN ROUND(SUM(t.transaction_amount),2)>10000 AND ROUND(SUM(t.transaction_amount),2)<=20000 THEN 'Average'
         WHEN ROUND(SUM(t.transaction_amount),2)<=10000 THEN 'Below Average'
         END AS performance_score,
ROUND(AVG(t.transaction_amount),2) AS average_transaction
FROM transactions t 
INNER JOIN merchants m 
ON t.recipient_id=m.merchant_id
WHERE t.transaction_date>= '2023-11-01' AND t.transaction_date< '2024-05-01'
GROUP BY m.merchant_id, m.business_name
ORDER BY total_received DESC;
-- Customer Engagement---
SELECT
    u.user_id,
    u.email
FROM
    users u
JOIN (
    SELECT
        t.sender_id,
        COUNT(DISTINCT DATE_FORMAT(t.transaction_date, '%Y-%m')) AS active_months
    FROM
        transactions t
    WHERE
        t.transaction_date >= '2023-05-01'
        AND t.transaction_date < '2024-05-01'
    GROUP BY
        t.sender_id
    HAVING
        active_months >= 6
) AS engaged_users
ON u.user_id = engaged_users.sender_id
ORDER BY
    u.user_id ASC;
-- Monthly_Transactions--
SELECT
    m.merchant_id,
    m.business_name,
    YEAR(t.transaction_date) AS transaction_year,
    MONTH(t.transaction_date) AS transaction_month,
    SUM(t.transaction_amount)AS total_transaction_amount,
    CASE
        WHEN SUM(t.transaction_amount) > 50000 THEN 'Exceeded $50,000'
        ELSE 'Did Not Exceed $50,000'
    END AS performance_status
FROM
    transactions t
JOIN
    merchants m ON t.recipient_id = m.merchant_id
WHERE
    t.transaction_date >= '2023-11-01'
    AND t.transaction_date < '2024-05-01'
GROUP BY
    m.merchant_id, m.business_name, YEAR(t.transaction_date), MONTH(t.transaction_date)
ORDER BY
    m.merchant_id ASC, transaction_year ASC, transaction_month ASC;