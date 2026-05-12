/*
	============================================================================
	File:		03 - Normalization phase.sql

	Summary:	This script demonstrates the output of the Normalization Result
				
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

SELECT	c_custkey,
		c_name,
		c_mktsegment
FROM	dbo.customers
WHERE	c_custkey <= 10
OPTION	(
			RECOMPILE,
			QUERYTRACEON 3604,
			QUERYTRACEON 8606
		);
GO

SELECT	c_custkey,
		c_name,
		c_mktsegment
FROM	dbo.customers
WHERE	NOT (c_custkey > 10)
OPTION	(
			RECOMPILE,
			QUERYTRACEON 3604,
			QUERYTRACEON 8606
		);
GO
