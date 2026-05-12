/*
	============================================================================
	File:		01 - concept of ctes.sql

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
	SQL statement into one logical units!

	Challenge:	Search the TOP (10) customers WITH TIES for February 2020!
				We list the customers with their number of orders!
*/
SELECT	TOP (10) WITH TIES
		c.c_custkey,
		c.c_name,
		COUNT_BIG(*)			AS	num_orders,
		AVG(o.o_totalprice)		AS	avg_totalprice
FROM	dbo.customers AS c
		INNER JOIN dbo.orders AS o
		ON (c.c_custkey = o.o_custkey)
WHERE	o.o_orderdate >= '2020-02-01'
		AND o.o_orderdate < '2020-03-01'
GROUP BY
		c.c_custkey,
		c.c_name
ORDER BY
		num_orders DESC;
GO

/*
	In the first step we try a solution with a SUBQUERY...
	Note: Some LinkedInfluencers state that it will be slow!
*/
SELECT	TOP (10) WITH TIES
		c.c_custkey,
		c.c_name,
		o.num_orders,
		o.avg_totalprice
FROM	dbo.customers AS c
		INNER JOIN
		(
			SELECT	o_custkey,
					COUNT_BIG(*)			AS	num_orders,
					AVG(o_totalprice)		AS	avg_totalprice
			FROM	dbo.orders
			WHERE	o_orderdate >= '2020-02-01'
					AND o_orderdate < '2020-03-01'
			GROUP BY
					o_custkey
		) AS o
		ON (c.c_custkey = o.o_custkey)
ORDER BY
		o.num_orders DESC;
GO

/*
	We can put part(s) of the query into CTE(s)
*/
;WITH o (o_custkey, num_orders, avg_totalprice)
AS
(
	SELECT	o_custkey,
			COUNT_BIG(*)		AS	num_orders,
			AVG(o_totalprice)	AS	avg_totalprice
	FROM	dbo.orders
	WHERE	o_orderdate >= '2020-02-01'
			AND o_orderdate < '2020-03-01'
	GROUP BY
			o_custkey
)
SELECT	TOP (10) WITH TIES
		c.c_custkey,
		c.c_name,
		o.num_orders,
		o.avg_totalprice
FROM	dbo.customers AS c
		INNER JOIN o /* reference to the CTE */
		ON (c.c_custkey = o.o_custkey)
ORDER BY
		o.num_orders DESC;
GO

/*
	But maybe two separate analysis CTE will help?
*/
;WITH o (o_custkey, num_orders)
AS
(
	SELECT	o_custkey,
			COUNT_BIG(*)		AS	num_orders
	FROM	dbo.orders
	WHERE	o_orderdate >= '2020-02-01'
			AND o_orderdate < '2020-03-01'
	GROUP BY
			o_custkey
),
p
AS
(
	SELECT	o_custkey,
			AVG(o_totalprice)	AS	avg_totalprice
	FROM	dbo.orders
	WHERE	o_orderdate >= '2020-02-01'
			AND o_orderdate < '2020-03-01'
	GROUP BY
			o_custkey
)
SELECT	TOP (10) WITH TIES
		c.c_custkey,
		c.c_name,
		o.num_orders,
		p.avg_totalprice
FROM	dbo.customers AS c
		INNER JOIN o
		ON (c.c_custkey = o.o_custkey)
		INNER JOIN p
		ON (c.c_custkey = p.o_custkey)
ORDER BY
		o.num_orders DESC;
GO