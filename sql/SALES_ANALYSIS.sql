create database global_sales;
use global_sales;
CREATE TABLE orders (
    Row_ID INT,
    Order_ID VARCHAR(30),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(30),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Postal_Code VARCHAR(20),
    Market VARCHAR(50),
    Region VARCHAR(50),
    Product_ID VARCHAR(50),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(255),
    Sales DECIMAL(12,3),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(12,3),
    Shipping_Cost DECIMAL(12,3),
    Order_Priority VARCHAR(50)
);

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
LOAD DATA LOCAL INFILE 'FILE PATH'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    Row_ID,
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Customer_Name,
    Segment,
    City,
    State,
    Country,
    Postal_Code,
    Market,
    Region,
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    Sales,
    Quantity,
    Discount,
    Profit,
    Shipping_Cost,
    Order_Priority
);
SELECT COUNT(*) AS total_rows;
SELECT COUNT(*) FROM orders;

CREATE TABLE people (
    Person VARCHAR(100),
    Region VARCHAR(50)
);
CREATE TABLE returns (
    Returned VARCHAR(10),
    `Order ID` VARCHAR(30),
    Market VARCHAR(50)
);
select * from orders;
select * from returns;
select * from people;

-- Data Quality Checks
-- Are there NULL values in key numeric fields?
select
    sum(sales is null) as null_sales,
    sum(quantity is null) as null_quantity,
    sum(discount is null) as null_discount,
    sum(profit is null) as null_profit,
    sum(shipping_cost is null) as null_shipping_cost
from orders;
-- Are there duplicate rows?
select row_id, count(*) as duplicate_count
from orders
group by row_id
having count(*) > 1;
-- Are there orders with negative sales or invalid (≤0) quantity?
select *
from orders
where sales < 0 or quantity <= 0;


-- Module 1: Core KPIs
-- What is the total sales, profit, and quantity sold?
select sum(Sales) as total_sales
from orders;
select sum(Profit) as total_profit
from orders;
select sum(Quantity) as total_quantity
from orders;
-- What is the average order value?
select sum(Sales) / count(distinct Order_ID) average_order_value
from orders;
-- what is the Total Orders?
select count(distinct Order_ID) as total_orders
from orders;
-- How many unique orders were placed?
select count(distinct Order_ID) from orders;

-- Module 2: Product Analysis
-- Which products generate the highest sales?
select Product_Name,sum(Sales) as total_sales
from orders
group by Product_Name order by total_sales desc limit 10;
-- Which products generate the lowest sales?
select Product_Name,sum(Sales) as total_sales
from orders
group by Product_Name order by total_sales asc limit 10;
-- Which products generate the highest profit?
select Product_Name,sum(Profit) as total_profit
from orders
group by Product_Name order by total_profit desc limit 10;
-- Which products generate losses?
select Product_Name,sum(Profit) as total_profit
from orders
group by Product_Name 
having sum(Profit)<0
order by total_profit asc limit 10;
-- Which products sell the highest quantity?
select Product_Name,sum(Quantity) as total_quantity
from orders
group by Product_Name
order by total_quantity desc limit 10;
-- Which products sell the lowest quantity?
select Product_Name,sum(Quantity) as total_quantity
from orders
group by Product_Name
order by total_quantity asc limit 10;
-- Which categories generate the highest sales?
select Category,sum(Sales) as total_sales
from orders
group by Category
order by total_sales desc;
-- Which categories generate the highest profit?
select category,sum(Profit) as total_profit
from orders
group by Category
order by total_profit desc;
-- Which sub-categories generate losses?
select Sub_Category,sum(Profit) as total_profit
from orders
group by Sub_Category
having sum(Profit) < 0
order by total_profit asc;
-- Which products have the highest discounts?
select Product_Name,sum(Discount) as total_discount
from orders
group by Product_Name
order by total_discount desc limit 10;
-- Which are the top 3 products by sales within each category? (window function)
select Category, Product_Name, total_sales, sales_rank
from (
    select
        Category,
        Product_Name,
        SUM(Sales) AS total_sales,
        rank() over (partition by Category order by SUM(Sales) desc) as sales_rank
    from orders
    group by Category, Product_Name
) ranked
where sales_rank <= 3;

-- Module 3: Customer Analysis
-- Who are the top 10 customers by sales and by profit?
select Customer_ID,Customer_Name,sum(Sales) as total_sales
from orders
group by Customer_ID,Customer_Name
order by total_sales desc
limit 10;
select Customer_ID,Customer_Name,sum(Profit) as total_profit
from orders
group by Customer_ID,Customer_Name
order by total_profit desc,Customer_Name asc
limit 10;
-- Which customers generate losses?
select Customer_ID,Customer_Name,sum(Profit) as total_profit,sum(Sales) as total_sales 
from orders
group by Customer_ID,Customer_Name
having sum(Profit)<0
order by total_profit asc
limit 10;
-- Which customer segment contributes the highest sales/profit?
select Segment,sum(Sales) as total_sales
from orders
group by Segment
order by total_sales desc
limit 10;
select Segment,sum(Profit) as total_profit
from orders
group by Segment
order by total_profit desc
limit 10;
-- Which customers place the most orders?
select Customer_Name,Customer_ID,count(Order_ID) no_of_orders
from orders
group by Customer_ID,Customer_Name
order by no_of_orders desc
limit 10;
-- Which customers receive the highest discounts?
select Customer_Name,Customer_ID,sum(Discount) no_of_discounts
from orders
group by Customer_ID,Customer_Name
order by no_of_discounts desc
limit 10;
-- Which customers have the highest Average Order Value?
select Customer_Name,Customer_ID, sum(Sales)/count(Order_ID) aov
from orders
group by Customer_ID,Customer_Name
order by aov desc
limit 10;
-- Which customers ordered from more than one market?
select 
    Customer_ID, 
    Customer_Name, 
    count(distinct Market) as markets_used
from orders
group by Customer_ID, Customer_Name
having COUNT(distinct Market) > 1
order by  markets_used desc;
-- What % of total company sales does each customer contribute? (window function)
select 
    Customer_ID, 
    Customer_Name,
    sum(Sales) as customer_sales,
    round(sum(Sales) * 100.0 / sum(sum(Sales)) over (), 2) as pct_of_total_sales
from orders
group by  Customer_ID, Customer_Name
order by customer_sales desc;

-- Module 4: Regional Analysis
-- Which market generates the highest sales?
select Market,sum(Sales) as total_sales
from orders
group by Market
order by total_sales desc
limit 1;
-- Which region has the highest sales?
select Region,sum(Sales) total_sales
from orders
group by Region
order by total_sales desc;
-- Which country has the highest sales?
select Country,sum(Sales) total_sales
from orders
group by Country
order by total_sales desc
limit 10;
-- Which state has the highest sales?
select State,sum(Sales) total_sales
from orders
group by State
order by total_sales desc
limit 10;
-- Which city has the highest sales?
select City,sum(Sales) total_sales
from orders
group by City
order by total_sales desc
limit 10;
-- Which market generates the highest profit?
select Market,sum(Profit) as total_profit
from orders
group by Market
order by total_profit desc
limit 1;
-- Which region has the highest profit?
select Region,sum(Profit) total_profit
from orders
group by Region
order by total_profit desc
limit 10;
-- Which country has the highest profit?
select Country,sum(Profit) total_profit
from orders
group by Country
order by total_profit desc
limit 10;
-- Which state has the highest profit?
select State,sum(Profit) total_profit
from orders
group by State
order by total_profit desc
limit 10;
-- Which cities are generating losses?
select City,sum(Profit) total_profit
from orders
group by City
having sum(Profit)<0
order by total_profit asc
limit 10;
-- Which salesperson is responsible for each region? (uses People table)
select 
    o.region, 
    p.person, 
    sum(o.sales) as total_sales, 
    sum(o.profit) as total_profit
from orders o
left join people p on o.region = p.region
group by o.region, p.person
order by total_sales desc;
-- Which salesperson manages the most profitable region?
select 
    p.person, 
    sum(o.profit) as total_profit
from orders o
join people p on o.region = p.region
group by p.person
order by total_profit desc;

-- Module 5: Discount Analysis
-- Which products receive the highest discounts?
select Product_ID,Product_Name,avg(Discount) avg_discount
from orders
group by Product_ID,Product_Name
order by avg_discount desc
limit 10;
-- Which categories receive the highest discounts?
select Category,avg(Discount) avg_discount
from orders
group by Category
order by avg_discount desc
limit 10;
-- Does a higher discount reduce profit? -- yes discounts are reducing profits
select Discount,sum(Profit) as total_profit
from orders
group by Discount
order by total_profit desc;
-- Which regions receive the highest discounts?
select Region,sum(Discount) as discount
from orders
group by Region
order by discount desc
limit 10;
-- What is the average discount by category?
select Category,avg(Discount) avg_dis_catg
from orders
group by Category;
-- What is the average discount by product?
select Product_Name,avg(Discount) avg_dis_prod
from orders
group by Product_Name;
-- What is the average discount by region?
select Region,avg(Discount) avg_dis_region
from orders
group by Region;
-- Which products combine high discounts with losses?
select 
    Product_Name,
    round(avg(Discount), 2) as avg_discount,
    sum(Profit) as total_profit
from orders
group by Product_Name
having avg(Discount) > 0.5 and sum(Profit) < 0
order by avg_discount desc;

-- Module 6: Shipping Analysis
-- Which shipping mode is used the most?
select Ship_Mode,count(Ship_Mode) as ship_mode
from orders
group by Ship_Mode
order by ship_mode desc; 
-- Which shipping mode generates the highest sales?
select Ship_Mode,sum(Sales) as total_sales
from orders
group by Ship_Mode
order by total_sales desc; 
-- Which shipping mode generates the highest profit?
select Ship_Mode,sum(Profit) as total_profit
from orders
group by Ship_Mode
order by total_profit desc;
-- What is the average shipping cost by shipping mode?
select Ship_Mode,avg(Shipping_Cost) avg_shipping_mode_cost
from orders
group by Ship_Mode;
-- What is the average delivery time by shipping mode?
select 
    Ship_Mode,
    round(avg(datediff(Ship_Date, Order_Date)), 2) as avg_delivery_days
from orders
group by Ship_Mode
order by avg_delivery_days;
-- Which order priority contributes the highest sales?
select Order_Priority,sum(Sales) as total_sales
from orders
group by Order_Priority
order by total_sales desc
limit 10;
-- Is there a relationship between order priority and delivery time?
select 
    order_priority,
    round(avg(datediff(ship_date, order_date)), 2) as avg_delivery_days
from orders
group by order_priority
order by avg_delivery_days;

-- Module 7: Returns Analysis
-- How many orders were returned?
select count(Returned) no_of_returns
from returns;
-- What is the return rate?
select count(*)*100 /
       ( select count(distinct Order_ID)
        FROM orders) AS return_rate
FROM returns;
-- Which products are returned the most?
select o.Product_Name,count(r.`Order ID`) no_of_prod_returned
from returns as r
left join orders as o
on o.Order_ID = r.`Order ID`
group by o.Product_Name
order by no_of_prod_returned desc
limit 10;
-- Which categories have the highest return rate?
select o.Category,count(distinct r.`Order ID`)  * 100.0 / count(distinct o.Order_ID) as return_rate
from orders as o
left join returns as r
on `Order ID` = o.Order_ID
group by o.Category;
-- Which markets have the highest returns?
select Market,count(Returned) no_of_returns
from returns
group by Market
order by no_of_returns desc
limit 10;
-- Which order priority has the highest return rate?
select o.Order_Priority,count(distinct r.`Order ID`)  * 100.0 / count(distinct o.Order_ID) as return_rate
from orders as o
left join returns as r
on `Order ID` = o.Order_ID
group by o.Order_Priority;

-- Module 8: Trend & Business Insight Analysis
-- How are sales changing month by month?
select year(Order_Date) as year,month(Order_Date) as month,sum(Sales) as total_sales
from orders
group by year(Order_Date), month(Order_Date)
order by year,month asc;
-- Which year generated the highest sales?
select year(Order_Date) as year,sum(Sales) as total_sales
from orders
group by year(Order_Date)
order by total_sales desc
limit 1;
-- Which month generated the highest sales?
select year(Order_Date) as year,month(Order_Date) as month,sum(Sales) as total_sales
from orders
group by  year(Order_Date),month(Order_Date)
order by total_sales desc
limit 1;
-- Products with high sales but low profit
select Product_Name,sum(Sales) total_sales,sum(Profit) as total_profit
from orders
group by Product_Name
having sum(Sales)>0 and sum(Profit)<=0
order by total_sales desc
limit 10;
-- Which categories are actually profitable?
select Category,sum(Profit) / sum(Sales) * 100 as profit_margin
from orders
group by Category
order by profit_margin desc;
-- Are discounts causing losses?
select 
    Product_Name,
    avg(Discount) AS avg_discount,
    sum(Profit) AS total_profit
from orders
group by Product_Name
having avg(Discount) > 0.5 
   and sum(Profit) < 0
order by avg_discount desc;
-- Which products are returned most compared to total sales?
select 
    o.Product_Name,
    count(distinct r.`Order ID`) * 100.0 / count(distinct o.Order_ID) as return_rate
from orders o
left join returns r
on o.Order_ID = r.`Order ID`
group by o.Product_Name
order by return_rate desc
limit 10;
-- Which shipping mode takes more time?
select Ship_Mode,round(avg(datediff(Ship_Date,Order_Date))) as avg_delivery_days
from orders
group by Ship_Mode
order by avg_delivery_days;
-- What is the year-over-year sales growth %? (window function)
select 
    yr,
    yearly_sales,
    lag(yearly_sales) over (order by yr) as prev_year_sales,
    round(
        (yearly_sales - lag(yearly_sales) over (order by yr)) 
        / lag(yearly_sales) over (order by yr) * 100, 2
    ) as yoy_growth_pct
from (
    select year(order_date) as yr, sum(sales) as yearly_sales
    from orders
    group by year(order_date)
) yearly;
-- What is the running cumulative monthly sales total? (window function)
select 
    yr, mo, monthly_sales,
    sum(monthly_sales) over (order by yr, mo) as running_total_sales
from (
    select year(order_date) as yr, month(order_date) as mo, sum(sales) as monthly_sales
    from orders
    group by yr, mo
) monthly;
-- What % of total profit does each market contribute?
select 
    market,
    sum(profit) as market_profit,
    round(sum(profit) * 100.0 / sum(sum(profit)) over (), 2) as pct_of_total_profit
from orders
group by market
order by market_profit desc;


