# Banking Customer & Transaction Analytics — Business Insights

**Project phase:** SQL analytics and Power BI dashboard completed. 
**Tools:** PostgreSQL 18 and pgAdmin 4  
**Dataset:** Synthetic banking data: 10,000 customers, 10,000 transaction records, and 1,000 branch records  
**Source:** [Banking and Customer Transaction Data (Kaggle)](https://www.kaggle.com/datasets/yogeshtekawade/banking-and-customer-transaction-data)  
**Currency:** Unverified; all amounts below are in unspecified monetary units.

## Executive Summary

This project analyzes three connected synthetic banking datasets using PostgreSQL. It includes data validation, preparation of analysis-ready tables, and SQL-based investigation of account types, customer segments, transaction activity, investment categories, and regional financial performance.

The objective is to demonstrate practical SQL and analytical skills while identifying data-quality concerns that could affect financial reporting and decision-making.

**Important:** The dataset is synthetic, and its financial definitions have not been independently verified. The findings are descriptive and do not represent the actual performance of any bank.

---

## 1. Data Preparation and Quality Findings

| Measure | Verified Result |
|---|---:|
| Customer records | 10,000 |
| Transaction records | 10,000 |
| Branch records | 1,000 |
| Customer records with at least one missing age, city, or type | 1,420 (14.2%) |
| Complete customer records across those attributes | 8,580 (85.8%) |
| Branch records missing revenue | 50 (5.0%) |
| Branch records eligible for margin comparison | 950 |
| Margin discrepancies greater than 1 percentage point | 942 (99.16% of eligible records) |
| Unmatched transaction-to-customer references | 0 |
| Unmatched customer-to-branch references | 0 |

### Data Preparation Approach

Three analysis-ready tables were created:

- `analytics.customers_clean`
- `analytics.transactions_clean`
- `analytics.branches_clean`

Missing customer ages were preserved as NULL, while missing city and customer-type values were assigned an explicit `Unknown` reporting category.

Additional date features were created for transaction trend analysis.

For branch financial reporting, both the original profit-margin values and independently calculated margins were preserved.

The original staging tables remained unchanged.

### Financial Calculation

Calculated profit was defined as:

**Calculated Profit = Firm Revenue − Expenses**

Calculated profit margin was defined as:

**Calculated Profit Margin (%) = (Calculated Profit / Firm Revenue) × 100**

These formulas are provisional analytical assumptions. The source dataset's reported profit margins have not been reconciled to a verified accounting definition.

---

## 2. Account Balance Comparison by Account Type

### Business Question

How do recorded account balances vary across account types?

### Results

| Account Type | Transaction Records | Average Recorded Balance | Minimum | Maximum |
|---|---:|---:|---:|---:|
| Current | 3,363 | 50,341.10 | 1,107 | 99,944 |
| Business | 3,291 | 50,297.62 | 1,041 | 99,990 |
| Savings | 3,346 | 50,026.45 | 1,003 | 99,993 |

### Key Findings

Current accounts have the highest average recorded balance at 50,341.10, followed by Business accounts at 50,297.62 and Savings accounts at 50,026.45.

The difference between Current and Savings averages is approximately 314.65 monetary units, representing about 0.63% of the Savings average.

This indicates relatively similar average recorded balances across the three account categories.

### Business Interpretation

No single account type shows a substantial advantage in average recorded balances.

However, these statistics represent averages across transaction records, not unique accounts or customers.

Because the dataset does not include a unique account identifier, these values should not be interpreted as verified customer-level account balances or total deposits.

---

## 3. Customer Segmentation Analysis

### Business Question

How do transaction amounts and recorded balances differ across customer types?

### Results

| Customer Type | Unique Transacting Customers | Transaction Records | Average Transaction Amount | Average Recorded Balance |
|---|---:|---:|---:|---:|
| Employee | 2,044 | 3,242 | 2,562.81 | 50,230.08 |
| Business | 1,955 | 3,042 | 2,560.35 | 49,875.20 |
| Individual | 2,014 | 3,211 | 2,519.08 | 50,315.15 |
| Unknown | 322 | 505 | 2,457.68 | 51,657.06 |

### Key Findings

Employee customers have the highest average transaction amount at 2,562.81.

Business customers follow closely at 2,560.35, only 2.46 monetary units lower.

Individual customers have an average transaction amount of 2,519.08.

The `Unknown` category represents customers whose original customer type was missing. It should not be treated as a confirmed customer segment.

### Additional Finding: Customer Transaction Coverage

The customer dataset contains 10,000 customer records.

However, only 6,335 unique customers appear in the transaction dataset.

Therefore:

| Metric | Count |
|---|---:|
| Total customers | 10,000 |
| Customers with recorded transactions | 6,335 |
| Customers without recorded transactions | 3,665 |
| Percentage without recorded transactions | 36.65% |

### Business Interpretation

Approximately 36.65% of customers do not appear in the available transaction records.

This does not necessarily mean they are inactive customers. It only indicates that no matching transactions were observed in the supplied dataset.

The finding demonstrates why analysts must distinguish between the full customer population and the subset represented in transaction activity.

---

## 4. Monthly Transaction Trends

### Business Question

How does transaction activity change over time?

### Dataset Coverage

**Earliest transaction:** March 21, 2022  
**Latest transaction:** March 20, 2025  
**Observed calendar months:** 37

### Key Findings

| Metric | Finding |
|---|---|
| Highest monthly transaction count | January 2025 |
| Transactions in January 2025 | 312 |
| Highest monthly transaction value | August 2024 |
| August 2024 transaction records | 304 |
| August 2024 total recorded transaction value | 817,073.43 |

Monthly transaction activity fluctuated rather than showing a consistent increase throughout the observation period.

### Business Interpretation

Changes in monthly transaction value may reflect differences in transaction frequency, transaction size, or both.

The first and last observed months—March 2022 and March 2025—are incomplete months.

Therefore, direct comparisons of those months with full calendar months could be misleading.

The complete monthly results are available in [monthly_transaction_summary.csv](monthly_transaction_summary.csv).

The corresponding SQL queries are available in [05_business_analysis.sql](../sql/05_business_analysis.sql).

---

## 5. Investment Activity Analysis

### Business Question

Which investment categories account for the largest recorded investment amounts?

### Results

| Investment Type | Transaction Records | Total Recorded Amount | Average Recorded Amount |
|---|---:|---:|---:|
| Recurring Deposit | 3,338 | 86,002,806 | 25,764.77 |
| Mutual Fund | 3,327 | 84,823,930 | 25,495.62 |
| Fixed Deposit | 3,335 | 84,675,748 | 25,390.03 |
| **Total** | **10,000** | **255,502,484** | — |

### Key Findings

Recurring Deposits have the highest sum of recorded investment amounts at approximately 86.00 million monetary units.

Mutual Funds follow at approximately 84.82 million, while Fixed Deposits account for approximately 84.68 million.

The average investment amounts are also relatively similar across all three categories.

Recurring Deposits have the highest average amount at 25,764.77.

### Business Interpretation

Investment amounts are distributed relatively evenly across the three categories.

No category dominates the recorded investment data.

However, the dataset does not establish whether `investment_amount` represents a new investment transaction, a current holding, or a repeated balance.

Consequently, these totals cannot be interpreted as verified investment inflows, assets under management, or unique customer holdings.

---

## 6. Regional Financial Performance

### Business Question

Which regions demonstrate stronger calculated financial performance?

### Methodology

Regional profit was calculated using:

**Calculated Profit = Firm Revenue − Expenses**

Only branches with complete revenue and expense information were included in comparable profitability calculations.

### Results

| Region | Comparable Branches | Total Calculated Profit | Average Calculated Profit per Branch | Aggregate Calculated Margin | Loss-Making Branch Rate |
|---|---:|---:|---:|---:|---:|
| South | 245 | 63,993,148 | 261,196.52 | 49.43% | 22.45% |
| East | 249 | 62,294,113 | 250,177.16 | 48.27% | 24.10% |
| West | 232 | 55,284,503 | 238,295.27 | 47.70% | 26.29% |
| North | 224 | 52,834,793 | 235,869.61 | 46.37% | 23.66% |
| **Total** | **950** | **234,406,557** | — | — | — |

### Key Findings

**South Region**

South has the highest average calculated profit per comparable branch at 261,196.52.

It also leads in aggregate calculated margin at 49.43% and has the lowest calculated loss-making branch rate at 22.45%.

**North Region**

North has the lowest average calculated profit per comparable branch at 235,869.61 and the lowest aggregate calculated margin at 46.37%.

**West Region**

West has the highest calculated loss-making branch rate at 26.29%.

### Business Interpretation

South ranks highest under several calculated financial metrics.

However, these findings depend on the simplified profit formula and the availability of revenue and expense data.

Fifty branch records with missing revenue were excluded from comparable profitability calculations.

The regional comparisons should not be presented as audited operating results.

The aggregate calculated margin is based on total comparable profit divided by total comparable revenue, rather than an unweighted average of branch-level margins.

---

## 7. Financial Data Consistency Investigation

### Business Question

Do reported profit margins agree with margins independently calculated from revenue and expenses?

### Results

| Metric | Result |
|---|---:|
| Total branch records | 1,000 |
| Eligible records for comparison | 950 |
| Records with missing revenue | 50 |
| Margin discrepancies greater than 1 percentage point | 942 |
| Records within the selected tolerance | 8 |
| Percentage of eligible records flagged | 99.16% |
| Calculated-loss records with positive reported margins | 142 |

### Key Findings

A significant inconsistency was identified between the dataset's reported profit margins and the independently calculated margins.

Among 950 eligible records, 942 showed discrepancies exceeding one percentage point.

Additionally, 142 records had a negative calculated profit while retaining a positive reported profit margin.

### Business Interpretation

These findings suggest that the reported margin may use a different formula, reporting basis, or data-generation process.

The discrepancies should not automatically be treated as confirmed data errors.

### Recommendation

Preserve both reported and calculated profit margins until the source's financial definitions have been verified.

Any future correction should be documented and supported by a defensible business rule.

---

## 8. Overall Business Insights

The analysis produced several important observations:

**Customer Data Quality**

Missing customer information affects 14.2% of customer records across the evaluated demographic attributes.

Removing all incomplete profiles would unnecessarily reduce the available population for analyses that do not require every attribute.

**Customer Activity**

A significant portion of customers does not appear in the transaction dataset. This highlights the importance of distinguishing customer population size from observed transactional coverage.

**Account Balances**

Average recorded balances are similar across Current, Business, and Savings account categories.

**Investment Activity**

The sum of recorded investment amounts is relatively evenly distributed among Recurring Deposits, Mutual Funds, and Fixed Deposits.

**Regional Performance**

South ranks highest in several provisional calculated profitability metrics, while West has the greatest proportion of calculated loss-making branch records.

**Financial Reporting Reliability**

The widespread disagreement between reported and calculated profit margins demonstrates the need to verify financial metric definitions before using them for decision-making.

---

## 9. Recommendations

1. Preserve original customer and financial records while using separate analysis-ready tables for reporting.

2. Retain missing-value indicators and treat unknown customer attributes as missing information rather than inventing values.

3. Distinguish transaction-record-level calculations from customer-level or account-level metrics.

4. Verify financial definitions before interpreting reported profit margins or investment totals.

5. Use comparable populations for regional analysis and account for missing financial information.

6. Consider partial-month coverage when analyzing transaction trends.

7. Maintain and extend the completed Power BI dashboard to communicate the analytical findings clearly.

---

## 10. Project Limitations

- The dataset is synthetic and does not represent the actual operations of a financial institution.
- The currency associated with financial values has not been verified.
- The definitions of certain financial metrics remain uncertain.
- Reported profit margins differ substantially from calculated values.
- Investment amounts may represent balances or repeated observations rather than new investment transactions.
- Transaction records do not provide unique account identifiers.
- Some customer and branch financial records contain missing information.
- The analysis is descriptive and does not establish causal relationships.
- PostgreSQL analysis-ready tables are snapshot tables and do not automatically refresh when source data changes.

---

## 11. Future Work

The core PostgreSQL business analysis and Power BI dashboard have been completed.

Potential future enhancements include:

- Adding more advanced DAX measures and banking KPIs.
- Expanding customer segmentation and transaction analysis.
- Introducing additional interactive dashboard filters.
- Improving financial metric reconciliation when reliable source definitions become available.
- Exploring transaction forecasting using appropriate time-series methods.

The completed Power BI dashboard is available in the [`powerbi/`](../powerbi/) directory.

The PBIX contains an imported data snapshot. Refreshing the report requires access to a compatible PostgreSQL database.

---

## Related Project Files

- [Data Quality Report](data_quality_report.md)
- [Monthly Transaction Summary](monthly_transaction_summary.csv)
- [Business Analysis SQL](../sql/05_business_analysis.sql)
- [Dataset Source and Limitations](../data/dataset_source.md)

---

## Conclusion

This banking analytics project demonstrates how PostgreSQL can be used to validate data, prepare analysis-ready tables, investigate financial metrics, and generate descriptive business insights.

The project highlights the importance of data quality, appropriate analytical definitions, and careful interpretation of results before drawing business conclusions.

The completed SQL analysis and interactive Power BI dashboard demonstrate an end-to-end workflow, from data validation and preparation to business reporting and visualization.