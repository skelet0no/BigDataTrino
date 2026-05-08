CREATE SCHEMA IF NOT EXISTS clickhouse.dwh;

CREATE TABLE clickhouse.dwh.raw_union AS
SELECT
    id,
    from_utf8(customer_first_name) AS customer_first_name,
    from_utf8(customer_last_name) AS customer_last_name,
    customer_age,
    from_utf8(customer_email) AS customer_email,
    from_utf8(customer_country) AS customer_country,
    from_utf8(customer_postal_code) AS customer_postal_code,
    from_utf8(customer_pet_type) AS customer_pet_type,
    from_utf8(customer_pet_name) AS customer_pet_name,
    from_utf8(customer_pet_breed) AS customer_pet_breed,
    from_utf8(seller_first_name) AS seller_first_name,
    from_utf8(seller_last_name) AS seller_last_name,
    from_utf8(seller_email) AS seller_email,
    from_utf8(seller_country) AS seller_country,
    from_utf8(seller_postal_code) AS seller_postal_code,
    from_utf8(product_name) AS product_name,
    from_utf8(product_category) AS product_category,
    product_price,
    product_quantity,
    from_utf8(sale_date) AS sale_date,
    sale_customer_id,
    sale_seller_id,
    sale_product_id,
    sale_quantity,
    sale_total_price,
    from_utf8(store_name) AS store_name,
    from_utf8(store_location) AS store_location,
    from_utf8(store_city) AS store_city,
    from_utf8(store_state) AS store_state,
    from_utf8(store_country) AS store_country,
    from_utf8(store_phone) AS store_phone,
    from_utf8(store_email) AS store_email,
    from_utf8(pet_category) AS pet_category,
    product_weight,
    from_utf8(product_color) AS product_color,
    from_utf8(product_size) AS product_size,
    from_utf8(product_brand) AS product_brand,
    from_utf8(product_material) AS product_material,
    from_utf8(product_description) AS product_description,
    product_rating,
    product_reviews,
    from_utf8(product_release_date) AS product_release_date,
    from_utf8(product_expiry_date) AS product_expiry_date,
    from_utf8(supplier_name) AS supplier_name,
    from_utf8(supplier_contact) AS supplier_contact,
    from_utf8(supplier_email) AS supplier_email,
    from_utf8(supplier_phone) AS supplier_phone,
    from_utf8(supplier_address) AS supplier_address,
    from_utf8(supplier_city) AS supplier_city,
    from_utf8(supplier_country) AS supplier_country
FROM clickhouse.raw_clickhouse.mock_data

UNION ALL

SELECT *
FROM postgres.public.mock_data;


CREATE TABLE clickhouse.dwh.dim_supplier AS
SELECT DISTINCT
    row_number() OVER () AS id,
    supplier_phone,
    supplier_name,
    supplier_email,
    supplier_country,
    supplier_contact,
    supplier_city,
    supplier_address
FROM clickhouse.dwh.raw_union
WHERE supplier_email IS NOT NULL;


CREATE TABLE clickhouse.dwh.dim_seller AS
SELECT DISTINCT
    row_number() OVER () AS id,
    seller_postal_code,
    seller_last_name,
    seller_first_name,
    seller_email,
    seller_country
FROM clickhouse.dwh.raw_union
WHERE seller_email IS NOT NULL;


CREATE TABLE clickhouse.dwh.dim_product AS
SELECT DISTINCT
    row_number() OVER () AS id,
    product_weight,
    product_size,
    product_reviews,
    product_release_date,
    product_rating,
    product_quantity,
    product_price,
    product_name,
    product_material,
    product_expiry_date,
    product_description,
    product_color,
    product_category,
    product_brand,
    pet_category,
    sale_date
FROM clickhouse.dwh.raw_union
WHERE product_name IS NOT NULL;


CREATE TABLE clickhouse.dwh.dim_customer AS
SELECT DISTINCT
    row_number() OVER () AS id,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed,
    customer_last_name,
    customer_first_name,
    customer_email,
    customer_country,
    customer_age
FROM clickhouse.dwh.raw_union
WHERE customer_email IS NOT NULL;


CREATE TABLE clickhouse.dwh.dim_store AS
SELECT DISTINCT
    row_number() OVER () AS id,

    ds.id AS store_supplier_id,
    sl.id AS sale_seller_id,

    ru.store_email,
    ru.store_state,
    ru.store_phone,
    ru.store_name,
    ru.store_location,
    ru.store_country,
    ru.store_city
FROM clickhouse.dwh.raw_union ru
JOIN clickhouse.dwh.dim_supplier ds
    ON ru.supplier_email = ds.supplier_email
JOIN clickhouse.dwh.dim_seller sl
    ON ru.seller_email = sl.seller_email
WHERE ru.store_email IS NOT NULL;


CREATE TABLE clickhouse.dwh.fact_sales AS
SELECT
    row_number() OVER () AS id,

    dp.id AS product_id,
    dc.id AS customer_id,
    ds.id AS store_id,

    ru.sale_total_price,
    ru.sale_quantity
FROM clickhouse.dwh.raw_union ru
JOIN clickhouse.dwh.dim_product dp
    ON  ru.product_name         = dp.product_name
    AND ru.product_price        = dp.product_price
    AND ru.product_release_date = dp.product_release_date
    AND ru.product_brand        = dp.product_brand
    AND ru.product_weight       = dp.product_weight
JOIN clickhouse.dwh.dim_customer dc
    ON ru.customer_email = dc.customer_email
JOIN clickhouse.dwh.dim_store ds
    ON ru.store_email = ds.store_email;


SELECT count(*) FROM clickhouse.dwh.dim_supplier;
SELECT count(*) FROM clickhouse.dwh.dim_seller;
SELECT count(*) FROM clickhouse.dwh.dim_product;
SELECT count(*) FROM clickhouse.dwh.dim_customer;
SELECT count(*) FROM clickhouse.dwh.dim_store;
SELECT count(*) FROM clickhouse.dwh.fact_sales;
