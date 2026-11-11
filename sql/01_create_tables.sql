-- ======================================================
-- Banking Customer & Transaction Analytics
-- File: 01_create_tables.sql
-- Database: banking_analytics
-- DBMS: PostgreSQL 18
--
-- Purpose:
-- Create staging tables for three banking CSV datasets.
-- These tables preserve raw values for data quality
-- assessment before cleaning and further analysis.
-- ======================================================

-- ======================================================
-- TABLE 1: BANK DATA
-- Contains bank branch and financial information
-- ======================================================

CREATE TABLE IF NOT EXISTS bank_data (
    branch_id INTEGER,
    city VARCHAR(100),
    region VARCHAR(50),
    firm_revenue NUMERIC(15, 2),
    expenses NUMERIC(15, 2),
    profit_margin NUMERIC(10, 2)
);

-- ======================================================
-- TABLE 2: CUSTOMER DATA
-- Contains customer profiles and branch associations
-- ======================================================

CREATE TABLE IF NOT EXISTS customer_data (
    customer_id INTEGER,
    age NUMERIC(5, 1),
    customer_type VARCHAR(50),
    city VARCHAR(100),
    region VARCHAR(50),
    bank_name VARCHAR(100),
    branch_id INTEGER
);

-- ======================================================
-- TABLE 3: TRANSACTION DATA
-- Contains customer transactions and investment data
-- ======================================================

CREATE TABLE IF NOT EXISTS transaction_data (
    transaction_id INTEGER,
    customer_id INTEGER,
    account_type VARCHAR(50),
    total_balance NUMERIC(15, 2),
    transaction_amount NUMERIC(20, 10),
    investment_amount NUMERIC(15, 2),
    investment_type VARCHAR(100),
    transaction_date DATE
);

-- ======================================================
-- VERIFY TABLE CREATION
-- ======================================================

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
      'bank_data',
      'customer_data',
      'transaction_data'
  )
ORDER BY table_name;

-- ======================================================
-- NOTES
-- ======================================================

-- 1. These are initial staging tables.
-- 2. Primary and foreign key constraints are not yet
--    enforced at this stage.
-- 3. Missing values are retained as NULL.
-- 4. No records are deleted or modified.
-- 5. Data validation will be documented separately.
-- 6. CSV data is imported after table creation.
-- ======================================================
