# Dataset Source and Description

## 1. Dataset Overview

This project uses a synthetic banking dataset to perform customer data-quality assessment, transaction analysis, and branch-level financial analytics using PostgreSQL.

The dataset consists of three CSV files containing customer profiles, transaction records, and bank branch information.

**Dataset Type:** Synthetic Banking Data  
**Database:** PostgreSQL 18  
**Data Format:** CSV  
**Total Records:** 21,000 across three tables

## 2. Dataset Source

**Dataset Name:** Banking Customer and Transaction Dataset

**Original Source:** https://www.kaggle.com/datasets/yogeshtekawade/banking-and-customer-transaction-data

The dataset is used for educational purposes and portfolio development. It does not contain actual customer records.

The original data source and applicable redistribution permissions should be verified before publishing the CSV files in this repository.

## 3. Dataset Structure

### A. bank_data.csv

**Records:** 1,000  
**Columns:** 6

| Column | Description |
|---|---|
| Branch_ID | Identifier associated with a bank branch |
| City | City associated with the branch |
| Region | Geographic region |
| Firm_Revenue | Reported branch revenue |
| Expenses | Reported branch expenses |
| Profit_Margin | Reported profit margin field |

### B. customer_data.csv

**Records:** 10,000  
**Columns:** 7

| Column | Description |
|---|---|
| Customer_ID | Unique customer identifier |
| Age | Customer age |
| Customer_Type | Customer classification |
| City | Customer city |
| Region | Customer geographic region |
| Bank_Name | Bank name associated with customer |
| Branch_ID | Branch identifier associated with customer |

### C. transaction_data.csv

**Records:** 10,000  
**Columns:** 8

| Column | Description |
|---|---|
| Transaction_ID | Transaction identifier |
| Customer_ID | Customer associated with transaction |
| Account_Type | Account category |
| Total_Balance | Reported account balance |
| Transaction_Amount | Monetary value of transaction |
| Investment_Amount | Reported investment amount |
| Investment_Type | Investment category |
| Transaction_Date | Transaction date |

## 4. Relationships Between Tables

The following columns provide potential relationships for SQL analysis:

- `customer_data.branch_id` → `bank_data.branch_id`
- `transaction_data.customer_id` → `customer_data.customer_id`

These relationships will be validated during the data-quality assessment before being used for financial reporting and customer segmentation.

## 5. Initial Data Quality Findings

The initial PostgreSQL assessment identified:

- 500 missing customer age values (5%).
- 500 missing customer city values (5%).
- 500 missing customer type values (5%).
- No duplicate customer IDs.
- No customer ages outside the project-defined range of 18–100.
- No zero, negative, or NULL transaction amounts.

These findings reflect completed checks only. Additional validation is ongoing.

For detailed results, refer to `results/data_quality_report.md`.

## 6. Data Usage and Reproducibility

The original CSV datasets are imported into PostgreSQL staging tables.

The project SQL scripts are organized as follows:

- `sql/01_create_tables.sql` — Creates the initial database tables.
- `sql/02_data_quality_checks.sql` — Performs the initial data-quality assessment.

Future scripts will document data cleaning, customer segmentation, transaction analysis, and financial reporting.

To reproduce the project:

1. Obtain the three CSV files from the original source.
2. Create a PostgreSQL database named `banking_analytics`.
3. Execute `sql/01_create_tables.sql`.
4. Import the CSV files into their corresponding staging tables using pgAdmin.
5. Execute `sql/02_data_quality_checks.sql`.
6. Compare the query outputs with the documented findings.

## 7. Data Limitations

- The dataset is synthetic and may not represent actual banking operations.
- The meaning, currency, and units of some financial fields require confirmation from the source documentation.
- Missing customer values may affect demographic and geographic analysis.
- Table relationships and financial metrics require additional validation.
- Findings should not be interpreted as real financial or operational performance of any bank.

## 8. Ethical Considerations

This project is intended for SQL learning, analytical practice, and professional portfolio development.

The dataset is not presented as containing confidential banking information or real customer records.