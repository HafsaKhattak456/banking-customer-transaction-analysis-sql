# Banking Customer & Transaction Analytics
## Data Quality Assessment Report

**Database:** PostgreSQL 18  
**Tool:** pgAdmin 4  
**Dataset Type:** Synthetic Banking Data  
**Project Status:** In Progress — Data Quality Assessment

---

## 1. Project Overview

This project analyzes a synthetic banking dataset using PostgreSQL to evaluate data quality, identify missing and inconsistent records, and prepare reliable data for banking analytics.

The objective is to demonstrate practical SQL skills while applying data validation techniques commonly used in financial data analysis.

The assessment covers customer information, financial transactions, and banking branch records.

## 2. Dataset Overview

The dataset consists of three CSV files imported into PostgreSQL.

| Table | Number of Records | Columns |
|---|---:|---:|
| `bank_data` | 1,000 | 6 |
| `customer_data` | 10,000 | 7 |
| `transaction_data` | 10,000 | 8 |
| **Total** | **21,000** | **21** |

### Database Relationships

- `bank_data.branch_id` links to `customer_data.branch_id`.
- `customer_data.customer_id` links to `transaction_data.customer_id`.

These relationships will support customer-level, branch-level, and transaction-level analysis.

## 3. Data Quality Assessment

### 3.1 Missing Value Analysis

The initial assessment identified missing customer information.

| Column | Missing Values | Missing Percentage |
|---|---:|---:|
| Age | 500 | 5.00% |
| Customer Type | 500 | 5.00% |
| City | 500 | 5.00% |

**Observation:**

Each of these customer attributes contains 500 missing values out of 10,000 customer records.

The missing information may affect customer segmentation, demographic analysis, and geographical reporting.

**Business Impact:**

Incomplete customer attributes may result in inaccurate or incomplete segment-level insights, particularly when calculating customer distributions by age, location, or customer category.

**Next Action:**

Investigate whether missing values occur in the same customer records or across different customers before deciding on an appropriate treatment.

### 3.2 Duplicate Customer ID Validation

A duplicate check was performed using `GROUP BY` and `HAVING`.

**Result:** 0 duplicate customer IDs detected.

**Observation:**

Every customer ID appears only once in the imported `customer_data` table.

**Business Impact:**

Unique customer identifiers support reliable customer-level joins and reduce the risk of duplicate customer records inflating aggregated transaction calculations.

**Limitation:**

This check does not identify potentially duplicated customer profiles assigned different customer IDs.

### 3.3 Customer Age Validation

Customer ages were checked against the following project-defined range:

- Minimum age: 18 years
- Maximum age: 100 years

**Result:** 0 ages outside the selected range.

**Observation:**

All non-NULL ages satisfied the defined validation criteria.

**Business Impact:**

This supports using the available age records for preliminary segmentation, subject to further verification of the source data.

**Limitation:**

The chosen age boundaries are analytical assumptions, not official banking eligibility criteria. Missing ages were assessed separately.

### 3.4 Transaction Amount Validation

Transaction amounts were checked for:

- Negative values
- Zero values
- NULL values

**Result:** 0 records flagged.

**Observation:**

No transaction amounts were found to be zero, negative, or NULL in the imported `transaction_data` table.

**Business Impact:**

The initial transaction amount check did not identify incomplete or nonpositive transaction amounts.

**Limitation:**

This does not establish that all transaction amounts are accurate. Additional checks for unusual transaction values, duplicates, and financial inconsistencies are required.

---

## 4. Summary of Findings

| Data Quality Dimension | Finding | Assessment |
|---|---|---|
| Customer age completeness | 500 missing values | Requires investigation |
| Customer type completeness | 500 missing values | Requires investigation |
| Customer city completeness | 500 missing values | Requires investigation |
| Customer ID uniqueness | 0 duplicates | Passed |
| Customer age range | 0 flagged records | Passed |
| Transaction amount validity | 0 nonpositive or NULL amounts | Passed |

### Key Insight

The primary confirmed data-quality issue identified so far is incomplete customer information.

Although customer identifiers and transaction amounts passed their respective validation checks, additional analysis is necessary before considering the dataset suitable for all financial reporting purposes.

## 5. Recommendations

**1. Investigate missing customer information**

Determine whether missing age, city, and customer type values overlap across records.

**2. Preserve raw data**

Maintain the original staging tables and perform future cleaning operations in separate tables or reproducible SQL transformations.

**3. Validate additional financial attributes**

Check transaction dates, account balances, investment amounts, and transaction identifiers.

**4. Verify table relationships**

Investigate unmatched customer, transaction, and branch identifiers.

**5. Document all cleaning decisions**

Any imputation, correction, or exclusion should include a clear justification and an assessment of its possible impact on analytical results.

## 6. Next Steps

- [x] Import banking datasets into PostgreSQL
- [x] Identify missing customer attributes
- [x] Check duplicate customer IDs
- [x] Validate customer age ranges
- [x] Validate transaction amounts
- [ ] Investigate missing-value overlap
- [ ] Check duplicate transaction IDs
- [ ] Validate transaction dates
- [ ] Investigate transaction amount distributions
- [ ] Verify relational integrity
- [ ] Prepare cleaned analytical tables
- [ ] Perform customer and transaction analysis
- [ ] Develop business insights and visualizations

## 7. Tools and SQL Concepts Applied

**Tools**
- PostgreSQL 18
- pgAdmin 4
- GitHub

**SQL Concepts**
- `SELECT`
- `COUNT()`
- `WHERE`
- `GROUP BY`
- `HAVING`
- `ORDER BY`
- `IS NULL`
- `IS NOT NULL`
- Logical operators (`AND`, `OR`)

## 8. Project Limitations

This project uses synthetic banking data and does not represent actual customer or financial records from a financial institution.

The data-quality results are based on the SQL validation checks completed so far.

Passing an individual validation check does not guarantee that the underlying data is entirely accurate, complete, or consistent.

No customer records have been deleted or modified during the initial assessment.

---

## 9. Conclusion

The initial PostgreSQL data-quality assessment identified missing information in three customer attributes, each affecting 5% of records.

No duplicate customer IDs, out-of-range non-NULL ages, or nonpositive or NULL transaction amounts were identified.

The next phase will investigate missing-value patterns, transaction consistency, and relationships between banking tables before performing customer segmentation and financial analysis.

This project demonstrates the use of SQL for systematic data validation and supports the development of reproducible, business-oriented banking analytics workflows.