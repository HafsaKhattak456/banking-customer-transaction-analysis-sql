# Banking Customer & Transaction Analytics | PostgreSQL

A reproducible **SQL portfolio case study** analyzing a **synthetic** banking dataset with 10,000 customers, 10,000 transaction records, and 1,000 bank branch records. The project covers raw data import, data-quality validation, analysis-ready table creation, and descriptive business analysis.

**Stack:** PostgreSQL 18 · pgAdmin 4 · SQL (joins, CTEs, aggregations, conditional aggregates) · charts exported from the source CSVs.

## Project workflow

`Raw CSVs → PostgreSQL staging tables → Data-quality checks → analytics schema → Business queries → Findings and visualizations`

## Key findings

- **14.2%** of customer records (1,420 / 10,000) have at least one missing age, city, or customer type.
- **6,335 customers** have a transaction in the dataset; 3,665 do not.
- **January 2025** has the largest transaction count (**312**); **August 2024** has the highest monthly sum of transaction amounts (**817,073.43**).
- **Recurring Deposits** have the largest sum of recorded investment amounts (**86,002,806**), narrowly ahead of Mutual Funds and Fixed Deposits.
- **South** leads comparable branches in average *calculated* profit (**261,196.52** per branch); **West** has the highest calculated-loss record rate (**26.29%**).
- **Financial caveat:** 942 of 950 comparable branches have a recorded vs. recalculated profit-margin difference greater than 1 percentage point. Source definitions are unresolved; **neither margin metric should be presented as audited bank profit**.

### Visual snapshot

![Monthly transaction counts](visuals/monthly_transaction_trend.png)

| Investment totals | Average calculated profit by region |
|---|---|
| ![Investment categories](visuals/investment_category_totals.png) | ![Regional average profit](visuals/regional_average_profit.png) |

Read [the full business insights](results/business_insights.md) and [the data-quality assessment](results/data_quality_report.md).

## Repository structure

```text
README.md
data/dataset_source.md
sql/01_create_tables.sql
sql/02_data_quality_checks.sql
sql/03_remaining_data_quality_checks.sql
sql/04_create_analytics_tables.sql
sql/05_business_analysis.sql
results/data_quality_report.md
results/business_insights.md
results/monthly_transaction_summary.csv
visuals/monthly_transaction_trend.png
visuals/investment_category_totals.png
visuals/regional_average_profit.png
visuals/banking_analytics_dashboard.html
```

## Reproduce the analysis

1. Obtain the three original CSVs from the [Kaggle source](https://www.kaggle.com/datasets/yogeshtekawade/banking-and-customer-transaction-data). The raw CSVs are not redistributed here; check the source license.
2. Create a PostgreSQL database named `banking_analytics` and connect via pgAdmin Query Tool.
3. Execute `sql/01_create_tables.sql`, then import each CSV to the corresponding `public` table using pgAdmin Import/Export (CSV, header enabled). Verify imported record counts.
4. Execute `sql/02_data_quality_checks.sql` and `sql/03_remaining_data_quality_checks.sql` (queries can be run separately).
5. Execute `sql/04_create_analytics_tables.sql` to create `analytics.customers_clean`, `analytics.transactions_clean`, and `analytics.branches_clean` and verify counts/references.
6. Execute queries in `sql/05_business_analysis.sql`; compare with the reports and visuals.
7. Open `visuals/banking_analytics_dashboard.html` locally for a static, offline overview of verified descriptive results.

**Note:** `CREATE TABLE IF NOT EXISTS` does not refresh tables already built; the scripts are intended to build a fresh environment or preserve existing analysis snapshots.

## Interpretation safeguards

- **Synthetic, not real bank data.** No real institution's performance is claimed.
- **Currency is unspecified.** Do not assume INR, PKR, GBP, etc.
- **Grain matters.** Balance averages describe transaction rows; investment sums may double-count if source amounts are repeated balances; customer-segment joins exclude customers with no transactions.
- **Margin reconciliation remains open.** Source `profit_margin` is retained alongside a provisional calculated margin; 50 branches are ineligible for comparison because revenue is missing.
- **Period coverage:** 2022-03-21 to 2025-03-20; boundary months are partial.

## Project status

- [x] Database setup and import
- [x] Data-quality assessment
- [x] Analysis-ready customer, transaction, and branch tables
- [x] Six core business analyses
- [x] Business-insights report and static charts/dashboard
- [ ] Optional extensions: advanced customer cohort analysis, Power BI, source-defined KPI reconciliation
