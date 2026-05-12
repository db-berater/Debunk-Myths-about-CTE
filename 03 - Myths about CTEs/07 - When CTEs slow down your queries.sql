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
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET STATISTICS IO, TIME ON;
GO

USE ERP_Demo;
GO

/*
	It is possible to change the representation of data
	by adding individual column names
*/
SELECT	TOP (10) WITH TIES
		c.c_custkey,
		c.c_name,
		COUNT_BIG(o.o_orderkey)	AS	num_orders
FROM	dbo.customers AS c
		INNER JOIN dbo.orders AS o
		ON (c.c_custkey = o.o_custkey)
WHERE	o.o_orderdate >= '2020-02-01'
		AND o.o_orderdate < '2020-03-01'
GROUP BY
		c.c_custkey,
		c.c_name
ORDER BY
		COUNT_BIG(*) DESC;
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
FROM	o INNER JOIN dbo.customers AS c
		ON (c.c_custkey = o.o_custkey)
ORDER BY
		o.num_orders DESC;
GO

/*
	Yes - a CTE can slow down your query BUT...
	it is not the CTE which slows down but the
	concept of wrong Rowgoals!
*/
SELECT	c.c_custkey,
		c.c_name,
		o.num_orders
FROM	(
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
		) AS o
		INNER JOIN dbo.customers AS c
		ON (c.c_custkey = o.o_custkey)
ORDER BY
		o.num_orders DESC;
GO