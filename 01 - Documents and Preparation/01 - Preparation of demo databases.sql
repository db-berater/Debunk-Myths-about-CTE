/*
	============================================================================
	File:		01 - Preparation of demo databases.sql

	Summary:	This script restores the database ERP_Demo from
				the backup medium for distribution of data.
				
				THIS SCRIPT IS PART OF THE TRACK:
					"Debunk Myths About CTE"

	Date:		October 2025
	Revion:		November 2025

	SQL Server Version: >= 2016
	============================================================================
*/
USE master;
GO

/*
	Make sure you've executed the script 0000 - sp_restore_erp_demo.sql
	before you run this code!
*/
EXEC dbo.sp_restore_ERP_demo @query_store = 1;
GO

/* reset the sql server default settings for the demos */
EXEC ERP_Demo.dbo.sp_set_sql_server_defaults;
GO

SELECT * FROM ERP_Demo.dbo.get_database_help_info();
SELECT * FROM ERP_Demo.dbo.get_object_help_info(NULL);
GO

EXEC sp_configure N'cost threshold for parallelism', 50;
RECONFIGURE WITH OVERRIDE;
GO

USE ERP_Demo;
GO

/* disable the query store */
EXEC dbo.sp_deactivate_query_store;
GO

/* create all necessary indexes for the demos */
EXEC dbo.sp_create_indexes_regions;
EXEC dbo.sp_create_indexes_nations;
EXEC dbo.sp_create_indexes_customers;
EXEC dbo.sp_create_indexes_orders;
EXEC dbo.sp_create_indexes_lineitems;
EXEC dbo.sp_create_indexes_parts;
GO