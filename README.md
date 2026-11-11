# Banking Customer & Transaction Analytics Using PostgreSQL

## Project Overview

An end-to-end SQL analytics project using a synthetic banking dataset to investigate customer data quality, transaction activity, and financial performance indicators.

This project currently demonstrates SQL-based data validation, aggregation, and data-quality assessment using PostgreSQL. Upcoming phases will cover joins, CTEs, window functions, customer segmentation, and financial analytics.

## Tools and Technologies

- PostgreSQL 18
- pgAdmin 4
- SQL
- GitHub

## Dataset

The project uses three CSV datasets:

- `bank_data.csv` — 1,000 bank branch records
- `customer_data.csv` — 10,000 customer records
- `transaction_data.csv` — 10,000 transaction records

The dataset is synthetic and does not contain actual customer information.

## Project Objectives

1. Assess dataset quality and completeness.
2. Identify missing, duplicate, and unusual records.
3. Investigate customer and transaction relationships.
4. Analyze transaction patterns and financial metrics.
5. Produce reproducible SQL scripts and business insights.

## Current Progress

- [x] PostgreSQL database setup
- [x] Initial data import
- [x] Missing-value assessment
- [x] Duplicate customer ID checks
- [x] Customer age validation
- [x] Transaction amount validation
- [ ] Complete remaining data-quality checks
- [ ] Data cleaning and preparation
- [ ] Customer and transaction analysis
- [ ] Final business insights and visualizations

## Preliminary Findings

- 5% of customer ages are missing.
- 5% of customer city values are missing.
- 5% of customer type values are missing.
- No duplicate customer IDs were identified.
- No ages violated the selected 18–100 validation range.
- No zero, negative, or NULL transaction amounts were identified.

These are initial findings, not a comprehensive assessment of the dataset.

## Project Status

**In Progress — Data Quality Assessment**

Additional analytical findings, SQL scripts, and visualizations will be added as the project develops.