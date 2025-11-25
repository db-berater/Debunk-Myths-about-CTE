/*
	============================================================================
	File:		04 - recursive ctes.sql

	Summary:	This scripts demonstrates the concept of recursion with CTEs
				
				THIS SCRIPT IS PART OF THE TRACK:
					"Debunk Myths About CTE"

	Date:		October 2025
	Revion:		November 2025

	SQL Server Version: >= 2016
	============================================================================
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE ERP_Demo;
GO

/*
	Let's create a demo table with hierarchically data structures
*/
EXEC sp_create_demo_schema;
GO

DROP TABLE IF EXISTS demo.orders;
GO

SELECT	