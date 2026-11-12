-- Banking Customer & Transaction Analytics
-- 04_create_analytics_tables.sql
-- Run in database: banking_analytics
-- Depends on public.bank_data, public.customer_data, public.transaction_data
-- Creates analysis-ready copies; source tables are not changed.
-- CREATE TABLE IF NOT EXISTS does not refresh an existing table.

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS analytics.customers_clean AS
SELECT
    customer_id,
    age,
    COALESCE(NULLIF(TRIM(customer_type), ''), 'Unknown') AS customer_type,
    COALESCE(NULLIF(TRIM(city), ''), 'Unknown') AS city,
    region,
    bank_name,
    branch_id,
    CASE
        WHEN age IS NULL
          OR NULLIF(TRIM(customer_type), '') IS NULL
          OR NULLIF(TRIM(city), '') IS NULL
        THEN TRUE ELSE FALSE
    END AS has_missing_profile_data
FROM public.customer_data;

CREATE TABLE IF NOT EXISTS analytics.transactions_clean AS
SELECT
    transaction_id,
    customer_id,
    account_type,
    total_balance,
    transaction_amount,
    investment_amount,
    investment_type,
    transaction_date,
    EXTRACT(YEAR FROM transaction_date)::INTEGER AS transaction_year,
    EXTRACT(MONTH FROM transaction_date)::INTEGER AS transaction_month,
    DATE_TRUNC('month', transaction_date)::DATE AS transaction_month_start
FROM public.transaction_data;

CREATE TABLE IF NOT EXISTS analytics.branches_clean AS
WITH branch_metrics AS (
    SELECT
        branch_id,
        city,
        region,
        firm_revenue,
        expenses,
        profit_margin AS reported_profit_margin,
        CASE
            WHEN firm_revenue IS NOT NULL AND expenses IS NOT NULL
            THEN firm_revenue - expenses ELSE NULL
        END AS calculated_profit,
        CASE
            WHEN firm_revenue IS NOT NULL
             AND firm_revenue <> 0
             AND expenses IS NOT NULL
            THEN (firm_revenue - expenses) / firm_revenue * 100
            ELSE NULL
        END AS calculated_profit_margin
    FROM public.bank_data
)
SELECT
    *,
    ABS(reported_profit_margin - calculated_profit_margin) AS margin_difference_pp,
    CASE
        WHEN reported_profit_margin IS NULL OR calculated_profit_margin IS NULL THEN NULL
        WHEN ABS(reported_profit_margin - calculated_profit_margin) > 1 THEN TRUE
        ELSE FALSE
    END AS has_margin_discrepancy
FROM branch_metrics;

-- Final row-count and relationship verification
SELECT
    (SELECT COUNT(*) FROM analytics.customers_clean) AS total_customers,
    (SELECT COUNT(*) FROM analytics.transactions_clean) AS total_transactions,
    (SELECT COUNT(*) FROM analytics.branches_clean) AS total_branches,
    (SELECT COUNT(*)
     FROM analytics.transactions_clean t
     LEFT JOIN analytics.customers_clean c ON c.customer_id = t.customer_id
     WHERE c.customer_id IS NULL) AS unmatched_transactions,
    (SELECT COUNT(*)
     FROM analytics.customers_clean c
     LEFT JOIN analytics.branches_clean b ON b.branch_id = c.branch_id
     WHERE b.branch_id IS NULL) AS unmatched_customers;

-- Branch integrity (expected: 1000, 50, 942, 8, 50)
SELECT
    COUNT(*) AS total_branch_records,
    COUNT(*) FILTER (WHERE firm_revenue IS NULL) AS missing_revenue,
    COUNT(*) FILTER (WHERE has_margin_discrepancy IS TRUE) AS flagged_margins,
    COUNT(*) FILTER (WHERE has_margin_discrepancy IS FALSE) AS within_tolerance,
    COUNT(*) FILTER (WHERE has_margin_discrepancy IS NULL) AS not_comparable
FROM analytics.branches_clean;

-- Note: these tables are materialized snapshots and do not automatically update
-- if source CSVs are reimported. Rebuild intentionally on fresh databases.
