# Banking Customer & Transaction Analytics — Business Insights

**Project status:** Core SQL data preparation and business analysis completed.  
**Platform:** PostgreSQL 18 / pgAdmin 4  
**Data:** Synthetic banking records (10,000 customers, 10,000 transaction records, 1,000 branch records).  
**Currency:** Not confirmed in source metadata; amounts below are in unspecified monetary units.  
**Source:** [Kaggle: Banking and Customer Transaction Data](https://www.kaggle.com/datasets/yogeshtekawade/banking-and-customer-transaction-data).

## Executive summary

The project established three analysis-ready tables without modifying raw source tables, validated their row counts and cross-table references, then examined account types, customer segments, monthly transaction activity, investment categories, and regional financial performance. The analysis is **descriptive** and **synthetic**: it is not evidence about an actual bank's customers or profitability.

## Data preparation and quality controls

- `analytics.customers_clean`: 10,000 records; 1,420 (14.2%) incomplete across age, city and customer type; 8,580 complete. Missing age remains NULL; missing city or type becomes explicit `Unknown` category; flag retains provenance.
- `analytics.transactions_clean`: 10,000 records; date-derived year, month and month-start fields; transaction dates span **2022-03-21 to 2025-03-20**.
- `analytics.branches_clean`: 1,000 records; 50 missing revenue; reported margin preserved separately from recalculated margin. Of 950 comparable records, 942 (99.16%) differ by more than 1 percentage point under the provisional revenue-based margin formula.
- All 10,000 transactions reference customers and all 10,000 customer rows reference a branch; no unmatched references were detected in the prepared tables.

> **Critical metric limitation:** The dataset's recorded profit margin does not reconcile with `(firm_revenue - expenses) / firm_revenue * 100` in most comparable records. Do not treat reported margin and recalculated margin as interchangeable, and do not call either an audited financial KPI. Source field definitions remain unverified.

## 1. Account-type balance comparison

| Account type | Transaction rows | Average recorded balance | Minimum | Maximum |
|---|---:|---:|---:|---:|
| Current | 3,363 | 50,341.10 | 1,107 | 99,944 |
| Business | 3,291 | 50,297.62 | 1,041 | 99,990 |
| Savings | 3,346 | 50,026.45 | 1,003 | 99,993 |

Average balance values are similar across the three types. Current leads Savings by 314.65 units (about 0.63% of the Savings average). **These are transaction-row-level balances, not unique-account holdings or total customer deposits.**

## 2. Customer type segmentation (customers with transactions only)

| Customer type | Unique transacting customers | Transaction rows | Average transaction amount | Average recorded balance |
|---|---:|---:|---:|---:|
| Employee | 2,044 | 3,242 | 2,562.81 | 50,230.08 |
| Business | 1,955 | 3,042 | 2,560.35 | 49,875.20 |
| Individual | 2,014 | 3,211 | 2,519.08 | 50,315.15 |
| Unknown | 322 | 505 | 2,457.68 | 51,657.06 |

The three known groups have closely spaced average transaction amounts. The `Unknown` category means **missing source customer type**, not an identified segment. A total of **6,335** distinct customers have transactions in the supplied dataset; **3,665** of 10,000 customers have none in the file. This does not imply actual banking inactivity.

## 3. Monthly transaction trends

- The full dataset covers **37 observed calendar months** (March 2022 to March 2025).
- **January 2025** had the most transaction records: **312**.
- **August 2024** had the highest monthly sum of transaction amounts: **817,073.43** across **304** records.
- Monthly counts fluctuate and do not show a steady monotonic increase. March 2022 and March 2025 are **partial observation months** and should not be compared unadjusted with full months.

![Monthly transaction counts](../visuals/monthly_transaction_trend.png)

The full reproducible monthly results are in `results/monthly_transaction_summary.csv`; the SQL that generates them is in `sql/05_business_analysis.sql`.

## 4. Recorded investment categories

| Investment type | Transaction rows | Sum of recorded amounts | Average amount |
|---|---:|---:|---:|
| Recurring Deposit | 3,338 | 86,002,806 | 25,764.77 |
| Mutual Fund | 3,327 | 84,823,930 | 25,495.62 |
| Fixed Deposit | 3,335 | 84,675,748 | 25,390.03 |
| **Total** | **10,000** | **255,502,484** | — |

Recurring Deposits have the highest sum of recorded amounts, though all three categories are close. **Investment amounts may represent position values or repeated balances rather than newly invested flows; do not describe the sum as net inflows or assets under management.**

![Investment category totals](../visuals/investment_category_totals.png)

## 5. Regional financial performance

| Region | Comparable branches | Calculated profit sum | Avg. calculated profit/branch | Aggregate calculated margin | Loss-record rate |
|---|---:|---:|---:|---:|---:|
| South | 245 | 63,993,148 | 261,196.52 | 49.43% | 22.45% |
| East | 249 | 62,294,113 | 250,177.16 | 48.27% | 24.10% |
| West | 232 | 55,284,503 | 238,295.27 | 47.70% | 26.29% |
| North | 224 | 52,834,793 | 235,869.61 | 46.37% | 23.66% |
| **Total** | **950** | **234,406,557** | — | — | — |

South leads on average calculated profit, aggregate calculated margin, and the lowest calculated-loss record rate. West has the highest loss-record rate (26.29%). Regional metrics omit **50 branch records with missing revenue** and use the provisional formula `revenue - expenses`; they are not audited financial statements.

![Regional average profit](../visuals/regional_average_profit.png)

## Practical implications

1. **Measure missingness before excluding records.** Dropping incomplete profiles would remove 14.2% of customer rows when all three fields are required.
2. **Verify financial definitions before trusting a KPI.** Recorded and recalculated margins disagree for 99.16% of comparable branch records; preserve both and investigate upstream definitions.
3. **Use the correct unit of analysis.** Transaction-record balance averages are not unique-customer or account balances; investment value sums are not necessarily investment flows.
4. **Make fair period comparisons.** The boundary months are partially observed.

## Limitations and next steps

- Synthetic dataset; currency, field definitions, accounting periods and investment semantics remain unverified.
- No formal uncertainty estimation, causal inference, or forecasting is claimed.
- SQL transformations create snapshot tables; rerunning `CREATE TABLE IF NOT EXISTS` will not refresh old tables.
- Possible next extensions: distinct customer behavioral cohorts, fully observed-month comparisons, source-defined financial KPI reconciliation, and a dashboard using verified metrics.
