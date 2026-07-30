-------------------------------------------------------------------
/*DDL Script: CREATING BRONZE TABLES
-------------------------------------
This script creates multiple tables in the bronze schema, including customer information, product information,
sales details, and various ERP tables.Each table is dropped if it already exists before being created.
*/
--------------------------------------------------------------------
IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_material_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);

IF OBJECT_ID('bronze.crm_prd_info','U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
prd_id INT,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATETIME,
prd_end_dt DATETIME
);

IF OBJECT_ID('bronze.crm_sales_details','U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
sls_ord_num NVARCHAR(30),
sls_prd_key NVARCHAR(30),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);

IF OBJECT_ID('bronze.erp_cust_az12','U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
cid VARCHAR(18),
bdate DATE,
gen VARCHAR(6)
);

IF OBJECT_ID('bronze.erp_loc_a101','U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
cid VARCHAR(50),
cntry VARCHAR (50)
);

IF OBJECT_ID('bronze.erp_px_cat_g1v2','U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
id VARCHAR(5),
cat VARCHAR (11),
subcat VARCHAR(30),
maintenance VARCHAR(3)
);


