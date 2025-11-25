/*
	============================================================================
	File:		04 - Optimization phase.sql

	Summary:	This script demonstrates the output of the Optimization Result
				
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
FROM	dbo.customers AS c
		INNER JOIN dbo.nations AS n
		ON (c.c_nationkey = n.n_nationkey)
WHERE	n.n_name = 'PORTUGAL'
		AND c.c_mktsegment = 'AUTOMOBILE'
OPTION	(
			RECOMPILE
			, QUERYTRACEON 3604
			, QUERYTRACEON 8607
			, QUERYTRACEON 9130
		);
GO
