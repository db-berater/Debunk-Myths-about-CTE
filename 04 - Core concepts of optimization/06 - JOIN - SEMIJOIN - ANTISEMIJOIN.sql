/*
	============================================================================
	File:		06 - examples for rewriting.sql

	Summary:	This script demonstrates the cost based execution plans
				from different variants of writing the same query.
				
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

EXEC dbo.sp_create_indexes_customers;
EXEC dbo.sp_create_indexes_nations;
EXEC dbo.sp_create_indexes_regions;
EXEC dbo.sp_create_indexes_orders;
GO

SELECT	c.c_custkey,
		c.c_name
FROM	dbo.customers AS c
WHERE	EXISTS
		(
			SELECT	*
			FROM	dbo.orders AS o
			WHERE	o.o_custkey = c.c_custkey
					AND o_orderdate >= '2019-01-01'
					AND o_orderdate < '2019-01-02'
		);
GO

SELECT	c.c_custkey,
		c.c_name
FROM	dbo.customers AS c
WHERE	EXISTS
		(
			SELECT	*
			FROM	dbo.orders AS o
			WHERE	o.o_custkey = c.c_custkey
					AND o_orderdate = '2019-01-01'
		);
GO

/*	Decorrelation = LEFT ANTI SEMI JOIN */
SELECT	TOP (10)
		c.c_custkey,
		c.c_name
FROM	dbo.customers AS c
WHERE	NOT EXISTS
		(
			SELECT	*
			FROM	dbo.orders AS o
			WHERE	o.o_custkey = c.c_custkey
					AND o_orderdate = '2019-01-01'
		);
GO
