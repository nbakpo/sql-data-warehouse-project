/*
==========================================================================
Quality Checks
==========================================================================
Script Purpose:
  This script performs various checks for data consistency, accuracy,
  and standardization across the 'silver' schema. It includes checks for
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data standardization and consistency.
  - Invalid date ranges and orders.
  - Data consistency between related fields
Usage Notes: 
  - Run these checks after data loading Silver Layer.
  - Investigate and resolve any discrepancies  found during the checks.
==========================================================================
*/
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Nulls or Duplicates
SELECT
prd_id,
count(*) 
From bronze.crm_prd_info
Group BY prd_id
Having Count(*) > 1 or prd_id is null;

-- Check for unwanted Spaces
-- Expectation: No unwanted spaces
SELECT prd_line
From bronze.crm_prd_info
where prd_line != Trim(prd_line);

-- Data Standardization & Consistency Check
Select distinct gen,
Case When upper(Trim(gen)) in ('F', 'FEMALE') Then 'Female'
When upper(Trim(gen)) in ('M', 'MALE') Then 'Male'
else 'n/a'
End as gen
From bronze.erp_cust_az12 

select * from [bronze].[erp_cust_az12]

-- Check for Nulls or negative values
-- expectation: No Nulls or negative values
select prd_id, prd_cost
from bronze.crm_prd_info
where prd_cost is null or prd_cost < 0;
select left(gen, len(gen)-1) as gen_trimmed from bronze.erp_cust_az12
-- check for invalid Date Orders
Select 
nullif(sls_ship_dt,0) as sls_ship_dt
from bronze.crm_sales_details
where sls_ship_dt <= 0 
or len(sls_ship_dt) != 8
or sls_ship_dt > 20500101
or sls_ship_dt < 19000101;

-- check for invalid Date Orders
Select *
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt 
or sls_order_dt > sls_due_dt 

-- Sales = Quantity * Price
-- values must not be null, zero or negative.
SELECT Distinct
sls_sales,
sls_quantity,
sls_price 
From silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null 
or sls_quantity is null
or sls_price is null
or sls_sales <= 0 
or sls_quantity <= 0
or sls_price <= 0
order by sls_sales, sls_quantity, sls_price

select * from Silver.crm_sales_details

-- Identify Out-of-Range Dates
select DISTINCT
bdate
from bronze.erp_cust_az12
where bdate < '1924-01-01' or bdate > GETDATE()

-- Data standardization & Consistency Check
select DISTINCT
gen 
select * from bronze.crm_cust_info

-- Checking if all locations in erp_loc_a10 are present in crm_cust_info
Select cntry from bronze.erp_loc_a10
where cntry not in (select distinct cntry from silver.crm_cust_info)
-- remove hyphen from cid to match cst_key format in crm_cust_info
replace(cid, '-', '') as cid,
cntry
-- Check if cid (customer id) in erp_loc_a10 exists in cst_key (customer key) in crm_cust_info
from bronze.erp_loc_a10 where replace(cid, '-', '') 
not in (select cst_key from silver.crm_cust_info) 

-- Data Standarization & Consistency Check
Select Distinct id
from bronze.erp_px_cat_g1v2
where id not in (select distinct cat_id from silver.crm_prd_info)




  
  
