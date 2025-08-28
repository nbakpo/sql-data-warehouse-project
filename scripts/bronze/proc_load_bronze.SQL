/*
=============================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=============================================================
Script Purpose:
  This stored procedure loads data into the 'bronze schema from external CSV files.
  It performs the following actions:
  - Truncates the bronze tables before loading data.
  - Uses the 'BULK INSERT' command to load data from csv files to bronze tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  Exec bronze.load_bronze;
=============================================================
*/

-- Truncate_Inserting DATA into the table from CSV into bronze schema

Create OR Alter Procedure bronze._load_bronze as 

Begin

    Declare @start_time Datetime, 
            @end_time Datetime, @start_time1 Datetime, 
        @end_time1 Datetime;
    BEGIN TRY 
        set @start_time1 = getdate();
        print '=================================================';
        print 'Bronze Layer Data Insertion Started';
        print '=================================================';
        print '=================================================';
        print 'Loading CRM and ERP Data into Bronze Layer';
        print '=================================================';
        print '>> Truncate Table: bronze.crm_cust_info';
        
        set @start_time = getdate();
        TRUNCATE TABLE bronze.crm_cust_info;
        print '>> Inserting Data into Table: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM '/home/nenubaribakpo/mssql/backup/cust_info.csv'
        WITH (
            Firstrow = 2,
            fieldterminator = ',',
            Tablock
        ); 
        set @end_time = getdate();
        print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) as nvarchar) + ' seconds';
        print '==================================';
        
        set @start_time = getdate();
        print '>> Truncate Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        print '>> Inserting Data into Table: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM '/home/nenubaribakpo/mssql/backup/prd_info.csv'
        WITH (
            Firstrow = 2,
            fieldterminator = ',',
            Tablock
        ); 
        set @end_time = getdate();
        print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) as nvarchar) + ' seconds';
        print '==================================';

        set @start_time = getdate();
        print '>> Truncate Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        print '>> Inserting Data into Table: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM '/home/nenubaribakpo/mssql/backup/sales_details.csv'
        WITH (
            Firstrow = 2,
            fieldterminator = ',',
            Tablock
        ); 
        set @end_time = getdate();
        print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) as nvarchar) + ' seconds';
        print '==================================';
        
        set @start_time = getdate();
        print '>> Truncate Table: bronze.erp_loc_a10';
        TRUNCATE TABLE bronze.erp_loc_a10;
        print '>> Inserting Data into Table: bronze.erp_loc_a10';
        BULK INSERT bronze.erp_loc_a10
        FROM '/home/nenubaribakpo/mssql/backup/loc_a10.csv'
        WITH (
            Firstrow = 2,
            fieldterminator = ',',
            Tablock
        ); 
        set @end_time = getdate();
        print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) as nvarchar) + ' seconds';
        print '==================================';
        
        set @start_time = getdate();
        print '>> Truncate Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        print '>> Inserting Data into Table: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/home/nenubaribakpo/mssql/backup/px_cat-g1v2.csv'
        WITH (
            Firstrow = 2,
            fieldterminator = ',',
            Tablock
        ); 
        set @end_time = getdate();
        print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) as nvarchar) + ' seconds';
        print '==================================';
        
        set @start_time = getdate();
        print '>> Truncate Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12_cust_az12;
        print '>> Inserting Data into Table: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM '/home/nenubaribakpo/mssql/backup/cust_az12.csv'
        WITH (
            Firstrow = 2,
            fieldterminator = ',',
            Tablock
        ); 
         set @end_time = getdate();
        print '>> Load Duration: ' + Cast(DateDiff(Second, @start_time, @end_time) as nvarchar) + ' seconds';
        print '==================================';
        print '>> Total Load Duration of Procedure: ' + Cast(DateDiff(Second, @start_time1, @end_time1) as nvarchar) + ' seconds';
        print '==================================';
    END TRY 
    Begin CATCH
    print '=================================================';
    print 'Error Occurred During Bronze Layer Data Insertion';
    print 'Error Message' + Error_Message();
    print 'Error Message' + Cast(Error_Number() as nvarchar);
    print 'Error Message' + Cast(Error_state() as nvarchar);
    print '=================================================';
    End CATCH
    set @end_time1 = getdate();

End; 

