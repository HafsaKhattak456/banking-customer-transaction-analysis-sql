-- Banking Customer & Transaction Analytics
-- Remaining data-quality assessment (Checks 15-22)
-- PostgreSQL 18 | Database: banking_analytics
-- Read-only: this script does not alter source tables.
-- Run after importing bank_data, customer_data and transaction_data.
-- Assumption for financial comparisons: profit_margin is a percentage
-- calculated as (firm_revenue - expenses) / firm_revenue * 100.
-- This source definition has NOT been verified. Treat discrepancies as
-- investigation flags, not confirmed errors.

-- CHECK 15: Financial outcome counts (rows, not necessarily unique branches)
SELECT
    COUNT(*) AS eligible_branch_records,
    COUNT(*) FILTER (WHERE expenses > firm_revenue) AS calculated_loss_records,
    COUNT(*) FILTER (WHERE firm_revenue > expenses) AS calculated_profit_records,
    COUNT(*) FILTER (WHERE firm_revenue = expenses) AS calculated_break_even_records
FROM bank_data
WHERE firm_revenue IS NOT NULL AND expenses IS NOT NULL;

-- CHECK 16: Summary of recorded vs calculated profit-margin discrepancies
WITH eligible AS (
    SELECT branch_id, city, region, firm_revenue, expenses, profit_margin,
           (firm_revenue - expenses) / NULLIF(firm_revenue, 0) * 100 AS calculated_margin
    FROM bank_data
    WHERE firm_revenue IS NOT NULL AND firm_revenue <> 0
      AND expenses IS NOT NULL AND profit_margin IS NOT NULL
), differences AS (
    SELECT *, ABS(profit_margin - calculated_margin) AS difference_pp
    FROM eligible
)
SELECT
    COUNT(*) AS eligible_records,
    COUNT(*) FILTER (WHERE difference_pp > 1) AS flagged_over_one_pp,
    COUNT(*) FILTER (WHERE difference_pp <= 1) AS within_one_pp,
    ROUND(100.0 * COUNT(*) FILTER (WHERE difference_pp > 1) / NULLIF(COUNT(*),0), 2) AS flagged_pct,
    ROUND(AVG(difference_pp), 2) AS mean_abs_difference_pp,
    ROUND(MAX(difference_pp), 2) AS max_difference_pp,
    COUNT(*) FILTER (WHERE calculated_margin < 0 AND profit_margin > 0)
        AS calculated_loss_but_reported_positive
FROM differences;

-- CHECK 17: Record identifier completeness and uniqueness
-- Duplicate non-NULL IDs are counted separately from missing IDs.
SELECT 'bank_data.branch_id' AS identifier,
       COUNT(*) AS row_count,
       COUNT(*) FILTER (WHERE branch_id IS NULL) AS missing_ids,
       COUNT(branch_id) - COUNT(DISTINCT branch_id) AS extra_repeated_nonnull_ids
FROM bank_data
UNION ALL
SELECT 'customer_data.customer_id', COUNT(*),
       COUNT(*) FILTER (WHERE customer_id IS NULL),
       COUNT(customer_id) - COUNT(DISTINCT customer_id)
FROM customer_data
UNION ALL
SELECT 'transaction_data.transaction_id', COUNT(*),
       COUNT(*) FILTER (WHERE transaction_id IS NULL),
       COUNT(transaction_id) - COUNT(DISTINCT transaction_id)
FROM transaction_data;

-- CHECK 18: Customer and transaction foreign-key consistency
-- The nullable left-side keys are explicitly identified and counted.
SELECT
    (SELECT COUNT(*) FROM customer_data WHERE branch_id IS NULL) AS customers_missing_branch_id,
    (SELECT COUNT(*) FROM transaction_data WHERE customer_id IS NULL) AS transactions_missing_customer_id,
    (SELECT COUNT(*)
     FROM customer_data c
     WHERE c.branch_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM bank_data b WHERE b.branch_id = c.branch_id))
       AS customers_unmatched_branch_id,
    (SELECT COUNT(*)
     FROM transaction_data t
     WHERE t.customer_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM customer_data c WHERE c.customer_id = t.customer_id))
       AS transactions_unmatched_customer_id;

-- CHECK 19: Completeness of all transaction attributes
SELECT
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (WHERE account_type IS NULL OR BTRIM(account_type) = '') AS missing_account_type,
    COUNT(*) FILTER (WHERE total_balance IS NULL) AS missing_total_balance,
    COUNT(*) FILTER (WHERE transaction_amount IS NULL) AS missing_transaction_amount,
    COUNT(*) FILTER (WHERE investment_amount IS NULL) AS missing_investment_amount,
    COUNT(*) FILTER (WHERE investment_type IS NULL OR BTRIM(investment_type) = '') AS missing_investment_type,
    COUNT(*) FILTER (WHERE transaction_date IS NULL) AS missing_transaction_date
FROM transaction_data;

-- CHECK 20: Unusual values and plausible ranges for transaction figures
-- Negative balances and investment amounts can be legitimate: review, don't delete.
SELECT
    COUNT(*) FILTER (WHERE total_balance < 0) AS negative_balances,
    COUNT(*) FILTER (WHERE investment_amount < 0) AS negative_investments,
    COUNT(*) FILTER (WHERE transaction_amount <= 0) AS nonpositive_transaction_amounts,
    COUNT(*) FILTER (WHERE transaction_date > CURRENT_DATE) AS future_dated_transactions,
    MIN(transaction_date) AS earliest_transaction_date,
    MAX(transaction_date) AS latest_transaction_date,
    MIN(transaction_amount) AS smallest_transaction_amount,
    MAX(transaction_amount) AS largest_transaction_amount,
    MIN(total_balance) AS smallest_total_balance,
    MAX(total_balance) AS largest_total_balance
FROM transaction_data;

-- CHECK 21: Customer and branch text-field quality
SELECT
    (SELECT COUNT(*) FROM customer_data WHERE city IS NOT NULL AND BTRIM(city) = '') AS blank_customer_city,
    (SELECT COUNT(*) FROM customer_data WHERE customer_type IS NOT NULL AND BTRIM(customer_type) = '') AS blank_customer_type,
    (SELECT COUNT(*) FROM customer_data WHERE region IS NULL OR BTRIM(region) = '') AS missing_customer_region,
    (SELECT COUNT(*) FROM bank_data WHERE city IS NULL OR BTRIM(city) = '') AS missing_branch_city,
    (SELECT COUNT(*) FROM bank_data WHERE region IS NULL OR BTRIM(region) = '') AS missing_branch_region;

-- CHECK 22: City/region differences between customers and referenced branches
-- These differences are flags only: customer's home city may differ from branch city.
-- Compare only where both values are present; trim/case-normalize for comparison.
SELECT
    COUNT(*) AS comparable_customer_branch_rows,
    COUNT(*) FILTER (
        WHERE c.city IS NOT NULL AND b.city IS NOT NULL
          AND LOWER(BTRIM(c.city)) <> LOWER(BTRIM(b.city))
    ) AS customer_branch_city_differences,
    COUNT(*) FILTER (
        WHERE c.region IS NOT NULL AND b.region IS NOT NULL
          AND LOWER(BTRIM(c.region)) <> LOWER(BTRIM(b.region))
    ) AS customer_branch_region_differences
FROM customer_data c
JOIN bank_data b ON c.branch_id = b.branch_id;

-- OPTIONAL SPOT CHECK: Inspect 10 largest computed margin discrepancies
WITH eligible AS (
    SELECT branch_id, city, region, firm_revenue, expenses, profit_margin,
           (firm_revenue - expenses) / NULLIF(firm_revenue, 0) * 100 AS calculated_margin
    FROM bank_data
    WHERE firm_revenue IS NOT NULL AND firm_revenue <> 0
      AND expenses IS NOT NULL AND profit_margin IS NOT NULL
)
SELECT branch_id, city, region, firm_revenue, expenses, profit_margin,
       ROUND(calculated_margin, 2) AS calculated_margin,
       ROUND(ABS(profit_margin - calculated_margin), 2) AS difference_pp
FROM eligible
ORDER BY ABS(profit_margin - calculated_margin) DESC, branch_id
LIMIT 10;
