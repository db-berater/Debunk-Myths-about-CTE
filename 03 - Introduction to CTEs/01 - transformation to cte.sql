/*
	============================================================================
	File:		01 - simple examples for ctes.sql

	Summary:	This scripts demonstrates the general usage of CTEs
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
	How often did we sell "Brand#23" in 2019?
	- General approach with JOIN order
*/
SELECT	COUNT_BIG(*)	AS	total_order_count
FROM	dbo.orders AS o
		INNER JOIN dbo.lineitems AS l
		ON (o.o_orderkey = l.l_orderkey)
		INNER JOIN dbo.parts AS p
		ON (l.l_partkey = p.p_partkey)
WHERE	o.o_orderdate >= '2019-01-01'
		AND o.o_orderdate < '2020-01-01'
		AND p.p_brand = 'Brand#23'
OPTION	(
			RECOMPILE,
			QUERYTRACEON 3604,
			QUERYTRACEON 8606
		);
GO

/*
	- with SUB query order
*/
SELECT	COUNT_BIG(*)	AS	total_order_count
FROM	(
			SELECT	l.l_partkey
			FROM	dbo.orders AS o
					INNER JOIN dbo.lineitems AS l
					ON (o.o_orderkey = l.l_orderkey)
			WHERE	o_orderdate >= '2019-01-01'
					AND o_orderdate < '2020-01-01'
		) AS o
		INNER JOIN
		(
			SELECT	p_partkey
			FROM	dbo.parts
			WHERE	p_brand = 'Brand#23'
		) AS p
		ON (o.l_partkey = p.p_partkey);
GO

/*
	- with CTE query order
*/
;WITH o
AS
(
	SELECT	l.l_partkey
	FROM	dbo.orders AS o
			INNER JOIN dbo.lineitems AS l
			ON (o.o_orderkey = l.l_orderkey)
	WHERE	o_orderdate >= '2019-01-01'
			AND o_orderdate < '2020-01-01'
)
SELECT	COUNT_BIG(*)	AS	total_order_count
FROM	o INNER JOIN dbo.parts AS p
		ON (o.l_partkey = p.p_partkey)
WHERE	p.p_brand = 'Brand#23';
GO