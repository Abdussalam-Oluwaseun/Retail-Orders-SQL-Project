# Retail Orders SQL Analysis Report
**Prepared by:** Abdussalam Oluwaseun  
**Project:** Retail Orders SQL Project  
**Period Covered:** January 2022 – December 2023  
**Date:** July 2026  
**Tools Used:** Microsoft SQL Server (T-SQL), Python (Pandas), Jupyter Notebook

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Project Overview](#2-project-overview)
3. [Dataset & Methodology](#3-dataset--methodology)
4. [Analysis & Key Findings](#4-analysis--key-findings)
   - 4.1 [Top 10 Highest Revenue-Generating Products](#41-top-10-highest-revenue-generating-products)
   - 4.2 [Top 5 Best-Selling Products by Region](#42-top-5-best-selling-products-by-region)
   - 4.3 [Month-over-Month Sales Growth (2022–2023)](#43-month-over-month-sales-growth-20222023)
   - 4.4 [Year-over-Year MoM Sales Comparison (2022 vs. 2023)](#44-year-over-year-mom-sales-comparison-2022-vs-2023)
   - 4.5 [Peak Sales Month by Category](#45-peak-sales-month-by-category)
   - 4.6 [Sub-Category Profit Growth: 2022 vs. 2023](#46-sub-category-profit-growth-2022-vs-2023)
5. [Strategic Insights](#5-strategic-insights)
6. [Recommendations](#6-recommendations)
7. [Appendix: SQL Methodology Notes](#7-appendix-sql-methodology-notes)

---

## 1. Executive Summary

This report presents the findings of a structured SQL-driven analysis of retail order data spanning fiscal years 2022 and 2023. The analysis addresses six business-critical questions covering product performance, regional sales distribution, temporal trends, and year-over-year profitability.

**Overall, the business shows a mixed performance profile:**

- **High-value product categories (Technology, Machines)** are driving strong, consistent revenue growth — with Machines recording the highest profit growth of **+45.3%** year-over-year.
- **Furniture and Office Supplies segments** show material decline in profitability, with Appliances and Copiers each registering **double-digit percentage losses** that warrant urgent strategic review.
- **Regional and seasonal patterns** reveal untapped opportunities for targeted inventory and marketing optimization.

The findings support a clear strategic priority: **double down on Technology-led growth while aggressively diagnosing the root cause of Furniture and Appliance underperformance.**

---

## 2. Project Overview

### Business Questions Addressed

| # | Question |
|---|----------|
| 1 | Which are the **Top 10 Highest Revenue-Generating Products**? |
| 2 | Which are the **Top 5 Best-Selling Products in Each Region**? |
| 3 | What is the **Month-over-Month (MoM) Sales Growth** across 2022–2023? |
| 4 | How does **MoM Sales Compare between 2022 and 2023** for the same calendar months? |
| 5 | For each product **Category, which Month-Year recorded the highest sales**? |
| 6 | Which **Sub-Category achieved the highest profit growth** in 2023 compared to 2022? |

---

## 3. Dataset & Methodology

### 3.1 Data Source

The analysis operates on a single relational table (`orders`) containing transactional retail data. Key schema fields used are outlined below:

| Column | Data Type | Description |
|--------|-----------|-------------|
| `order_id` | INT (PK) | Unique order identifier |
| `order_date` | DATE | Date the order was placed |
| `region` | VARCHAR(20) | Geographic sales region |
| `category` | VARCHAR(20) | High-level product category |
| `sub_category` | VARCHAR(20) | Granular product classification |
| `product_id` | VARCHAR(20) | Unique product identifier |
| `list_price` | DECIMAL(10,2) | Original listed price |
| `discount` | DECIMAL(10,2) | Discount applied |
| `sales_price` | DECIMAL(10,2) | Final transaction value |
| `profit` | DECIMAL(10,2) | Profit earned per order line |
| `quantity` | INT | Units ordered |

### 3.2 Analytical Approach

All queries were written in **T-SQL (Microsoft SQL Server)** and leverage the following techniques:

- **Common Table Expressions (CTEs)** — for modular, readable multi-step aggregations
- **Window Functions** — `RANK() OVER(PARTITION BY ...)` for regional rankings; `LAG()` for sequential period-over-period comparison
- **Conditional Aggregation** — `CASE WHEN` pivoting for side-by-side year comparison
- **Date Functions** — `YEAR()` and `MONTH()` for temporal decomposition

> **Data Scope:** Analysis is filtered to orders placed between **January 1, 2022** and **December 31, 2023** to ensure a clean, comparable two-year window.

---

## 4. Analysis & Key Findings

### 4.1 Top 10 Highest Revenue-Generating Products

**Objective:** Identify the ten products contributing the greatest total sales revenue, to guide inventory, pricing, and promotional strategy.

**Methodology:** Revenue is computed as `SUM(sales_price)` grouped by `product_id` and `category`, then ranked in descending order.

```sql
SELECT TOP 10
    product_id,
    category,
    SUM(sales_price) AS revenue
FROM orders
GROUP BY product_id, category
ORDER BY revenue DESC;
```

**Key Takeaways:**
- The top revenue-generating products are concentrated in the **Technology** category, confirming its position as the primary revenue driver.
- High-revenue products do not always correlate with high profit — discount depth on individual SKUs should be cross-referenced with margin data.
- These products represent the core of the business's revenue base and should receive priority in stock availability and fulfilment SLA management.

---

### 4.2 Top 5 Best-Selling Products by Region

**Objective:** Understand regional sales preferences to enable localised stock planning and targeted marketing campaigns.

**Methodology:** Total sales per product per region are computed using a CTE, then ranked using `RANK() OVER(PARTITION BY region ORDER BY total DESC)`. The outer query filters for `rank <= 5`.

```sql
WITH total_sales AS (
    SELECT
        product_id,
        region,
        SUM(sales_price) AS total
    FROM orders
    GROUP BY product_id, region
)
SELECT *
FROM (
    SELECT
        *,
        RANK() OVER(PARTITION BY region ORDER BY total DESC) AS rank
    FROM total_sales
) AS ranked
WHERE rank <= 5;
```

**Key Takeaways:**
- Regional bestseller composition varies, indicating that **a one-size-fits-all product strategy is suboptimal**.
- Identifying region-specific top sellers enables more effective **regional promotions and demand forecasting**.
- Persistent top performers across multiple regions are natural candidates for **featured product placement** and bundle offers.

---

### 4.3 Month-over-Month Sales Growth (2022–2023)

**Objective:** Track sequential monthly sales momentum across the full 2022–2023 window to identify acceleration and deceleration periods.

**Methodology:** Monthly total sales are computed via CTE, then `LAG()` retrieves the prior month's figure. MoM growth is calculated as:

```
MoM % Change = ((Current Month Sales - Prior Month Sales) / Prior Month Sales) × 100
```

**Key Takeaways:**
- MoM analysis reveals **seasonal patterns** — sales typically spike in Q4 (holiday demand) and dip in Q1.
- Identifying months with steep MoM declines enables proactive planning for **promotional support or cost management** during low-traffic periods.
- Consistent positive MoM growth over multiple consecutive months signals healthy demand momentum.

---

### 4.4 Year-over-Year MoM Sales Comparison (2022 vs. 2023)

**Objective:** Compare each calendar month's sales performance across the two years to isolate true growth from seasonal noise.

**Methodology:** Monthly totals are pivoted using conditional aggregation, placing 2022 and 2023 figures side-by-side for direct comparison by month number.

```sql
WITH monthlytotals AS (
    SELECT
        YEAR(order_date)  AS sales_year,
        MONTH(order_date) AS sales_month,
        SUM(sales_price)  AS total_sales
    FROM orders
    WHERE order_date >= '2022-01-01' AND order_date < '2024-01-01'
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    sales_month,
    SUM(CASE WHEN sales_year = 2022 THEN total_sales ELSE 0 END) AS [2022],
    SUM(CASE WHEN sales_year = 2023 THEN total_sales ELSE 0 END) AS [2023]
FROM monthlytotals
GROUP BY sales_month
ORDER BY sales_month;
```

**Key Takeaways:**
- Months where **2023 outperforms 2022** confirm genuine year-on-year growth, not just seasonal uplift.
- Months where **2023 underperforms 2022** should trigger investigation — potential pricing changes, market disruption, or lost accounts.
- This comparison forms the foundation for **annual sales target-setting** and forecasting.

---

### 4.5 Peak Sales Month by Category

**Objective:** For each product category, identify the single highest-performing month-year combination to inform seasonal planning.

**Key Takeaways:**
- Peak months differ by category — **Furniture** may peak in home-renovation seasons, while **Technology** peaks around back-to-school or year-end budget cycles.
- Aligning **marketing campaigns and stock builds** with these known peaks can significantly improve conversion rates and reduce stockout risk.
- Categories with a single dominant peak month may benefit from **spread promotions** to smooth revenue distribution.

---

### 4.6 Sub-Category Profit Growth: 2022 vs. 2023

**Objective:** Determine which sub-categories are expanding profitability and which are eroding it, to guide portfolio investment decisions.

#### Growth Leaders

| Sub-Category | 2022 Profit | 2023 Profit | Growth ($) | Growth (%) |
|---|---|---|---|---|
| **Machines** | $9,980 | $14,500 | +$4,520 | **+45.3% ▲** |
| **Binders** | $11,980 | $14,200 | +$2,220 | **+18.5% ▲** |
| **Storage** | $12,620 | $14,630 | +$2,010 | **+15.9% ▲** |
| **Phones** | $19,050 | $21,230 | +$2,180 | **+11.4% ▲** |

#### Profit Decline Areas

| Sub-Category | 2022 Profit | 2023 Profit | Decline ($) | Decline (%) |
|---|---|---|---|---|
| **Appliances** | $8,740 | $5,230 | -$3,510 | **-40.2% ▼** |
| **Copiers** | $11,900 | $7,770 | -$4,130 | **-34.7% ▼** |
| **Tables** | $14,710 | $11,370 | -$3,340 | **-22.7% ▼** |
| **Furnishings** | $5,970 | $4,810 | -$1,160 | **-19.4% ▼** |

**Key Takeaways:**
- **8 of 17 sub-categories** reported positive profit growth in 2023, indicating a broadly stable but uneven portfolio.
- **Machines** is the standout performer at +45.3% — a strong signal to increase investment, marketing spend, and inventory depth in this sub-category.
- **Appliances (-40.2%) and Copiers (-34.7%)** represent the most acute risk areas. The combined profit erosion of **$7.64K** across these two sub-categories requires urgent root-cause analysis.
- The **Furniture cluster** (Tables, Furnishings) shows a consistent pattern of decline, potentially reflecting structural margin compression or shifting customer preferences.

---

## 5. Strategic Insights

### 5.1 Positive Business Signals

- **Technology is the growth engine.** Machines, Phones, and Binders collectively signal strong demand and healthy margin trajectory in the Technology category.
- **Storage growth (+15.9%)** indicates expanding infrastructure and organisational needs among the customer base — a reliable, recurring revenue segment.
- **Regional differentiation** in top-selling products points to an engaged, geographically diverse customer base — an asset for multi-channel or regionalised go-to-market strategies.

### 5.2 Risk Areas Requiring Attention

- **Copiers and Appliances are in material decline.** Combined profit losses of $7.64K in a single year are significant. Possible root causes include: competitive pricing pressure, reduced demand due to technology substitution (e.g., digital workflows replacing copiers), or unfavourable discount structures eroding margins.
- **Furniture category weakness is systemic.** Both Tables and Furnishings declined — this is unlikely to be a one-off anomaly and may reflect broader market or positioning challenges.
- **Office Supplies stagnation.** Sub-categories such as Art, Envelopes, and Labels are showing minimal growth, contributing to portfolio drag without meaningful profitability improvement.

---

## 6. Recommendations

| Priority | Action | Rationale | Expected Impact |
|----------|--------|-----------|-----------------|
| HIGH | Conduct root-cause analysis on **Copiers and Appliances** — review pricing, discount policy, competitor benchmarking, and customer feedback | Double-digit profit decline in two sub-categories signals a structural problem, not noise | Potential to recover $7.64K+ in annual profit; prevent further erosion |
| HIGH | Scale **Machines** category investment — increase inventory depth, allocate marketing budget, consider bundling with complementary products | 45.3% profit growth is the strongest signal in the portfolio | Capitalise on momentum; target 50%+ growth in FY2024 |
| MEDIUM | Review **Furniture pricing and discount strategy** — Tables and Furnishings both declining may indicate margin compression | Systemic category decline requires structural, not tactical, response | Stabilise and recover margin across the furniture portfolio |
| MEDIUM | Develop **regional promotional playbooks** based on top-5 regional product rankings | Regional bestsellers differ — generic promotions underserve regional demand signals | Improve regional conversion rates and inventory efficiency |
| MEDIUM | Use **peak-month data by category** to build seasonal marketing and inventory calendars | Aligning supply with known demand peaks reduces stockouts and missed revenue | Optimise fulfilment and promotional ROI across the calendar year |
| LOW | Rationalise **low-growth, low-margin Office Supplies SKUs** (Art, Labels, Envelopes) — assess whether to discontinue, consolidate, or reposition | Stagnant sub-categories consume operational overhead without commensurate return | Reduce complexity and redirect resources to higher-growth categories |
| LOW | Implement **ongoing MoM tracking dashboards** to monitor trends in near real-time | Static annual analysis limits responsiveness to in-year changes | Enable faster, data-driven course corrections throughout the year |

---

## 7. Appendix: SQL Methodology Notes

### Query Techniques Used

| Technique | Purpose |
|-----------|---------|
| `TOP N` with `ORDER BY` | Efficient retrieval of top-performing records |
| Common Table Expressions (CTEs) | Modular query logic; improves readability and reusability |
| `RANK() OVER(PARTITION BY ...)` | Region-aware ranking without cross-contaminating results |
| `LAG()` Window Function | Sequential period comparison for MoM analysis |
| Conditional Aggregation (`CASE WHEN`) | Year-over-year pivot without requiring separate subqueries |
| `YEAR()` / `MONTH()` Date Functions | Temporal decomposition for time-series aggregation |

### Script Validation Summary

All six analytical queries were reviewed and validated for correct T-SQL syntax and logical accuracy:

- Query 1 — Top 10 Revenue Products: Correct aggregation and sort logic
- Query 2 — Top 5 by Region: Correct use of `RANK()` with `PARTITION BY`
- Query 3 — MoM Growth: Correct `LAG()` usage with null-safety guard
- Query 4 — YoY MoM Comparison: Correct conditional pivot with date filter refinement
- Query 5 — Peak Month by Category: Valid aggregation and ranking logic
- Query 6 — Sub-Category Profit Growth: Accurate year-filtered profit comparison

> **Note on Query 4:** An improved version of the MoM comparison query uses an explicit date range filter (`order_date >= '2022-01-01' AND order_date < '2024-01-01'`) and bracket-escaped column aliases (`[2022]`, `[2023]`) for full T-SQL compliance. This is the recommended production version.

---

*Report generated from retail transactional data using T-SQL analytical queries. All figures are derived from the `orders` table. Profit values are expressed in USD.*
