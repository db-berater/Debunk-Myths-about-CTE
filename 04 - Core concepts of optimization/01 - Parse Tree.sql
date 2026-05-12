/*
	============================================================================
	File:		01 - Parse Tree.sql

	Summary:	This script demonstrates the output of the Parse Tree
				(Converted Tree)
				
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

/* run this query with actual execution plan! */
SELECT	c.c_custkey,
		c.c_name
FROM	dbo.customers AS c
		INNER JOIN dbo.nations AS n
		ON (c.c_nationkey = n.n_nationkey)
		INNER JOIN dbo.regions AS r
		ON (n.n_regionkey = r.r_regionkey)
WHERE	c.c_mktsegment = 'AUTOMOBILE'
		AND n.n_name = 'Slovenia'
		AND r.r_name = 'Europe'
OPTION	(QUERYTRACEON 9130);
GO

/* run this query with actual execution plan! */
SELECT	c.c_custkey,
		c.c_name
FROM	dbo.customers AS c
		INNER JOIN dbo.nations AS n
		ON (c.c_nationkey = n.n_nationkey)
		INNER JOIN dbo.regions AS r
		ON (n.n_regionkey = r.r_regionkey)
WHERE	c.c_mktsegment = 'AUTOMOBILE'
		AND n.n_name = 'Slovenia'
		AND r.r_name = 'Europe'
OPTION	(
			FORCE ORDER,
			QUERYTRACEON 9130
		);
GO

/* What is going up behind the scene? */
SELECT	c.c_custkey,
		c.c_name
FROM	dbo.customers AS c
		INNER JOIN dbo.nations AS n
		ON (c.c_nationkey = n.n_nationkey)
		INNER JOIN dbo.regions AS r
		ON (n.n_regionkey = r.r_regionkey)
WHERE	c.c_mktsegment = 'AUTOMOBILE'
		AND n.n_name = 'Slovenia'
		AND r.r_name = 'Europe'
OPTION	(
			RECOMPILE,
			QUERYTRACEON 3604,	/* output to application */
			QUERYTRACEON 8605	/* output of converted tree */
		);
GO