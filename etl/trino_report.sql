CREATE TABLE clickhouse.dwh.mart_product_top10_by_quantity AS
SELECT
    dp.product_name,
    dp.product_category,
    dp.product_brand,
    SUM(fs.sale_quantity)    AS total_quantity,
    SUM(fs.sale_total_price) AS total_revenue,
    AVG(fs.sale_total_price) AS avg_order_price
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_product dp ON fs.product_id = dp.id
GROUP BY dp.product_name, dp.product_category, dp.product_brand
LIMIT 10;

CREATE TABLE clickhouse.dwh.mart_product_revenue_by_category AS
SELECT
    dp.product_category,
    COUNT(DISTINCT fs.id)    AS total_orders,
    SUM(fs.sale_quantity)    AS total_quantity,
    SUM(fs.sale_total_price) AS total_revenue,
    AVG(dp.product_price)    AS avg_product_price
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_product dp ON fs.product_id = dp.id
GROUP BY dp.product_category;

CREATE TABLE clickhouse.dwh.mart_product_ratings AS
SELECT
    dp.product_name,
    dp.product_category,
    dp.product_brand,
    dp.product_rating,
    dp.product_reviews,
    SUM(fs.sale_quantity)    AS total_quantity_sold,
    SUM(fs.sale_total_price) AS total_revenue
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_product dp ON fs.product_id = dp.id
GROUP BY
    dp.product_name,
    dp.product_category,
    dp.product_brand,
    dp.product_rating,
    dp.product_reviews;

CREATE TABLE clickhouse.dwh.mart_customer_top10_by_revenue AS
SELECT
    dc.customer_first_name,
    dc.customer_last_name,
    dc.customer_email,
    dc.customer_country,
    COUNT(DISTINCT fs.id)    AS total_orders,
    SUM(fs.sale_quantity)    AS total_quantity,
    SUM(fs.sale_total_price) AS total_spent,
    AVG(fs.sale_total_price) AS avg_order_value
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_customer dc ON fs.customer_id = dc.id
GROUP BY
    dc.customer_first_name,
    dc.customer_last_name,
    dc.customer_email,
    dc.customer_country
LIMIT 10;

CREATE TABLE clickhouse.dwh.mart_customer_by_country AS
SELECT
    dc.customer_country,
    COUNT(DISTINCT dc.id)    AS total_customers,
    COUNT(DISTINCT fs.id)    AS total_orders,
    SUM(fs.sale_total_price) AS total_revenue,
    AVG(fs.sale_total_price) AS avg_order_value
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_customer dc ON fs.customer_id = dc.id
GROUP BY dc.customer_country;

CREATE TABLE clickhouse.dwh.mart_customer_avg_check AS
SELECT
    dc.customer_email,
    dc.customer_first_name,
    dc.customer_last_name,
    dc.customer_country,
    dc.customer_age,
    COUNT(DISTINCT fs.id)    AS total_orders,
    SUM(fs.sale_total_price) AS total_spent,
    AVG(fs.sale_total_price) AS avg_check,
    SUM(fs.sale_quantity)    AS total_items_bought
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_customer dc ON fs.customer_id = dc.id
GROUP BY
    dc.customer_email,
    dc.customer_first_name,
    dc.customer_last_name,
    dc.customer_country,
    dc.customer_age;

CREATE TABLE clickhouse.dwh.mart_time_monthly_trends AS
SELECT
    SUBSTR(from_utf8(dp.sale_date), 1, 4) AS sale_year,
    SUBSTR(from_utf8(dp.sale_date), 6, 2) AS sale_month,
    CONCAT(
        SUBSTR(from_utf8(dp.sale_date), 1, 4),
        '-',
        SUBSTR(from_utf8(dp.sale_date), 6, 2)
    ) AS year_month,
    COUNT(DISTINCT fs.id)      AS total_orders,
    SUM(fs.sale_quantity)      AS total_quantity,
    SUM(fs.sale_total_price)   AS total_revenue
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_product dp
    ON fs.product_id = dp.id
WHERE dp.sale_date IS NOT NULL
GROUP BY
    SUBSTR(from_utf8(dp.sale_date), 1, 4),
    SUBSTR(from_utf8(dp.sale_date), 6, 2),
    CONCAT(
        SUBSTR(from_utf8(dp.sale_date), 1, 4),
        '-',
        SUBSTR(from_utf8(dp.sale_date), 6, 2)
    );

CREATE TABLE clickhouse.dwh.mart_time_yearly_revenue AS
SELECT
    SUBSTR(dp.sale_date, 1, 4)  AS sale_year,
    COUNT(DISTINCT fs.id)       AS total_orders,
    SUM(fs.sale_quantity)       AS total_quantity,
    SUM(fs.sale_total_price)    AS total_revenue,
    AVG(fs.sale_total_price)    AS avg_order_value
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_product dp ON fs.product_id = dp.id
WHERE dp.sale_date IS NOT NULL
GROUP BY SUBSTR(dp.sale_date, 1, 4);

CREATE TABLE clickhouse.dwh.mart_time_avg_order_by_month AS
SELECT
    SUBSTR(dp.sale_date, 6, 2)  AS sale_month,
    COUNT(DISTINCT fs.id)       AS total_orders,
    AVG(fs.sale_quantity)       AS avg_quantity_per_order,
    AVG(fs.sale_total_price)    AS avg_revenue_per_order,
    SUM(fs.sale_total_price)    AS total_revenue
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_product dp ON fs.product_id = dp.id
WHERE dp.sale_date IS NOT NULL
GROUP BY SUBSTR(dp.sale_date, 6, 2);

CREATE TABLE clickhouse.dwh.mart_store_top5_by_revenue AS
SELECT
    dst.store_name,
    dst.store_city,
    dst.store_country,
    dst.store_email,
    COUNT(DISTINCT fs.id)    AS total_orders,
    SUM(fs.sale_quantity)    AS total_quantity,
    SUM(fs.sale_total_price) AS total_revenue,
    AVG(fs.sale_total_price) AS avg_check
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_store dst ON fs.store_id = dst.id
GROUP BY
    dst.store_name,
    dst.store_city,
    dst.store_country,
    dst.store_email
LIMIT 5;

CREATE TABLE clickhouse.dwh.mart_store_by_geography AS
SELECT
    dst.store_country,
    dst.store_city,
    COUNT(DISTINCT dst.id)   AS total_stores,
    COUNT(DISTINCT fs.id)    AS total_orders,
    SUM(fs.sale_quantity)    AS total_quantity,
    SUM(fs.sale_total_price) AS total_revenue
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_store dst ON fs.store_id = dst.id
GROUP BY dst.store_country, dst.store_city;

CREATE TABLE clickhouse.dwh.mart_store_avg_check AS
SELECT
    dst.store_name,
    dst.store_city,
    dst.store_country,
    COUNT(DISTINCT fs.id)    AS total_orders,
    SUM(fs.sale_total_price) AS total_revenue,
    AVG(fs.sale_total_price) AS avg_check,
    SUM(fs.sale_quantity)    AS total_quantity
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_store dst ON fs.store_id = dst.id
GROUP BY dst.store_name, dst.store_city, dst.store_country;

CREATE TABLE clickhouse.dwh.mart_supplier_top5_by_revenue AS
SELECT
    dsp.supplier_name,
    dsp.supplier_country,
    dsp.supplier_email,
    COUNT(DISTINCT fs.id)    AS total_orders,
    SUM(fs.sale_quantity)    AS total_quantity,
    SUM(fs.sale_total_price) AS total_revenue,
    AVG(dp.product_price)    AS avg_product_price
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_store dst   ON fs.store_id    = dst.id
JOIN clickhouse.dwh.dim_supplier dsp ON dst.store_supplier_id = dsp.id
JOIN clickhouse.dwh.dim_product dp  ON fs.product_id  = dp.id
GROUP BY dsp.supplier_name, dsp.supplier_country, dsp.supplier_email
LIMIT 5;

CREATE TABLE clickhouse.dwh.mart_supplier_avg_price AS
SELECT
    dsp.supplier_name,
    dsp.supplier_country,
    dsp.supplier_city,
    COUNT(DISTINCT dp.id)    AS total_products,
    AVG(dp.product_price)    AS avg_product_price,
    MIN(dp.product_price)    AS min_product_price,
    MAX(dp.product_price)    AS max_product_price,
    SUM(fs.sale_total_price) AS total_revenue
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_store dst    ON fs.store_id          = dst.id
JOIN clickhouse.dwh.dim_supplier dsp ON dst.store_supplier_id = dsp.id
JOIN clickhouse.dwh.dim_product dp   ON fs.product_id         = dp.id
GROUP BY dsp.supplier_name, dsp.supplier_country, dsp.supplier_city;

CREATE TABLE clickhouse.dwh.mart_supplier_by_country AS
SELECT
    dsp.supplier_country,
    COUNT(DISTINCT dsp.id)   AS total_suppliers,
    COUNT(DISTINCT fs.id)    AS total_orders,
    SUM(fs.sale_quantity)    AS total_quantity,
    SUM(fs.sale_total_price) AS total_revenue
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_store dst    ON fs.store_id          = dst.id
JOIN clickhouse.dwh.dim_supplier dsp ON dst.store_supplier_id = dsp.id
GROUP BY dsp.supplier_country;

CREATE TABLE clickhouse.dwh.mart_quality_ratings_extremes AS
SELECT
    dp.product_name,
    dp.product_category,
    dp.product_brand,
    dp.product_rating,
    dp.product_reviews,
    SUM(fs.sale_quantity)    AS total_sold,
    SUM(fs.sale_total_price) AS total_revenue
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_product dp ON fs.product_id = dp.id
GROUP BY
    dp.product_name,
    dp.product_category,
    dp.product_brand,
    dp.product_rating,
    dp.product_reviews;

CREATE TABLE clickhouse.dwh.mart_quality_rating_vs_sales AS
SELECT
    ROUND(CAST(dp.product_rating AS DECIMAL(4,1)), 1) AS rating_bucket,
    COUNT(DISTINCT dp.id)                             AS products_count,
    SUM(fs.sale_quantity)                             AS total_quantity_sold,
    SUM(fs.sale_total_price)                          AS total_revenue,
    AVG(fs.sale_total_price)                          AS avg_revenue_per_order
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_product dp ON fs.product_id = dp.id
WHERE dp.product_rating IS NOT NULL
GROUP BY ROUND(CAST(dp.product_rating AS DECIMAL(4,1)), 1);

CREATE TABLE clickhouse.dwh.mart_quality_most_reviewed AS
SELECT
    dp.product_name,
    dp.product_category,
    dp.product_brand,
    dp.product_reviews,
    dp.product_rating,
    SUM(fs.sale_quantity)    AS total_sold,
    SUM(fs.sale_total_price) AS total_revenue
FROM clickhouse.dwh.fact_sales fs
JOIN clickhouse.dwh.dim_product dp ON fs.product_id = dp.id
GROUP BY
    dp.product_name,
    dp.product_category,
    dp.product_brand,
    dp.product_reviews,
    dp.product_rating
LIMIT 20;


SELECT count(*) FROM clickhouse.dwh.mart_product_top10_by_quantity;
SELECT count(*) FROM clickhouse.dwh.mart_product_revenue_by_category;
SELECT count(*) FROM clickhouse.dwh.mart_product_ratings;
SELECT count(*) FROM clickhouse.dwh.mart_customer_top10_by_revenue;
SELECT count(*) FROM clickhouse.dwh.mart_customer_by_country;
SELECT count(*) FROM clickhouse.dwh.mart_customer_avg_check;
SELECT count(*) FROM clickhouse.dwh.mart_time_monthly_trends;
SELECT count(*) FROM clickhouse.dwh.mart_time_yearly_revenue;
SELECT count(*) FROM clickhouse.dwh.mart_time_avg_order_by_month;
SELECT count(*) FROM clickhouse.dwh.mart_store_top5_by_revenue;
SELECT count(*) FROM clickhouse.dwh.mart_store_by_geography;
SELECT count(*) FROM clickhouse.dwh.mart_store_avg_check;
SELECT count(*) FROM clickhouse.dwh.mart_supplier_top5_by_revenue;
SELECT count(*) FROM clickhouse.dwh.mart_supplier_avg_price;
SELECT count(*) FROM clickhouse.dwh.mart_supplier_by_country;
SELECT count(*) FROM clickhouse.dwh.mart_quality_ratings_extremes;
SELECT count(*) FROM clickhouse.dwh.mart_quality_rating_vs_sales;
SELECT count(*) FROM clickhouse.dwh.mart_quality_most_reviewed;
