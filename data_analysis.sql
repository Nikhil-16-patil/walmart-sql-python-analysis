-- ================================================
-- WALMART SALES — SQL DATA ANALYSIS PROJECT
-- Tools: MySQL 8.0+, Python (pandas) for data cleaning
-- Dataset: 9,969 cleaned transactions (from 10,051 raw rows)
-- across 100 branches, 6 product categories, 2019-2023
-- ================================================

USE walmart_db;

-- Quick sanity checks after loading data
SELECT * FROM walmart_db.sales;

SELECT * FROM sales
LIMIT 5;

-- Safety check: ensure total is rounded even if re-imported without the Python rounding step
UPDATE sales
SET total = ROUND(total, 2);


-- ══════════════════════════════════════
-- 1. What is the total revenue generated?
-- ══════════════════════════════════════

SELECT
    ROUND(SUM(total), 2) AS total_revenue
FROM sales;


-- ══════════════════════════════════════
-- 2. Which branch generated the highest revenue?
-- ══════════════════════════════════════

SELECT
    Branch,
    ROUND(SUM(total), 2) AS total_revenue
FROM sales
GROUP BY Branch
ORDER BY total_revenue DESC;


-- ══════════════════════════════════════
-- 3. Which product category generated the highest revenue?
-- ══════════════════════════════════════

SELECT
    category,
    ROUND(SUM(total), 2) AS total_revenue
FROM sales
GROUP BY category
ORDER BY total_revenue DESC;


-- ══════════════════════════════════════
-- 4. What is the highest-rated category overall, and the lowest-rated?
-- ══════════════════════════════════════

SELECT
    category,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY category
ORDER BY avg_rating DESC;


-- ══════════════════════════════════════
-- 5. What payment method is used most frequently, and does it vary by city?
-- ══════════════════════════════════════

-- Overall
SELECT
    payment_method,
    COUNT(*) AS transaction_count
FROM sales
GROUP BY payment_method
ORDER BY transaction_count DESC;

-- By city
SELECT
    City,
    payment_method,
    COUNT(*) AS transaction_count
FROM sales
GROUP BY City, payment_method
ORDER BY City, transaction_count DESC;


-- ══════════════════════════════════════
-- 6. What is the busiest hour of the day for sales?
-- ══════════════════════════════════════

SELECT
    HOUR(time) AS hours_of_the_day,
    COUNT(*) AS num_transactions
FROM sales
GROUP BY hours_of_the_day
ORDER BY num_transactions DESC;


-- ══════════════════════════════════════
-- 7. What is the busiest day of the week?
-- ══════════════════════════════════════

SELECT
    DAYNAME(date) AS day,
    COUNT(*) AS busiest_day
FROM sales
GROUP BY day
ORDER BY busiest_day DESC;


-- ══════════════════════════════════════
-- 8. Which category has the highest average profit margin?
-- ══════════════════════════════════════

SELECT
    category,
    ROUND(AVG(profit_margin), 2) AS average_profit_margin
FROM sales
GROUP BY category
ORDER BY average_profit_margin DESC;


-- ══════════════════════════════════════
-- 9. What is the best-selling category in each branch?
-- ══════════════════════════════════════

WITH best_selling AS
(
    SELECT
        Branch,
        category,
        ROUND(SUM(total), 2) AS total_revenue
    FROM sales
    GROUP BY category, Branch
),
each_branch AS
(
    SELECT
        *,
        DENSE_RANK() OVER (PARTITION BY Branch ORDER BY total_revenue DESC) AS top_sales
    FROM best_selling
)
SELECT * FROM each_branch
WHERE top_sales = 1;


-- ══════════════════════════════════════
-- 10. Which branches have an average rating below the overall average?
-- ══════════════════════════════════════

SELECT
    Branch,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY Branch
HAVING avg_rating < (SELECT AVG(rating) FROM sales)
ORDER BY avg_rating;


-- ══════════════════════════════════════
-- 11. What is the revenue and profit contribution of each payment method?
-- (total * profit_margin as computed profit)
-- ══════════════════════════════════════

SELECT
    payment_method,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(SUM(total * profit_margin), 2) AS computed_profit,
    COUNT(*) AS transaction_count
FROM sales
GROUP BY payment_method
ORDER BY computed_profit DESC;


-- ══════════════════════════════════════
-- 12. How does revenue vary by time of day (Morning/Afternoon/Evening)?
-- (CASE WHEN bucketing on HOUR(time))
-- ══════════════════════════════════════

SELECT
    CASE
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_the_day,
    ROUND(SUM(total), 2) AS total_revenue,
    COUNT(*) AS total_orders
FROM sales
GROUP BY time_of_the_day
ORDER BY total_revenue DESC;


-- ══════════════════════════════════════
-- 13. Which city has the highest average transaction value (total)?
-- ══════════════════════════════════════

SELECT
    City,
    ROUND(AVG(total), 2) AS avg_transaction_value
FROM sales
GROUP BY City
ORDER BY avg_transaction_value DESC;


-- ══════════════════════════════════════
-- 14. What is the monthly revenue trend across all branches?
-- ══════════════════════════════════════
-- Note: dataset spans 2019-2023, so year is included to avoid
-- collapsing 5 years of data into the same 12 month buckets.

SELECT
    YEAR(date) AS year,
    MONTH(date) AS month,
    ROUND(SUM(total), 2) AS total_revenue,
    COUNT(*) AS total_orders
FROM sales
GROUP BY year, month
ORDER BY year, month;


-- ══════════════════════════════════════
-- 15. Which branch-category combination is the single most profitable pairing?
-- (total * profit_margin, ranked)
-- ══════════════════════════════════════

WITH profit_branch AS
(
    SELECT
        Branch,
        category,
        ROUND(SUM(total), 2) AS total_revenue,
        ROUND(SUM(total * profit_margin), 2) AS profit
    FROM sales
    GROUP BY Branch, category
),
branch_category AS
(
    SELECT
        *,
        RANK() OVER (ORDER BY profit DESC) AS combination
    FROM profit_branch
)
SELECT * FROM branch_category
WHERE combination = 1;