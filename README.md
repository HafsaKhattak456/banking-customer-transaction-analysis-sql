# Banking Customer & Transaction Analytics Using PostgreSQL

## Project Overview

An end-to-end SQL analytics project using a synthetic banking dataset to investigate customer data quality, transaction activity, and financial performance indicators.

This project currently demonstrates SQL-based data validation, aggregation, and data-quality assessment using PostgreSQL. The completed data-quality phase also applies joins, CTEs, conditional aggregation, and financial metric reconciliation. Upcoming phases will focus on data preparation, business analysis, and window functions.

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
- [x] Complete planned data-quality checks
- [ ] Data cleaning and preparation
- [ ] Customer and transaction analysis
- [ ] Final business insights and visualizations

## Data Quality Findings

- 5% of customer ages are missing.
- 5% of customer city values are missing.
- 5% of customer type values are missing.
- No duplicate customer IDs were identified.
- No ages violated the selected 18–100 validation range.
- No zero, negative, or NULL transaction amounts were identified.

- 1,420 customer records (14.2%) are missing at least one of age, city, or customer type; 8,580 are complete across these attributes.
- No missing or repeated branch, customer, or transaction identifiers were found.
- No missing or unmatched customer–branch or transaction–customer reference IDs were found.
- 50 of 1,000 branch records have missing revenue.
- Among 950 eligible branch records, 942 (99.16%) differ by more than 1 percentage point between recorded profit margin and the margin recalculated using revenue and expenses.
- Of those eligible records, 229 indicate a calculated loss and 721 indicate a calculated profit; 142 have calculated losses alongside positive reported margins.
- Customer city and branch city differ in 7,932 joined rows, and regions differ in 7,502 joined rows. These are **not necessarily errors** because customers can use branches outside their home location.

These findings describe a synthetic dataset and the project's validation assumptions; source financial field definitions remain unverified. See `results/data_quality_report.md` for details.

## Project Status

**In Progress — Data Quality Assessment Completed; Data Preparation Next**

Data cleaning, analytical queries, and visualizations will be added in subsequent phases. The dataset CSVs are not redistributed; see `data/dataset_source.md` for the source link and license caution.