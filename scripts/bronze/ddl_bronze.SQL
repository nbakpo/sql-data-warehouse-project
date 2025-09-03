/* 
===================================================================
DDL Script: Create Bronze Tables
===================================================================
Script Purpose:
  This script creates tables in the 'bronze' schema, first dropping existing tables
  if they already exist.
Run this script to redefine the DDL structure of the 'bronze' tables
===================================================================
*/ 
-- Create Tables for bronze layer

-- Table for customer information
if object_id('bronze.crm_cust_info', 'U') is not null
    drop table bronze.crm_cust_info;
    GO
CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);

-- Table for product information
if object_id('bronze.crm_prd_info', 'U') is not null
    drop table bronze.crm_prd_info;
    GO
CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost NVARCHAR(50),
    prd_line NVARCHAR (10),
    prd_start_dt DATE,
    prd_end_dt DATE
);


-- Table for sales details
if object_id('bronze.crm_sales_details', 'U') is not null
    drop table bronze.crm_sales_details;
    GO
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(10),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt VARCHAR(50),
    sls_ship_dt VARCHAR(50),
    sls_due_dt VARCHAR(50),
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

-- Table for product category information
if object_id('bronze.erp_px_cat_g1v2', 'U') is not null
    drop table bronze.erp_px_cat_g1v2;
    GO
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(10)
);

-- Table for location information
if object_id('bronze.erp_loc_a10', 'U') is not null
    drop table bronze.erp_loc_a10;
    GO
CREATE TABLE bronze.erp_loc_a10 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

-- Table for customer demographics
if object_id('bronze.erp_cust_az12', 'U') is not null
    drop table bronze.erp_cust_az12; 
    GO
CREATE TABLE bronze.erp_cust_az12 (
    cid NVARCHAR(20),
    bdate DATE,
    gen VARCHAR(50)
);

