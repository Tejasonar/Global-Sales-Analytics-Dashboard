🌍 Global Sales Analytics Dashboard

End-to-end sales analytics project on the Global Superstore dataset — cleaned in Excel,
analyzed in MySQL, and visualized in an interactive Power BI dashboard.

== Overview

A global superstore sells across 7 markets (US, APAC, EU, LATAM, EMEA, Africa, Canada)
but lacked visibility into where it's profitable, which products/customers/regions
drive value, and whether discounting and shipping practices help or hurt the bottom
line. This project analyzes **51,290 order line items (25,035 unique orders)**
spanning 2011–2014 to uncover sales and profit trends, flag loss-making products and
regions, and evaluate the impact of discounts, shipping, and returns — delivered
through a 5-page interactive Power BI dashboard for quick, data-driven decisions.

Total Sales:$12.64M | Total Profit:$1.47M | Profit Margin:11.6%

== Tech Stack
- Excel — initial data inspection and cleaning
- MySQL — schema design across 3 relational tables, data loading, and **70 analytical queries** (aggregations, multi-table joins, subqueries, window functions)
- Power BI — 5-page interactive dashboard with DAX measures, geo-visuals, and drill-through

== Dataset

| Table | Rows   | Description |
|-------|-----------------------------|
|orders | 51,290 | Order, customer, product,
|       |        |  sales, profit, shipping & discount details |
|returns| 1,173  | Returned order IDs by market |
|people | 13     | Region-to-salesperson mapping |

== Analysis Modules (70 SQL queries)

1. Data Quality Checks — NULL checks, duplicate detection, invalid value checks
2. Core KPIs — total sales, profit, AOV, order volume
3. Product Analysis — top/bottom performers, loss-making products, category margins, top-3-per-category ranking *(window function)*
4. Customer Analysis — top customers, loss-making accounts, segment contribution, % of total sales per customer *(window function)*, multi-market customers
5. Regional Analysis — performance by market/region/country/state/city, salesperson-per-region *(People table join)*
6. Discount Analysis — discount-profit correlation, over-discounted products
7. Shipping Analysis — delivery speed and cost by shipping mode, priority vs. delivery time
8. Returns Analysis — return rate by product, category, market, and order priority *(Returns table join)*
9. Trend Analysis — YoY growth *(window function)*, running cumulative sales *(window function)*, category and market profitability

== Key Findings
- Technology** is the top category by both sales and margin (14.0%).
- Furniture sells well but has the weakest margin (6.9%).
- APAC is the leading market by sales and profit.
- EMEA has a disproportionately weak margin.
- Discounting has a measurable negative correlation with profit (-0.32) — several SKUs lose money despite high sales volume.
- Standard Class shipping is both the most-used and slowest mode (~5 days avg); delivery speed scales directly with order priority (Critical: 1.8 days → Low: 6.5 days).
- Overall return rate is 4.7% of unique orders.


== Dashboard Preview
The dashboard has 5 pages: Executive Overview, Product Performance, Customer Analysis,Regional Analysis, and Shipping & Returns.
![Image Alt Text](https://github.com/Tejasonar/Global-Sales-Analytics-Dashboard/blob/3a02b2c7a7e30c28e3a88e90191a8afc4d7e19bf/Executive_Sales_Overview_(page_1).png)


==  How to Use
1. Run the schema + `LOAD DATA INFILE` section in `sql/global_sales_analysis.sql` to populate `orders`
2. Import `People.csv` and `Returns.csv` into their tables via MySQL Workbench's Table Data Import Wizard
3. Run the analysis queries module by module
4. Open `powerbi/GLOBAL_SALES_ANALYSIS.pbix` in Power BI Desktop to explore the dashboard

== Future Enhancements
- Sales forecasting (Power BI forecasting or Python/ARIMA)
- Automated ETL with Power Query or a Python pipeline
- Customer segmentation (RFM analysis)

