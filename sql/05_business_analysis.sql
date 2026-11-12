-- Banking Customer & Transaction Analytics
-- 05_business_analysis.sql
-- Run after 04_create_analytics_tables.sql in database banking_analytics.
-- Each query can be executed separately in pgAdmin.
-- Monetary currency not verified; totals describe synthetic records.

-- ANALYSIS 1: Average balance by account type (transaction-ROW level).
-- Does NOT measure unique accounts or customer-level deposit balances.
SELECT
    account_type,
    COUNT(*) AS transaction_records,
    ROUND(AVG(total_balance), 2) AS average_balance,
    ROUND(MIN(total_balance), 2) AS minimum_balance,
    ROUND(MAX(total_balance), 2) AS maximum_balance
FROM analytics.transactions_clean
WHERE account_type IS NOT NULL AND total_balance IS NOT NULL
GROUP BY account_type
ORDER BY average_balance DESC;

-- ANALYSIS 2: Customer-type segmentation for customers with transactions.
-- INNER JOIN excludes customers without transactions in this dataset.
SELECT
    c.customer_type,
    COUNT(DISTINCT c.customer_id) AS unique_customers,
    COUNT(t.transaction_id) AS transaction_count,
    ROUND(AVG(t.transaction_amount), 2) AS average_transaction_amount,
    ROUND(AVG(t.total_balance), 2) AS average_recorded_balance
FROM analytics.customers_clean c
JOIN analytics.transactions_clean t ON t.customer_id = c.customer_id
GROUP BY c.customer_type
ORDER BY average_transaction_amount DESC;

-- Additional coverage check: customers with no observed transactions.
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE tx.customer_id IS NULL) AS customers_without_transactions,
    COUNT(*) FILTER (WHERE tx.customer_id IS NOT NULL) AS customers_with_transactions
FROM analytics.customers_clean c
LEFT JOIN (
    SELECT DISTINCT customer_id FROM analytics.transactions_clean
) tx ON tx.customer_id = c.customer_id;

-- ANALYSIS 3: Monthly transaction activity.
-- March 2022 (starts 21st) and March 2025 (ends 20th) are partial months.
SELECT
    transaction_month_start,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount), 2) AS total_transaction_value,
    ROUND(AVG(transaction_amount), 2) AS average_transaction_amount
FROM analytics.transactions_clean
GROUP BY transaction_month_start
ORDER BY transaction_month_start ASC;

-- ANALYSIS 4: Investment categories (sums of transaction-record values).
-- The source does not establish whether investments are flows or balances.
SELECT
    investment_type,
    COUNT(*) AS transaction_records,
    ROUND(SUM(investment_amount), 2) AS total_recorded_investment_amount,
    ROUND(AVG(investment_amount), 2) AS average_investment_amount,
    ROUND(MIN(investment_amount), 2) AS minimum_investment_amount,
    ROUND(MAX(investment_amount), 2) AS maximum_investment_amount
FROM analytics.transactions_clean
WHERE investment_type IS NOT NULL AND investment_amount IS NOT NULL
GROUP BY investment_type
ORDER BY total_recorded_investment_amount DESC;

-- ANALYSIS 5: Regional financial totals over comparable records.
-- This excludes branches with missing revenue from calculated profit/expenses.
SELECT
    region,
    COUNT(*) AS total_branch_records,
    COUNT(*) FILTER (WHERE calculated_profit IS NOT NULL) AS branches_with_financial_data,
    COUNT(*) FILTER (WHERE firm_revenue IS NULL) AS branches_missing_revenue,
    ROUND(SUM(firm_revenue), 2) AS total_recorded_revenue,
    ROUND(SUM(expenses) FILTER (WHERE calculated_profit IS NOT NULL), 2)
        AS comparable_expenses,
    ROUND(SUM(calculated_profit), 2) AS total_calculated_profit,
    COUNT(*) FILTER (WHERE calculated_profit < 0) AS calculated_loss_branches
FROM analytics.branches_clean
GROUP BY region
ORDER BY total_calculated_profit DESC;

-- ANALYSIS 6: Normalized regional profitability.
-- Aggregate margin = SUM(comparable profit) / SUM(comparable revenue).
-- This is NOT the average of the individual branch margins.
SELECT
    region,
    COUNT(*) FILTER (WHERE calculated_profit IS NOT NULL) AS comparable_branches,
    ROUND(AVG(calculated_profit), 2) AS average_calculated_profit_per_branch,
    ROUND(
        SUM(calculated_profit)
        / NULLIF(SUM(firm_revenue) FILTER (WHERE calculated_profit IS NOT NULL), 0)
        * 100, 2
    ) AS aggregate_calculated_margin_pct,
    ROUND(
        COUNT(*) FILTER (WHERE calculated_profit < 0) * 100.0
        / NULLIF(COUNT(*) FILTER (WHERE calculated_profit IS NOT NULL), 0), 2
    ) AS calculated_loss_branch_pct
FROM analytics.branches_clean
GROUP BY region
ORDER BY average_calculated_profit_per_branch DESC;
