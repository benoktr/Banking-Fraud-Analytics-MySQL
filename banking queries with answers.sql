USE banking_fraud_analytics;
-- 50 ADVANCED SQL CHALLENGES
-- =========================================================

-- 01. Top 20 customers by successful transaction value.
-- 02. Calculate each customer's average transaction and compare it with the bank-wide average.
-- 03. Rank customers within each branch using DENSE_RANK().
-- 04. Find the top 3 customers in every branch.
-- 05. Calculate running transaction value for every account.
-- 06. Find the previous transaction amount for every account using LAG().
-- 07. Detect transactions occurring within 5 minutes for the same account.
-- 08. Detect same-customer transactions from different cities within 30 minutes.
-- 09. Find transactions more than 3x the customer's average successful transaction.
-- 10. Find customers with more than 10 failed transactions in 24 hours.
-- 11. Find accounts with transactions in 5+ cities.
-- 12. Calculate monthly transaction growth using LAG().
-- 13. Calculate each branch's percentage contribution to total transaction value.
-- 14. Find the branch with the highest average transaction value.
-- 15. Find the month with the highest successful transaction volume.
-- 16. Find customers with no successful transactions in the last 90 days.
-- 17. Calculate customer transaction percentiles using NTILE(10).
-- 18. Identify high-income customers with unusually low banking activity.
-- 19. Find customers with both loans and high fraud exposure.
-- 20. Calculate loan repayment completion percentage.
-- 21. Find loans with 3+ missed payments.
-- 22. Find loans where average days late exceeds 15.
-- 23. Rank branches by loan default rate.
-- 24. Find customers whose total loan principal exceeds 50% of annual income.
-- 25. Find the top loan type by branch.
-- 26. Calculate monthly loan collection.
-- 27. Detect repeated card declines followed by approval.
-- 28. Find high-risk merchants with unusually high transaction values.
-- 29. Calculate fraud confirmation rate by fraud type.
-- 30. Calculate average fraud risk score by merchant category.
-- 31. Find customers with 2+ fraud alerts in 30 days.
-- 32. Find open fraud alerts older than 7 days.
-- 33. Calculate false-positive rate of fraud alerts.
-- 34. Find customers with complaints and fraud alerts.
-- 35. Rank complaint categories by volume.
-- 36. Calculate average complaint resolution time by branch/customer.
-- 37. Find customers with critical complaints that remain unresolved.
-- 38. Build a customer risk score from transaction velocity, fraud alerts and loan lateness.
-- 39. Find dormant accounts with recent transaction attempts.
-- 40. Find accounts whose current balance is below their average daily withdrawal.
-- 41. Use EXPLAIN to compare an indexed vs non-indexed transaction query.
-- 42. Identify duplicate reference codes.
-- 43. Find transactions with amount anomalies using standard-deviation logic.
-- 44. Find consecutive-day transaction activity for customers.
-- 45. Find customers active in at least 6 distinct months.
-- 46. Find each customer's first and latest transaction.
-- 47. Calculate customer retention by signup cohort.
-- 48. Find merchants responsible for the highest confirmed fraud value.
-- 49. Create a view combining customer, account, transaction and fraud metrics.
-- 50. Optimize a multi-join fraud query and document the EXPLAIN plan.

 -- 01. Top 20 customers by successful transaction value.
USE banking_fraud_analytics;

SELECT 
    a.customer_id,
    SUM(t.amount) AS total_amount
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
WHERE t.status = 'Success'
GROUP BY a.customer_id
ORDER BY total_amount DESC
LIMIT 20;

-- 02. Calculate each customer's average transaction and compare it with the bank-wide average.

USE banking_fraud_analytics;

SELECT
    a.customer_id,
    ROUND(AVG(t.amount), 2) AS customer_average,
    ROUND((SELECT AVG(amount)
           FROM transactions
           WHERE status = 'Success'), 2) AS bank_average
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE t.status = 'Success'
GROUP BY a.customer_id;

-- 03. Rank customers within each branch using DENSE_RANK().

SELECT
    a.branch_id,
    a.customer_id,
    SUM(t.amount) AS total_amount,
    DENSE_RANK() OVER (
        PARTITION BY a.branch_id
        ORDER BY SUM(t.amount) DESC
    ) AS customer_rank
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
WHERE t.status = 'Success'
GROUP BY a.branch_id, a.customer_id;

-- 04. Find the top 3 customers in every branch.

SELECT *
FROM (
    SELECT
        a.branch_id,
        a.customer_id,
        SUM(t.amount) AS total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY a.branch_id
            ORDER BY SUM(t.amount) DESC
        ) AS rank_no
    FROM accounts a
    JOIN transactions t ON a.account_id = t.account_id
    WHERE t.status = 'Success'
    GROUP BY a.branch_id, a.customer_id
) x
WHERE rank_no <= 3;


-- 05. Calculate running transaction value for every account.

SELECT
    account_id,
    transaction_time,
    amount,
    SUM(amount) OVER (
        PARTITION BY account_id
        ORDER BY transaction_time
    ) AS running_total
FROM transactions
WHERE status = 'Success';


-- 06. Find the previous transaction amount for every account using LAG().

SELECT
    account_id,
    transaction_time,
    amount,
    LAG(amount) OVER (
        PARTITION BY account_id
        ORDER BY transaction_time
    ) AS previous_amount
FROM transactions;

-- 07. Detect transactions occurring within 5 minutes for the same account.


SELECT
    t1.account_id,
    t1.transaction_id,
    t2.transaction_id AS next_transaction,
    t1.transaction_time,
    t2.transaction_time
FROM transactions t1
JOIN transactions t2
    ON t1.account_id = t2.account_id
    AND t1.transaction_id < t2.transaction_id
WHERE TIMESTAMPDIFF(
        MINUTE,
        t1.transaction_time,
        t2.transaction_time
      ) <= 5;
      
      -- 08. Detect same-customer transactions from different cities within 30 minutes.


SELECT
    a1.customer_id,
    t1.city AS city1,
    t2.city AS city2,
    t1.transaction_time,
    t2.transaction_time
FROM transactions t1
JOIN accounts a1 ON t1.account_id = a1.account_id
JOIN transactions t2
    ON t1.transaction_id < t2.transaction_id
JOIN accounts a2
    ON t2.account_id = a2.account_id
    AND a1.customer_id = a2.customer_id
WHERE t1.city <> t2.city
AND TIMESTAMPDIFF(
    MINUTE,
    t1.transaction_time,
    t2.transaction_time
) <= 30
LIMIT 500;

-- 09. Find transactions more than 3x the customer's average successful transaction.


SELECT
    a.customer_id,
    t.transaction_id,
    t.amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE t.status = 'Success'
AND t.amount > (
    SELECT AVG(t2.amount) * 3
    FROM transactions t2
    JOIN accounts a2 ON t2.account_id = a2.account_id
    WHERE a2.customer_id = a.customer_id
    AND t2.status = 'Success'
);

-- 10. Find customers with more than 10 failed transactions in 24 hours.


SELECT
    a.customer_id,
    COUNT(*) AS failed_transactions
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE t.status = 'Failed'
GROUP BY a.customer_id
HAVING COUNT(*) > 10;

-- 11. Find accounts with transactions in 5+ cities.


SELECT
    account_id,
    COUNT(DISTINCT city) AS city_count
FROM transactions
GROUP BY account_id
HAVING COUNT(DISTINCT city) >= 5;

-- 12. Calculate monthly transaction growth using LAG().


WITH monthly AS (
    SELECT
        DATE_FORMAT(transaction_time, '%Y-%m') AS month,
        SUM(amount) AS total_amount
    FROM transactions
    WHERE status = 'Success'
    GROUP BY month
)
SELECT
    month,
    total_amount,
    LAG(total_amount) OVER (ORDER BY month) AS previous_month
FROM monthly;

-- 13. Calculate each branch's percentage contribution to total transaction value.


SELECT
    a.branch_id,
    SUM(t.amount) AS branch_amount,
    ROUND(
        SUM(t.amount) * 100 /
        (SELECT SUM(amount)
         FROM transactions
         WHERE status = 'Success'),
        2
    ) AS percentage
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
WHERE t.status = 'Success'
GROUP BY a.branch_id;

-- 14. Find the branch with the highest average transaction value.


SELECT
    a.branch_id,
    AVG(t.amount) AS average_amount
FROM accounts a
JOIN transactions t ON a.account_id = t.account_id
WHERE t.status = 'Success'
GROUP BY a.branch_id
ORDER BY average_amount DESC
LIMIT 1;

-- 15. Find the month with the highest successful transaction volume.


SELECT
    DATE_FORMAT(transaction_time, '%Y-%m') AS month,
    SUM(amount) AS total_amount
FROM transactions
WHERE status = 'Success'
GROUP BY month
ORDER BY total_amount DESC
LIMIT 1;

-- 16. Find customers with no successful transactions in the last 90 days.


SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM accounts a
    JOIN transactions t ON a.account_id = t.account_id
    WHERE a.customer_id = c.customer_id
    AND t.status = 'Success'
    AND t.transaction_time >= (
        SELECT MAX(transaction_time)
        FROM transactions
    ) - INTERVAL 90 DAY
);

-- 17. Calculate customer transaction percentiles using NTILE(10).


SELECT
    customer_id,
    total_amount,
    NTILE(10) OVER (
        ORDER BY total_amount DESC
    ) AS percentile_group
FROM (
    SELECT
        a.customer_id,
        SUM(t.amount) AS total_amount
    FROM accounts a
    JOIN transactions t ON a.account_id = t.account_id
    WHERE t.status = 'Success'
    GROUP BY a.customer_id
) x;

-- 18. Identify high-income customers with unusually low banking activity.


SELECT
    c.customer_id,
    c.annual_income,
    COUNT(t.transaction_id) AS transaction_count
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.customer_id, c.annual_income
HAVING c.annual_income > 1000000
AND COUNT(t.transaction_id) < 10;

-- 19. Find customers with both loans and high fraud exposure.


SELECT
    l.customer_id,
    COUNT(DISTINCT l.loan_id) AS loans,
    COUNT(DISTINCT f.alert_id) AS fraud_alerts
FROM loans l
JOIN accounts a ON l.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
JOIN fraud_alerts f ON t.transaction_id = f.transaction_id
GROUP BY l.customer_id
HAVING COUNT(DISTINCT f.alert_id) >= 2;

-- 20. Calculate loan repayment completion percentage.


SELECT
    loan_id,
    ROUND(
        SUM(paid_amount) * 100 / SUM(due_amount),
        2
    ) AS repayment_percentage
FROM loan_payments
GROUP BY loan_id;

-- 21. Find loans with 3+ missed payments.

SELECT
    loan_id,
    COUNT(*) AS missed_payments
FROM loan_payments
WHERE payment_status = 'Missed'
GROUP BY loan_id
HAVING COUNT(*) >= 3;

-- 22. Find loans where average days late exceeds 15.


SELECT
    loan_id,
    AVG(days_late) AS average_days_late
FROM loan_payments
GROUP BY loan_id
HAVING AVG(days_late) > 15;

-- 23. Rank branches by loan default rate.

SELECT
    branch_id,
    ROUND(
        SUM(loan_status = 'Defaulted') * 100 / COUNT(*),
        2
    ) AS default_rate,
    DENSE_RANK() OVER (
        ORDER BY SUM(loan_status = 'Defaulted') / COUNT(*) DESC
    ) AS branch_rank
FROM loans
GROUP BY branch_id;

-- 24. Find customers whose total loan principal exceeds 50% of annual income.

SELECT
    c.customer_id,
    c.annual_income,
    SUM(l.principal_amount) AS total_loan
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.annual_income
HAVING SUM(l.principal_amount) > c.annual_income * 0.50;

-- 25. Find the top loan type by branch.

SELECT
    branch_id,
    loan_type,
    COUNT(*) AS loan_count
FROM loans
GROUP BY branch_id, loan_type
ORDER BY branch_id, loan_count DESC;

-- 26. Calculate monthly loan collection.

SELECT
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    SUM(paid_amount) AS total_collection
FROM loan_payments
GROUP BY month
ORDER BY month;

-- 27. Detect repeated card declines followed by approval.

SELECT
    c1.account_id,
    c1.transaction_time AS declined_time,
    c2.transaction_time AS approved_time
FROM card_transactions c1
JOIN card_transactions c2
    ON c1.account_id = c2.account_id
    AND c1.card_transaction_id < c2.card_transaction_id
WHERE c1.status = 'Declined'
AND c2.status = 'Approved'
AND TIMESTAMPDIFF(
    MINUTE,
    c1.transaction_time,
    c2.transaction_time
) <= 30;

-- 28. Find high-risk merchants with unusually high transaction values.

SELECT
    m.merchant_id,
    m.merchant_name,
    m.risk_level,
    SUM(t.amount) AS total_amount
FROM merchants m
JOIN transactions t ON m.merchant_id = t.merchant_id
WHERE m.risk_level = 'High'
GROUP BY m.merchant_id, m.merchant_name, m.risk_level
ORDER BY total_amount DESC;

-- 29. Calculate fraud confirmation rate by fraud type.

SELECT
    fraud_type,
    COUNT(*) AS total_alerts,
    SUM(alert_status = 'Confirmed') AS confirmed,
    ROUND(
        SUM(alert_status = 'Confirmed') * 100 / COUNT(*),
        2
    ) AS confirmation_rate
FROM fraud_alerts
GROUP BY fraud_type;

-- 30. Calculate average fraud risk score by merchant category.

SELECT
    m.merchant_category,
    AVG(f.risk_score) AS average_risk_score
FROM fraud_alerts f
JOIN transactions t ON f.transaction_id = t.transaction_id
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_category
ORDER BY average_risk_score DESC;

-- 31. Find customers with 2+ fraud alerts in 30 days.

SELECT
    a.customer_id,
    COUNT(f.alert_id) AS fraud_alerts
FROM fraud_alerts f
JOIN transactions t ON f.transaction_id = t.transaction_id
JOIN accounts a ON t.account_id = a.account_id
WHERE f.alert_time >= (
    SELECT MAX(alert_time)
    FROM fraud_alerts
) - INTERVAL 30 DAY
GROUP BY a.customer_id
HAVING COUNT(f.alert_id) >= 2;

-- 32. Find open fraud alerts older than 7 days.

SELECT *
FROM fraud_alerts
WHERE alert_status = 'Open'
AND alert_time < (
    SELECT MAX(alert_time)
    FROM fraud_alerts
) - INTERVAL 7 DAY;

-- 33. Calculate false-positive rate of fraud alerts.

SELECT
    ROUND(
        SUM(alert_status = 'False Positive') * 100 / COUNT(*),
        2
    ) AS false_positive_rate
FROM fraud_alerts;

-- 34. Find customers with complaints and fraud alerts.

SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customers c
JOIN customer_complaints cc
    ON c.customer_id = cc.customer_id
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
JOIN fraud_alerts f
    ON t.transaction_id = f.transaction_id;

-- 35. Rank complaint categories by volume.

SELECT
    category,
    COUNT(*) AS complaint_count,
    DENSE_RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS category_rank
FROM customer_complaints
GROUP BY category;

-- 36. Calculate average complaint resolution time by branch/customer.

SELECT
    AVG(resolution_days) AS average_resolution_days
FROM customer_complaints
WHERE resolution_days IS NOT NULL;

SELECT
    category,
    AVG(resolution_days) AS average_days
FROM customer_complaints
WHERE resolution_days IS NOT NULL
GROUP BY category;

-- 37. Find customers with critical complaints that remain unresolved.

SELECT
    complaint_id,
    customer_id,
    category,
    status
FROM customer_complaints
WHERE priority = 'Critical'
AND status NOT IN ('Resolved', 'Closed');

-- 38. Build a customer risk score from transaction velocity, fraud alerts and loan lateness.

SELECT
    c.customer_id,

    COUNT(DISTINCT f.alert_id) AS fraud_alerts,

    COUNT(DISTINCT t.transaction_id) AS transactions,

    AVG(lp.days_late) AS average_days_late,

    (
        COUNT(DISTINCT f.alert_id) * 30
        +
        CASE
            WHEN AVG(lp.days_late) > 15 THEN 30
            ELSE 0
        END
        +
        CASE
            WHEN COUNT(DISTINCT t.transaction_id) > 1000 THEN 20
            ELSE 0
        END
    ) AS risk_score

FROM customers c

LEFT JOIN accounts a
    ON c.customer_id = a.customer_id

LEFT JOIN transactions t
    ON a.account_id = t.account_id

LEFT JOIN fraud_alerts f
    ON t.transaction_id = f.transaction_id

LEFT JOIN loans l
    ON c.customer_id = l.customer_id

LEFT JOIN loan_payments lp
    ON l.loan_id = lp.loan_id

GROUP BY c.customer_id;

-- 39. Find dormant accounts with recent transaction attempts.

SELECT
    a.account_id,
    a.customer_id,
    a.status,
    MAX(t.transaction_time) AS latest_transaction
FROM accounts a
JOIN transactions t
    ON a.account_id = t.account_id
WHERE a.status = 'Dormant'
GROUP BY a.account_id, a.customer_id, a.status
HAVING MAX(t.transaction_time) >= (
    SELECT MAX(transaction_time)
    FROM transactions
) - INTERVAL 30 DAY;

-- 40. Find accounts whose current balance is below their average daily withdrawal.

SELECT
    a.account_id,
    a.current_balance,
    AVG(t.amount) AS average_withdrawal
FROM accounts a
JOIN transactions t
    ON a.account_id = t.account_id
WHERE t.transaction_type = 'Withdrawal'
GROUP BY a.account_id, a.current_balance
HAVING a.current_balance < AVG(t.amount);

-- 41. Use EXPLAIN to compare an indexed vs non-indexed transaction query.
-- Indexed-style query
EXPLAIN
SELECT *
FROM transactions
WHERE account_id = 1000;

-- Non-index-friendly query

EXPLAIN
SELECT *
FROM transactions
WHERE YEAR(transaction_time) = 2025;

-- 42. Identify duplicate reference codes.

SELECT
    reference_code,
    COUNT(*) AS duplicate_count
FROM transactions
GROUP BY reference_code
HAVING COUNT(*) > 1;

-- 43. Find transactions with amount anomalies using standard-deviation logic.

SELECT
    transaction_id,
    account_id,
    amount
FROM transactions
WHERE amount >
(
    SELECT AVG(amount) + 3 * STDDEV_POP(amount)
    FROM transactions
);

-- 44. Find consecutive-day transaction activity for customers.

SELECT DISTINCT
    a.customer_id,
    DATE(t1.transaction_time) AS day1,
    DATE(t2.transaction_time) AS day2
FROM transactions t1
JOIN transactions t2
    ON t1.account_id = t2.account_id
JOIN accounts a
    ON t1.account_id = a.account_id
WHERE DATE(t2.transaction_time)
      = DATE(t1.transaction_time) + INTERVAL 1 DAY;
      
    -- 45. Find customers active in at least 6 distinct months.
  
      
      SELECT
    a.customer_id,
    COUNT(
        DISTINCT DATE_FORMAT(t.transaction_time, '%Y-%m')
    ) AS active_months
FROM accounts a
JOIN transactions t
    ON a.account_id = t.account_id
WHERE t.status = 'Success'
GROUP BY a.customer_id
HAVING active_months >= 6;

-- 46. Find each customer's first and latest transaction.


SELECT
    a.customer_id,
    MIN(t.transaction_time) AS first_transaction,
    MAX(t.transaction_time) AS latest_transaction
FROM accounts a
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY a.customer_id;

-- 47. Calculate customer retention by signup cohort.


SELECT
    DATE_FORMAT(c.customer_since, '%Y-%m') AS signup_month,
    COUNT(DISTINCT c.customer_id) AS customers
FROM customers c
GROUP BY signup_month
ORDER BY signup_month;

-- 48. Find merchants responsible for the highest confirmed fraud value.


SELECT
    m.merchant_id,
    m.merchant_name,
    SUM(t.amount) AS fraud_value
FROM fraud_alerts f
JOIN transactions t
    ON f.transaction_id = t.transaction_id
JOIN merchants m
    ON t.merchant_id = m.merchant_id
WHERE f.alert_status = 'Confirmed'
GROUP BY m.merchant_id, m.merchant_name
ORDER BY fraud_value DESC
LIMIT 20;

-- 49. Create a view combining customer, account, transaction and fraud metrics.


CREATE OR REPLACE VIEW customer_risk_summary AS

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.annual_income,
    c.risk_category,

    COUNT(DISTINCT a.account_id) AS accounts,

    COUNT(DISTINCT t.transaction_id) AS transactions,

    COALESCE(SUM(t.amount), 0) AS transaction_value,

    COUNT(DISTINCT f.alert_id) AS fraud_alerts

FROM customers c

LEFT JOIN accounts a
    ON c.customer_id = a.customer_id

LEFT JOIN transactions t
    ON a.account_id = t.account_id

LEFT JOIN fraud_alerts f
    ON t.transaction_id = f.transaction_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.annual_income,
    c.risk_category;
    
    SELECT *
FROM customer_risk_summary
LIMIT 20;
    -- 50. Optimize a multi-join fraud query and document the EXPLAIN plan.

    
    EXPLAIN
SELECT
    a.customer_id,
    f.alert_id,
    f.risk_score,
    t.amount
FROM fraud_alerts f
JOIN transactions t
    ON f.transaction_id = t.transaction_id
JOIN accounts a
    ON t.account_id = a.account_id
WHERE f.risk_score > 80
AND t.status = 'Success';

SHOW INDEX FROM fraud_alerts;
SHOW INDEX FROM transactions;
SHOW INDEX FROM accounts;
EXPLAIN ANALYZE
SELECT
    a.customer_id,
    f.alert_id,
    f.risk_score,
    t.amount
FROM fraud_alerts f
JOIN transactions t
    ON f.transaction_id = t.transaction_id
JOIN accounts a
    ON t.account_id = a.account_id
WHERE f.risk_score > 80
AND t.status = 'Success';