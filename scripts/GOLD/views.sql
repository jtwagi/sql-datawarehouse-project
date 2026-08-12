
/*
Create views for customers, products, and sales

SCRIPT PURPOSE:
>>   The script creates three views in the gold schema: dim_customers, dim_products, and fact_sales. Each view pulls from silver schema source tables and uses GO batch separators between create/drop statements.
>>   Existing views are checked and dropped with OBJECT_ID before they are recreated.
>>   The dim_customers view combines CRM customer information with ERP customer and location data.
>>   It generates a customer surrogate key and includes customer details such as names, country, marital status, gender, birthdate, and creation date.
>>   Gender values use the CRM gender when available; otherwise, the ERP gender is used, with 'n/a' as the final fallback.
>>   The dim_products view combines CRM product data with ERP category data.
>>   It generates a product surrogate key and includes product, category, subcategory, cost, maintenance, and product-line details.
>>   The product view filters out products that have an end date, retaining only active products.
>>   The fact_sales view pulls sales transaction data from the CRM sales-details table.
>>   It links each sale to the customer and product dimension views using customer IDs and product numbers.
>>   The sales fact view includes order, shipping, and due dates, along with sales amount, quantity, and price.
*/

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL -- dropping the dimension customer view if it already existed
   DROP VIEW gold.dim_customers;
GO

-- CREATING THE DIMENSION PRODUCT VIEW

CREATE VIEW gold.dim_customers AS
SELECT DISTINCT
     ROW_NUMBER() OVER (ORDER by cst_id) AS customer_key,
     ci.cst_id                           AS customer_id,
     ci.cst_key                          AS customer_number,
     ci.cst_firstname                    AS first_number,
     ci.cst_lastname                     AS last_name,
     la.cntry                            AS country,
     ci.cst_marital_status,
     CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
          ELSE COALESCE(ca.gen, 'n/a') -- returns the first non-NULL value
     END                                 AS gender,
     ca.bdate                            AS birthdate,
     ci.cst_create_date

FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON        ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON        ci.cst_key = la.cid

GO 

-- CREATING THE DIMENSION PRODUCT VIEW

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL -- dropping the dimension product view if it already existed
   DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id                                                AS product_id,
	pn.prd_key                                               AS product_number,
    pn.prd_nm                                                AS product_name,
	pn.cat_id                                                AS category_id,
	pc.cat                                                   AS category,
	pc.subcat                                                AS subcategory,
	pc.maintenance,
	pn.prd_cost                                              AS product_cost,
	pn.prd_line                                              AS product_line,
	pn.prd_start_dt                                          AS start_date

FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL

GO

-- CREATING THE FACTS SALES VIEW

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL --dropping the facts sales view if it already existed
   DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales   AS
SELECT 
	sls_ord_num            AS order_number,
	pr.product_key,
	cu.customer_key,
	sls_order_dt           AS order_date,
	sls_ship_dt            AS shipping_date,
	sls_due_dt             AS due_date,
	sls_sales              AS sales_amount,
	sls_quantity           AS quantity,
	sls_price              AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id


 
