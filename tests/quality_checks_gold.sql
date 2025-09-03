/*
==========================================================================
Quality Checks
==========================================================================
Script Purpose:
  This script performs various checks for data consistency, and accuracy
 across the Gold Layer. It includes checks for
  - Uniqueness of the surrogate keys in dimension tables.
  - Referential integrity between fact and dimension tables.
  - Validation of relationships in the data model for analytical purposes.
Usage Notes: 
  - Run these checks after data loading Silver Layer.
  - Investigate and resolve any discrepancies  found during the checks.
==========================================================================
*/

 -- Data integration with genders
SELECT Distinct
ci.cst_gndr,
ca.gen,
-- CRM is the Master for gender Info
Case When ci.cst_gndr != 'n/a' Then ci.cst_gndr 
Else coalesce(ca.gen, 'n/a')
End as new_gen

FROM silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key = ca.cid
Left join silver.erp_loc_a10 la 
on ci.cst_key = la.cid
order by 1,2

-- Quality check of Gold Table
Select Distinct 
gender 
from gold.dim_customers

--Check for multiple active products with same prd_key
select prd_key, count(*) from (
SELECT
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.maintenance
from silver.crm_prd_info pn  
Left Join silver.erp_px_cat_g1v2  pc
on pn.prd_key = pc.id 
-- Filter to get only active products
Where prd_end_dt is NULL)t
group by prd_key
Having count(*) > 1

-- Check quality of the view
Select * from gold.fact_sales

-- Foreign key Integrity check
-- Check for no matching customer_key/product_key in fact_sales and dim_customers
Select * from gold.fact_sales f 
left join gold.dim_customers c 
on f.customer_key = c.customer_key
Left Join gold.dim_products p
on f.product_key = p.product_key
where p.product_key is null


select product_line from gold.dim_products
