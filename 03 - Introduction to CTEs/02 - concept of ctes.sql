/*
	============================================================================
	File:		02 - concept of ctes.sql

	Summary:	This scripts demonstrates the concept of CTEs
				in a T-SQL query
				
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
	The core concept of a cte is the separation of a dedicated
	SQL statement into one logical operation!

	Challenge:	Search the TOP (10) customers with the most
				orders in February 2020
*/
SELECT	TOP (10) WITH TIES
		c.c_custkey,
		c.c_name,
		COUNT_BIG(*)	AS	num_orders
FROM	dbo.customers AS c
		INNER JOIN dbo.orders AS o
		ON (c.c_custkey = o.o_custkey)
WHERE	o.o_orderdate >= '2020-02-01'
		AND o.o_orderdate < '2020-03-01'
GROUP BY
		c.c_custkey,
		c.c_name
ORDER BY
		num_orders DESC
OPTION	(MAXDOP 4);
GO

/*
	It is possible to change the representation of data
	by adding individual column names
*/
;WITH o
AS
(
	SELECT	o_custkey,
			COUNT_BIG(*)	AS	num_orders
	FROM	dbo.orders
	WHERE	o_orderdate >= '2020-02-01'
			AND o_orderdate < '2020-03-01'
	GROUP BY
			o_custkey
)
SELECT	TOP (10) WITH TIES
		c.c_custkey,
		c.c_name,
		o.num_orders
FROM	dbo.customers AS c
		INNER JOIN o
		ON (c.c_custkey = o.o_custkey)
ORDER BY
		o.num_orders DESC;
GO

/*
	Can we optimize the execution by pushing the TOP Operator
	into the CTE
*/
;WITH o
AS
(
	SELECT	TOP (10) WITH TIES
			o_custkey,
			COUNT_BIG(*)	AS	num_orders
	FROM	dbo.orders
	WHERE	o_orderdate >= '2020-02-01'
			AND o_orderdate < '2020-03-01'
	GROUP BY
			o_custkey
	ORDER BY
			num_orders DESC
)
SELECT	c.c_custkey,
		c.c_name,
		o.num_orders
FROM	dbo.customers AS c
		INNER JOIN o
		ON (c.c_custkey = o.o_custkey)
ORDER BY
		o.num_orders DESC;
GO