# Banking Customer & Transaction Analytics — Data Quality Report

**Status:** Data-quality assessment completed.  
**Database:** PostgreSQL 18 (pgAdmin 4)  
**Source:** Synthetic banking dataset; see [dataset_source.md](../data/dataset_source.md).  
**Evidence:** Results obtained by executing SQL queries in PostgreSQL.

## Dataset

| Table | Imported records |
|---|---:|
| `bank_data` | 1,000 |
| `customer_data` | 10,000 |
| `transaction_data` | 10,000 |

## 1. Customer completeness

| Measure | Result |
|---|---:|
| Missing age | 500 (5.0%) |
| Missing city | 500 (5.0%) |
| Missing customer type | 500 (5.0%) |
| Records missing at least one of these three fields | 1,420 (14.2%) |
| Records missing all three | 1 |
| Records complete on all three | 8,580 (85.8%) |

The 1,500 missing cells are spread across 1,420 customer records: 1,341 records have exactly one missing field, 78 have exactly two, and one has all three. Discarding every incomplete record would exclude 14.2% of customers from analyses requiring all three attributes. For analyses needing only one attribute, retain other usable records.

## 2. IDs, dates, and relationships

- No repeated customer IDs or transaction IDs were detected in the individual checks.
- The later identifier audit found **zero missing IDs and zero extra repeated non-NULL IDs** for branch, customer, and transaction identifiers.
- **Zero** customer records had missing or unmatched branch IDs; **zero** transaction records had missing or unmatched customer IDs.
- Transaction date validation returned **zero** NULL or future-dated records as of the execution date.
- Customer ages outside the project-defined range 18–100: **zero** non-NULL records.
- Transaction amounts that are NULL, zero, or negative: **zero** records.

These checks do not prove that every record represents a unique person or economic event, nor that historical dates and amounts are intrinsically correct.

## 3. Financial-field completeness and reconciliation

| Metric | Result |
|---|---:|
| Branch records | 1,000 |
| Missing `firm_revenue` | 50 (5%) |
| Missing `expenses` | 0 |
| Missing `profit_margin` | 0 |
| Eligible rows for margin comparison | 950 |
| Margin discrepancy above 1 percentage point | 942 (99.16% of eligible) |
| Rows within 1 percentage point | 8 |
| Mean absolute discrepancy | 72.75 percentage points |
| Maximum absolute discrepancy | 759.64 percentage points |
| Calculated loss alongside positive reported margin | 142 |

**Assumption to verify:** Recalculated profit margin = `(firm_revenue - expenses) / firm_revenue * 100`, treating the supplied `profit_margin` as percentage points. The dataset's financial definitions and units have **not** been established. A flagged difference is **not** a confirmed accounting error. Do not overwrite the original margin column without source reconciliation.

### Distribution of recorded vs recalculated margins

| Statistic | Recorded margin | Recalculated margin |
|---|---:|---:|
| Minimum | −49.50 | −789.14 |
| Maximum | 99.97 | 97.62 |
| Mean | 25.26 | 12.08 |

Ranges and means do not establish row-level agreement. The high flag rate warrants verification of the intended metric, its scale, and the revenue/expense period.

### Simplified branch profitability (revenue minus expenses)

Of 950 branch records with revenue and expenses present, **721** have revenue greater than expenses (75.89%), **229** have expenses greater than revenue (24.11%), and **0** are break-even. This is an arithmetic classification, **not** a verified statement of real-world operating profitability. Fifty records with missing revenue were excluded.

## 4. Transaction attribute completeness and ranges

A transaction attribute check returned **zero missing** values in the visible output for account type, total balance, transaction amount, investment amount, and investment type. The screenshot's date-completeness column was cut off, but a separate date-validation query found zero NULL dates.

| Observed value | Result |
|---|---|
| Earliest transaction date | 2022-03-21 |
| Latest transaction date | 2025-03-20 |
| Smallest transaction amount | 51.6139516774 |
| Largest transaction amount | 7046.2964407668 |
| Minimum total balance | 1003.00 |
| Maximum total balance | 99993.00 |

Currency units are not confirmed. The ranges alone do not establish abnormality. Some fields from the full Check 20 output were not visible, so unobserved negative-balance/investment counts are not asserted here.

## 5. Text values and geography

Visible text-field audit results show **zero blank (non-NULL)** customer cities and customer types, and **zero missing/blank** customer regions, branch cities, or branch regions. Earlier results identified **500 SQL NULL customer city values**; this does not conflict with zero *blank strings*.

The location comparison returned **10,000 joined customer–branch rows**. On those rows:

- **7,932** customer/branch city differences were flagged.
- **7,502** customer/branch region differences were flagged.

These are location differences, **not evidence of invalid customer records**. Customers can live in a different city or region from their bank branch. Furthermore, the comparison query did not count NULL customer cities as mismatches; its 10,000 denominator represents joined rows, not necessarily all rows eligible for a city comparison. Separate denominators are needed for precise mismatch rates among non-NULL pairs.

## 6. Data Preparation Decisions and Outcomes

Following the data-quality assessment, three analysis-ready PostgreSQL tables were created in the `analytics` schema.

| Table | Records | Purpose |
|---|---:|---|
| `analytics.customers_clean` | 10,000 | Customer profiles with explicit handling of missing demographic attributes |
| `analytics.transactions_clean` | 10,000 | Transaction records with derived year and month features |
| `analytics.branches_clean` | 1,000 | Branch financial records with calculated profit metrics and discrepancy flags |

### Cleaning and Preparation Decisions

1. Preserved the original `public` staging tables without modifying source records.
2. Retained missing customer ages as NULL.
3. Replaced missing customer cities and customer types with an explicit `Unknown` reporting category in the analysis-ready customer table.
4. Added `has_missing_profile_data` to identify incomplete customer profiles.
5. Added transaction year and month fields to support time-based reporting.
6. Preserved reported profit margins alongside independently calculated margins.
7. Added `has_margin_discrepancy` to flag differences exceeding one percentage point.
8. Preserved customer–branch location differences without assuming they were data errors.

### Validation Results

The analysis-ready tables retained all expected records:

- Customers: 10,000
- Transactions: 10,000
- Branch records: 1,000

Final cross-table validation confirmed:

- Unmatched transaction-to-customer references: 0
- Unmatched customer-to-branch references: 0

These results confirm record-count preservation and successful relationship checks. They do not establish that every financial value is accurate.

### Current Project Status

Data-quality assessment, data preparation, and the core SQL business analyses are complete.

The financial metric inconsistencies remain documented and unresolved.

The next planned stage is Power BI dashboard development.

## SQL Evidence

- [01_create_tables.sql](../sql/01_create_tables.sql) — Staging table creation.
- [02_data_quality_checks.sql](../sql/02_data_quality_checks.sql) — Data Quality Checks 1–14.
- [03_remaining_data_quality_checks.sql](../sql/03_remaining_data_quality_checks.sql) — Additional validation checks.
- [04_create_analytics_tables.sql](../sql/04_create_analytics_tables.sql) — Analysis-ready table creation and verification.
- [05_business_analysis.sql](../sql/05_business_analysis.sql) — Customer, transaction, investment, and regional analysis.

For analytical findings, see [Business Insights](business_insights.md).