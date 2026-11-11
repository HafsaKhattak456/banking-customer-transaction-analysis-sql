-- Banking Customer & Transaction Analytics
-- Data Quality Assessment
-- Database: banking_analytics

-- Check 1: Missing customer values

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) - COUNT(age) AS missing_age,
    COUNT(*) - COUNT(customer_type) AS missing_customer_type,
    COUNT(*) - COUNT(city) AS missing_city
FROM customer_data;


-- Check 2: Duplicate customer IDs

SELECT
    customer_id,
    COUNT(*) AS occurrences
FROM customer_data
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- Check 3: Invalid customer ages
-- Project validation range: 18 to 100

SELECT customer_id, age
FROM customer_data
WHERE age IS NOT NULL
  AND (age < 18 OR age > 100)
ORDER BY age DESC;


-- Check 4: Nonpositive or missing transactions

SELECT
    transaction_id,
    customer_id,
    transaction_amount
FROM transaction_data
WHERE transaction_amount <= 0
   OR transaction_amount IS NULL
ORDER BY transaction_amount ASC NULLS LAST;