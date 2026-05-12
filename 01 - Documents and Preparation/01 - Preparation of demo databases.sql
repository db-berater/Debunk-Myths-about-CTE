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
	for better analysis of execution plans we overwrite the
	default settings for

	- parallelism (MAXDOP):	4
	- cost threshold:		50
*/
EXEC sp_configure N'max degree of parallelism', 4;
EXEC sp_configure N'cost threshold for parallelism', 50;
RECONFIGURE WITH OVERRIDE;
GO

/*
	Make sure you've executed the script 0000 - sp_restore_erp_demo.sql
	before you run this code!
*/
EXEC dbo.sp_restore_ERP_demo @query_store = 1;
GO

SELECT * FROM ERP_Demo.dbo.get_database_help_info();
SELECT * FROM ERP_Demo.dbo.get_object_help_info(NULL);
GO

ALTER DATABASE ERP_Demo SET COMPATIBILITY_LEVEL = 170;