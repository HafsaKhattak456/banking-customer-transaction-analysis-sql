# Banking Customer & Transaction Analytics — Data Quality Report

**Status:** Planned initial data-quality checks complete; financial metric definition unresolved.  
**Database:** PostgreSQL 18 (pgAdmin 4)  
**Source:** Synthetic banking dataset; see [`../data/dataset_source.md`](../data/dataset_source.md).  
**Evidence:** Results shared from PostgreSQL by the project author. This report does not assert independent execution of the SQL against the author's database.

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

## 6. Decisions and next phase

1. Preserve the three original imported staging tables.
2. Retain customer records with incomplete demographic fields; use analysis-specific handling and document NULLs.
3. Keep recorded and recalculated financial margins in separate fields and label provisional formulas clearly.
4. Do not repair customer/branch location differences without a validated business rule.
5. Build analysis-ready tables/views and independently verify row counts and joins before business analysis.
6. Use the next phase for customer segmentation, transaction patterns, investments, and branch reporting, without presenting unresolved financial metrics as verified facts.

## SQL evidence

- [`../sql/01_create_tables.sql`](../sql/01_create_tables.sql): staging schemas.
- [`../sql/02_data_quality_checks.sql`](../sql/02_data_quality_checks.sql): Checks 1–14.
- [`../sql/03_remaining_data_quality_checks.sql`](../sql/03_remaining_data_quality_checks.sql): Checks 15–22 and optional spot check.
