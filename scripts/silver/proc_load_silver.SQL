/*
=============================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=============================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, and Load) process to 
  populate the 'silver' schema tables from the 'bronze' schema.
  It performs the following actions:
  - Truncates the Silver tables.
  - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  Exec silver.load_silver;
=============================================================
*/
-- Silver Layer Data Load Procedure
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @start_time1 DATETIME, @end_time1 DATETIME;
    SET @start_time1 = GETDATE();
    PRINT '=================================================';
    PRINT 'Silver Layer Data Insertion Started';
    PRINT '=================================================';
    PRINT 'Loading CRM and ERP Data into Silver Layer';

    -- crm_cust_info
    BEGIN TRY
        PRINT '>> Truncate Table: silver.crm_cust_info';
        SET @start_time = GETDATE();
        Truncate table silver.crm_cust_info;
        -- Inserting data into Silver.crm_cust_info table From bronze.crm_cust_info table with data cleaning and normalization
        Insert into silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date)
        Select 
        cst_id,
        cst_key,
        -- Removing unwanted spaces in the names
        TRIM(cst_firstname) as cst_firstname,
        TRIM(cst_lastname) as cst_lastname,
        -- Data normalization and standardization for marital status for easy formating 
        Case When upper(trim(cst_marital_status)) = 'M' Then 'Married'
        When upper(trim(cst_marital_status)) = 'S' Then 'Single'
        -- Handling missing data
        Else 'n/a' End as cst_marital_status,
        -- Data normalization and standardization for Gender for easy formating 
        Case When upper(trim(cst_gndr)) = 'F' Then 'Female'
        When upper(trim(cst_gndr)) = 'M' Then 'Male'
        Else 'n/a' End as cst_gndr,
        cst_create_date
        From( 
        Select
        *,
        -- Using ROW_NUMBER to get the latest record for each customer and removing duplicates
        ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last 
        From bronze.crm_cust_info where cst_id is NOT NULL)t 
        where flag_last = 1 

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT 'Error loading silver.crm_cust_info: ' + ERROR_MESSAGE();
    END CATCH

    -- crm_prd_info
    BEGIN TRY
        PRINT '>> Truncate Table: silver.crm_prd_info';
        SET @start_time = GETDATE();
        Truncate table silver.crm_prd_info;
    Insert into silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
        )
        Select 
        prd_id,
        -- Extracting category ID from product key
        replace(substring(prd_key, 1, 5), '-', '_') as cat_id, 
        substring(prd_key, 7, len(prd_key)) as prd_key,
        prd_nm,
        -- Handling missing information by replacing nulls with 0
        isnull(prd_cost, 0) as prd_cost,
        -- Standardizing product line values
        Case When upper(trim(prd_line)) = 'M' Then 'Mountain'
        When upper(trim(prd_line)) = 'R' Then 'Road'
        When upper(trim(prd_line)) = 'T' Then 'Touring'
        When upper(trim(prd_line)) = 'S' Then 'Other Sales'
        Else 'n/a' end as prd_line,
        -- Ensuring date format consistency with casting
        cast(prd_start_dt as date) as prd_start_dt,
        -- Data enrichment by calculating end date as one day before the next start date
        cast(Dateadd(day, -1, Lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)) as date) as prd_end_dt
        From bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT 'Error loading silver.crm_prd_info: ' + ERROR_MESSAGE();
    END CATCH

    -- crm_sales_details
    BEGIN TRY
        PRINT '>> Truncate Table: silver.crm_sales_details';
        SET @start_time = GETDATE();
    Truncate Table silver.crm_sales_details;
    Insert into silver.crm_sales_details(
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
        Select 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        -- Transforming integer date to date format, if the date is invalid (0 or not 8 digits) Then set it to null
        Case When sls_order_dt = 0 or len(sls_order_dt) != 8 Then null
        Else Cast(cast(sls_order_dt as varchar) as Date) 
        End As sls_order_dt,
        Case When sls_ship_dt = 0 or len(sls_ship_dt) != 8 Then null
        Else Cast(cast(sls_ship_dt as varchar) as Date) 
        End As sls_ship_dt,
        Case When sls_due_dt = 0 or len(sls_due_dt) != 8 Then null
        Else Cast(cast(sls_due_dt as varchar) as Date) 
        End As sls_due_dt,
    --  Recalculating sales if original value is missing or incorrect 
        Case When sls_sales is null 
        or sls_sales <= 0 
        or sls_sales != sls_quantity * abs(sls_price)
        Then sls_quantity * abs(sls_price)
        Else sls_sales
        End as sls_sales,
        sls_quantity,
        -- Derive price if original value is missing or incorrect
        Case When sls_price is null or sls_price <= 0
        Then sls_sales / Nullif(sls_quantity, 0)
        Else sls_price
        End as sls_price
        From bronze.crm_sales_details
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT 'Error loading silver.crm_sales_details: ' + ERROR_MESSAGE();
    END CATCH

    -- erp_loc_a10
    BEGIN TRY
        PRINT '>> Truncate Table: silver.erp_loc_a10';
        SET @start_time = GETDATE();
          Truncate table silver.erp_loc_a10;
        Insert into silver.erp_loc_a10 (cid, cntry)
        Select 
        -- replace '-' From cid 
        replace(cid, '-', '') as cid,
        -- standardize country names
        Case When left(cntry, len(trim(cntry))-1) = 'DE' Then 'Germany'
        When left(cntry, len(cntry)-1) in ('US', 'USA') Then 'United States'
        When left(cntry, len(trim(cntry))-1) = '' or cntry is NULL Then 'n/a'
        Else left(cntry, len(trim(cntry))-1)
        End as cntry
        From bronze.erp_loc_a10 
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT 'Error loading silver.erp_loc_a10: ' + ERROR_MESSAGE();
    END CATCH

    -- erp_px_cat_g1v2
    BEGIN TRY
        PRINT '>> Truncate Table: silver.erp_px_cat_g1v2';
        SET @start_time = GETDATE();
        Truncate table silver.erp_px_cat_g1v2;
        Insert into silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
        )
        Select
        id,
        cat,
        subcat,
        left(maintenance, len(trim(maintenance))-1) as maintenance
        From bronze.erp_px_cat_g1v2
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT 'Error loading silver.erp_px_cat_g1v2: ' + ERROR_MESSAGE();
    END CATCH

    -- erp_cust_az12
    BEGIN TRY
        PRINT '>> Truncate Table: silver.erp_cust_az12';
        SET @start_time = GETDATE();
        Truncate table silver.erp_cust_az12;
        Insert into silver.erp_cust_az12 (cid, bdate, gen)
        Select 
        -- Remove 'NAS' prefix from cid
        Case When cid like 'NAS%' Then substring(cid, 4, len(cid))
        Else cid
        end cid,
        -- Set out-of-range birth dates to null
        Case When bdate > GETDATE() Then null
        Else bdate 
        End bdate,
        -- Normalize gender values and handle unknown Cases
        Case When 
        Upper(left(trim(gen), len(gen)-1)) in ('M', 'MALE') Then 'Male'
        When 
        Upper(left(trim(gen), len(gen)-1)) in ('F', 'FEMALE') Then 'Female'
        Else 'n/a'
        End gen
        From bronze.erp_cust_az12

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT 'Error loading silver.erp_cust_az12: ' + ERROR_MESSAGE();
    END CATCH

    SET @end_time1 = GETDATE();
    PRINT '>> Total Load Duration of Procedure: ' + CAST(DATEDIFF(SECOND, @start_time1, @end_time1) AS NVARCHAR) + ' seconds';
    PRINT '==================================';
END;
