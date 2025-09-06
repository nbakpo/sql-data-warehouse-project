/* 
===================================================================
DDL Script: Create Gold Views
===================================================================
Script Purpose:
  This script creates views for the Gold Layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables (Star Schema)

  Each view performs transformations and combines data from the silver layer
  to produce a clean, enriched, and business-ready dataset.

Usage:
   - These views can be applied directly for analytics and reporting
===================================================================
*/

-- Create Dimension: gold.dim_customers
CREATE VIEW gold.dim_customers AS
/* Joining and integrating customer demographic data 
from multiple sources and renaming the columns */
SELECT
  -- create a surrogate key
  ROW_NUMBER() over(order by cst_id) as customer_key,
  ci.cst_id as customer_id,
  ci.cst_key as customer_number,   
  ci.cst_firstname as first_name, 
  ci.cst_lastname as last_name,
  la.cntry as country,
  -- combining marital status from two sources
  ci.cst_marital_status as marital_status,
  Case When ci.cst_gndr != 'n/a' Then ci.cst_gndr 
  Else coalesce(ca.gen, 'n/a')
  End as gender,
  ca.bdate as birthdate,
  ci.cst_create_date as create_date
FROM silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key = ca.cid
Left join silver.erp_loc_a10 la 
on ci.cst_key = la.cid

-- Create Dimension: gold.dim_products
Create View gold.dim_products AS
-- Combining product information with category details
SELECT
  -- create a surrogate key
  ROW_NUMBER() over(order by pn.prd_start_dt) as product_key,
  pn.prd_id as product_id,
  pn.prd_key as product_number,
  pn.prd_nm as product_name,
  pn.cat_id as category_id,
  pc.cat as category,
  pc.subcat as sub_category,
  pc.maintenance as maintenance,
  pn.prd_cost as product_cost,
  pn.prd_line as product_line,
  pn.prd_start_dt as start_date
from silver.crm_prd_info pn  
Left Join silver.erp_px_cat_g1v2  pc
on pn.cat_id = pc.id 
-- Filter to get only active products
Where prd_end_dt is NULL




-- Create a fact table: gold.fact_sales 
Create View gold.fact_sales AS
-- constructing sales data
SELECT
  sd.sls_ord_num as order_number,
  -- Connecting this fact table to the product dimension table
  pr.product_key,
  -- Surrogate key for customer
  cu.customer_key,
  sd.sls_order_dt as order_date,
  sd.sls_ship_dt as ship_date,
  sd.sls_due_dt as due_date,
  sd.sls_sales as sales_amount,
  sd.sls_quantity as quantity,
  sd.sls_price as price
From silver.crm_sales_details sd
Left Join gold.dim_products pr 
on sd.sls_prd_key = pr.product_number
Left Join gold.dim_customers cu
on sd.sls_cust_id = cu.customer_id

