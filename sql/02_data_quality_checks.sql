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


-- CHECK 5: Missing-value overlap across three customer attributes
SELECT COUNT(*) AS total_customers,
       COUNT(*) FILTER (WHERE age IS NULL OR customer_type IS NULL OR city IS NULL) AS customers_with_any_missing,
       COUNT(*) FILTER (WHERE age IS NULL AND customer_type IS NULL AND city IS NULL) AS customers_with_all_missing,
       COUNT(*) FILTER (WHERE age IS NOT NULL AND customer_type IS NOT NULL AND city IS NOT NULL) AS complete_customers
FROM customer_data;

-- CHECK 6: Repeated transaction IDs
SELECT transaction_id, COUNT(*) AS occurrences
FROM transaction_data
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- CHECK 7: Missing or future-dated transactions
SELECT transaction_id, customer_id, transaction_date
FROM transaction_data
WHERE transaction_date IS NULL OR transaction_date > CURRENT_DATE
ORDER BY transaction_date DESC NULLS LAST;

-- CHECK 8: Transactions without matching customer records
SELECT t.transaction_id, t.customer_id
FROM transaction_data t
LEFT JOIN customer_data c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL
ORDER BY t.transaction_id;

-- CHECK 9: Customers without matching bank branches
SELECT c.customer_id, c.branch_id
FROM customer_data c
LEFT JOIN bank_data b ON c.branch_id = b.branch_id
WHERE b.branch_id IS NULL
ORDER BY c.customer_id;

-- CHECK 10: Missing branch financial values
SELECT COUNT(*) AS total_branches,
       COUNT(*) - COUNT(firm_revenue) AS missing_revenue,
       COUNT(*) - COUNT(expenses) AS missing_expenses,
       COUNT(*) - COUNT(profit_margin) AS missing_profit_margin
FROM bank_data;

-- Financial margin checks below use an ASSUMED formula:
-- (revenue - expenses) / revenue * 100, and an ASSUMED percent scale.
-- These discrepancies are investigation flags, NOT confirmed source errors.

-- CHECK 11: Calculated vs reported profit margins (eligible records)
SELECT branch_id, firm_revenue, expenses, profit_margin,
       (firm_revenue - expenses) / NULLIF(firm_revenue, 0) * 100 AS calculated_profit_margin
FROM bank_data
WHERE firm_revenue IS NOT NULL AND firm_revenue <> 0
  AND expenses IS NOT NULL AND profit_margin IS NOT NULL
ORDER BY branch_id;

-- CHECK 12: Branches with discrepancies above 1 percentage point
WITH margin_analysis AS (
    SELECT branch_id, firm_revenue, expenses, profit_margin,
           (firm_revenue - expenses) / NULLIF(firm_revenue, 0) * 100 AS calculated_profit_margin
    FROM bank_data
    WHERE firm_revenue IS NOT NULL AND firm_revenue <> 0
      AND expenses IS NOT NULL AND profit_margin IS NOT NULL
)
SELECT branch_id, firm_revenue, expenses, profit_margin, calculated_profit_margin,
       ABS(calculated_profit_margin - profit_margin) AS margin_difference
FROM margin_analysis
WHERE ABS(calculated_profit_margin - profit_margin) > 1
ORDER BY margin_difference DESC;

-- CHECK 13: Compare reported and calculated margin distributions on same rows
SELECT MIN(profit_margin) AS min_reported_margin,
       MAX(profit_margin) AS max_reported_margin,
       AVG(profit_margin) AS avg_reported_margin,
       MIN((firm_revenue - expenses) / NULLIF(firm_revenue, 0) * 100) AS min_calculated_margin,
       MAX((firm_revenue - expenses) / NULLIF(firm_revenue, 0) * 100) AS max_calculated_margin,
       AVG((firm_revenue - expenses) / NULLIF(firm_revenue, 0) * 100) AS avg_calculated_margin
FROM bank_data
WHERE firm_revenue IS NOT NULL AND firm_revenue <> 0
  AND expenses IS NOT NULL AND profit_margin IS NOT NULL;

-- CHECK 14: Ten largest margin discrepancies, irrespective of threshold
WITH margin_analysis AS (
    SELECT branch_id, city, region, firm_revenue, expenses, profit_margin,
           (firm_revenue - expenses) / NULLIF(firm_revenue, 0) * 100 AS calculated_profit_margin
    FROM bank_data
    WHERE firm_revenue IS NOT NULL AND firm_revenue <> 0
      AND expenses IS NOT NULL AND profit_margin IS NOT NULL
)
SELECT branch_id, city, region, firm_revenue, expenses, profit_margin,
       calculated_profit_margin,
       ABS(calculated_profit_margin - profit_margin) AS margin_difference
FROM margin_analysis
ORDER BY margin_difference DESC, branch_id
LIMIT 10;
