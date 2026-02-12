CREATE TABLE ORDERS (
Category VARCHAR(50),
City VARCHAR(100),
Country	VARCHAR(100),
Customer_ID	VARCHAR(50) NOT NULL,
Customer_Name VARCHAR(100),
Discount DECIMAL(5, 2),
Market VARCHAR(50),
Order_Date DATE NOT NULL,
Order_ID VARCHAR(50) NOT NULL,
Order_Priority VARCHAR(20),
Product_ID VARCHAR(50) NOT NULL,
Product_Name VARCHAR(200),
Profit	DECIMAL(10, 2),
Quantity INTEGER,
Region VARCHAR(50),
Row_ID INTEGER PRIMARY KEY,
Sales DECIMAL(10, 2),
Segment	VARCHAR(50),
Ship_Date  DATE NOT NULL,
Ship_Mode VARCHAR(50),
Shipping_Cost DECIMAL(10, 2),
State VARCHAR(100),
Sub_Category VARCHAR(50),
Year INTEGER,
weeknum INTEGER
)

select * from orders
limit 5;

-- Create indexes for better query performance
CREATE INDEX idx_order_date ON orders(order_date);
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_product_id ON orders(product_id);
CREATE INDEX idx_category ON orders(category);
CREATE INDEX idx_region ON orders(region);


-- QUERY 1: Overall Sales Performance Metrics
-- Purpose: Get a high-level overview of business performance
-- -----------------------------------------------------
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT product_id) AS total_products,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND(AVG(sales)::NUMERIC, 2) AS avg_order_value,
    SUM(quantity) AS total_units_sold
FROM orders;

-- QUERY 2: Sales Performance by Category
-- Purpose: Identify which product categories generate the most revenue and profit
-- -----------------------------------------------------
SELECT 
    category,
    COUNT(DISTINCT order_id) AS num_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND(AVG(sales)::NUMERIC, 2) AS avg_sale_amount
FROM orders
GROUP BY category
ORDER BY total_sales DESC;

-- QUERY 3: Top 10 Most Profitable Products
-- Purpose: Identify star products that drive profitability
-- -----------------------------------------------------
SELECT 
    product_name,
    category,
    sub_category,
    COUNT(*) AS times_ordered,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND(AVG(discount)::NUMERIC, 2) AS avg_discount
FROM orders
GROUP BY product_name, category, sub_category
ORDER BY total_profit DESC
LIMIT 10;

-- QUERY 4: Bottom 10 Products by Profit (Loss-Making Products)
-- Purpose: Identify products that are causing losses
-- -----------------------------------------------------
SELECT 
    product_name,
    category,
    sub_category,
    COUNT(*) AS times_ordered,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND(AVG(discount)::NUMERIC, 2) AS avg_discount
FROM orders
GROUP BY product_name, category, sub_category
ORDER BY total_profit ASC
LIMIT 10;

-- QUERY 5: Sales Trends by Year and Month
-- Purpose: Understand seasonality and growth patterns
-- -----------------------------------------------------
SELECT 
    year,
    EXTRACT(MONTH FROM order_date) AS month,
    TO_CHAR(order_date, 'Month') AS month_name,
    COUNT(DISTINCT order_id) AS num_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit
FROM orders
GROUP BY year, EXTRACT(MONTH FROM order_date), TO_CHAR(order_date, 'Month')
ORDER BY year, EXTRACT(MONTH FROM order_date);

-- QUERY 6: Geographic Performance Analysis
-- Purpose: Identify best and worst performing regions/countries
-- -----------------------------------------------------
SELECT 
    market,
    region,
    country,
    COUNT(DISTINCT customer_id) AS num_customers,
    COUNT(DISTINCT order_id) AS num_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
GROUP BY market, region, country
ORDER BY total_sales DESC
LIMIT 20;

-- QUERY 7: Customer Segmentation Analysis
-- Purpose: Compare performance across different customer segments
-- -----------------------------------------------------
SELECT 
    segment,
    COUNT(DISTINCT customer_id) AS num_customers,
    COUNT(DISTINCT order_id) AS num_orders,
    ROUND(AVG(sales)::NUMERIC, 2) AS avg_order_value,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
GROUP BY segment
ORDER BY total_sales DESC;

-- -----------------------------------------------------
-- QUERY 8: Top 20 Customers by Revenue
-- Purpose: Identify most valuable customers for retention strategies
-- -----------------------------------------------------
SELECT 
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id) AS num_orders,
    SUM(quantity) AS total_items_purchased,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_spent,
    ROUND(SUM(profit)::NUMERIC, 2) AS profit_generated,
    ROUND(AVG(sales)::NUMERIC, 2) AS avg_order_value,
    MAX(order_date) AS last_order_date
FROM orders
GROUP BY customer_id, customer_name, segment
ORDER BY total_spent DESC
LIMIT 20;

-- -----------------------------------------------------
-- QUERY 9: Shipping Mode Analysis
-- Purpose: Compare efficiency and profitability of different shipping methods
-- -----------------------------------------------------
SELECT 
    ship_mode,
    COUNT(DISTINCT order_id) AS num_orders,
    ROUND(AVG(ship_date - order_date)::NUMERIC, 1) AS avg_shipping_days,
    ROUND(AVG(shipping_cost)::NUMERIC, 2) AS avg_shipping_cost,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
GROUP BY ship_mode
ORDER BY num_orders DESC;

-- -----------------------------------------------------
-- QUERY 10: Discount Impact Analysis
-- Purpose: Understand how discounts affect profitability
-- -----------------------------------------------------
SELECT 
    CASE 
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount > 0 AND discount <= 0.1 THEN '1-10% Discount'
        WHEN discount > 0.1 AND discount <= 0.2 THEN '11-20% Discount'
        WHEN discount > 0.2 AND discount <= 0.3 THEN '21-30% Discount'
        WHEN discount > 0.3 THEN '30%+ Discount'
    END AS discount_range,
    COUNT(*) AS num_transactions,
    ROUND(AVG(discount)::NUMERIC, 3) AS avg_discount,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct
FROM orders
GROUP BY 
    CASE 
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount > 0 AND discount <= 0.1 THEN '1-10% Discount'
        WHEN discount > 0.1 AND discount <= 0.2 THEN '11-20% Discount'
        WHEN discount > 0.2 AND discount <= 0.3 THEN '21-30% Discount'
        WHEN discount > 0.3 THEN '30%+ Discount'
    END
ORDER BY avg_discount;

-- -----------------------------------------------------
-- QUERY 11: Sub-Category Performance Deep Dive
-- Purpose: Detailed analysis of product sub-categories
-- -----------------------------------------------------
SELECT 
    category,
    sub_category,
    COUNT(DISTINCT order_id) AS num_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND(AVG(discount)::NUMERIC, 3) AS avg_discount_rate
FROM orders
GROUP BY category, sub_category
ORDER BY total_profit DESC;

-- -----------------------------------------------------
-- QUERY 12: Year-over-Year Growth Analysis
-- Purpose: Calculate growth rates to measure business trajectory
-- -----------------------------------------------------
WITH yearly_metrics AS (
    SELECT 
        year,
        ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
        ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
        COUNT(DISTINCT order_id) AS num_orders
    FROM orders
    GROUP BY year
)
SELECT 
    year,
    total_sales,
    total_profit,
    num_orders,
    ROUND(((total_sales - LAG(total_sales) OVER (ORDER BY year)) / 
           NULLIF(LAG(total_sales) OVER (ORDER BY year), 0) * 100)::NUMERIC, 2) AS sales_growth_pct,
    ROUND(((total_profit - LAG(total_profit) OVER (ORDER BY year)) / 
           NULLIF(LAG(total_profit) OVER (ORDER BY year), 0) * 100)::NUMERIC, 2) AS profit_growth_pct
FROM yearly_metrics
ORDER BY year;

-- -----------------------------------------------------
-- QUERY 13: Customer Retention Analysis
-- Purpose: Identify repeat customers vs one-time buyers
-- -----------------------------------------------------
WITH customer_orders AS (
    SELECT 
        customer_id,
        customer_name,
        COUNT(DISTINCT order_id) AS num_orders,
        ROUND(SUM(sales)::NUMERIC, 2) AS total_spent
    FROM orders
    GROUP BY customer_id, customer_name
)
SELECT 
    CASE 
        WHEN num_orders = 1 THEN 'One-time Customer'
        WHEN num_orders BETWEEN 2 AND 5 THEN 'Occasional Customer (2-5 orders)'
        WHEN num_orders BETWEEN 6 AND 10 THEN 'Regular Customer (6-10 orders)'
        WHEN num_orders > 10 THEN 'Loyal Customer (10+ orders)'
    END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(AVG(num_orders)::NUMERIC, 1) AS avg_orders,
    ROUND(SUM(total_spent)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(total_spent)::NUMERIC, 2) AS avg_customer_value
FROM customer_orders
GROUP BY 
    CASE 
        WHEN num_orders = 1 THEN 'One-time Customer'
        WHEN num_orders BETWEEN 2 AND 5 THEN 'Occasional Customer (2-5 orders)'
        WHEN num_orders BETWEEN 6 AND 10 THEN 'Regular Customer (6-10 orders)'
        WHEN num_orders > 10 THEN 'Loyal Customer (10+ orders)'
    END
ORDER BY avg_orders DESC;

-- -----------------------------------------------------
-- QUERY 14: High-Value Order Analysis
-- Purpose: Identify patterns in large transactions
-- -----------------------------------------------------
SELECT 
    order_id,
    customer_name,
    segment,
    category,
    region,
    order_date,
    ROUND(SUM(sales)::NUMERIC, 2) AS order_value,
    ROUND(SUM(profit)::NUMERIC, 2) AS order_profit,
    COUNT(*) AS items_in_order
FROM orders
WHERE order_id IN (
    -- Find orders with total value > $10,000
    SELECT order_id
    FROM orders
    GROUP BY order_id
    HAVING SUM(sales) > 10000
)
GROUP BY order_id, customer_name, segment, category, region, order_date
ORDER BY order_value DESC;

-- -----------------------------------------------------
-- QUERY 15: Product Performance Matrix
-- Purpose: Categorize products into performance quadrants
-- -----------------------------------------------------
WITH product_metrics AS (
    SELECT 
        product_name,
        category,
        sub_category,
        ROUND(SUM(sales)::NUMERIC, 2) AS total_sales,
        ROUND(SUM(profit)::NUMERIC, 2) AS total_profit,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct
    FROM orders
    GROUP BY product_name, category, sub_category
),
thresholds AS (
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_sales) AS median_sales,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY profit_margin_pct) AS median_margin
    FROM product_metrics
)
SELECT 
    p.product_name,
    p.category,
    p.sub_category,
    p.total_sales,
    p.total_profit,
    p.profit_margin_pct,
    CASE 
        WHEN p.total_sales > t.median_sales AND p.profit_margin_pct > t.median_margin 
            THEN 'Star Products (High Sales, High Margin)'
        WHEN p.total_sales > t.median_sales AND p.profit_margin_pct <= t.median_margin 
            THEN 'Cash Cows (High Sales, Low Margin)'
        WHEN p.total_sales <= t.median_sales AND p.profit_margin_pct > t.median_margin 
            THEN 'Niche Winners (Low Sales, High Margin)'
        ELSE 'Underperformers (Low Sales, Low Margin)'
    END AS product_category
FROM product_metrics p
CROSS JOIN thresholds t
ORDER BY p.total_sales DESC;

-- =====================================================
-- END OF SQL ANALYSIS PROJECT
-- =====================================================