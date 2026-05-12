/*
	============================================================================
	File:		01 - CTEs improve performance.sql

	Summary:	This demo shows that CTEs are equally treaten by the query
				optimizer as JOIN / SubQueries

				THIS SCRIPT IS PART OF THE TRACK:
					"Debunk Myths About CTE"

	Date:		October 2025
	Revion:		November 2025

	SQL Server Version: >= 2016
	============================================================================
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET STATISTICS TIME ON;
GO

USE ERP_Demo;
GO

EXEC dbo.sp_clear_query_store;
GO

/*
	Let's find some order details by nation
	For each nation we want to know the percentage
	compared to all nations for a given year
*/
BEGIN
	DECLARE @start_date	DATE = '2019-01-01';
	DECLARE @end_date	DATE = '2019-12-31';

	SELECT	r.r_name						AS	region_name,
			n.n_name						AS	nation_name,
			MIN(o.o_orderdate)				AS	first_orderdate,
			MAX(o.o_orderdate)				AS	last_orderdate,
			COUNT_BIG(*)					AS	num_orders,
			FORMAT
			(
				COUNT_BIG(*) / t_o.total_orders,
				'##0.00%',
				'en-us'
			)	AS	percentage_share
	FROM	dbo.regions AS r
			INNER JOIN dbo.nations AS n
			ON (r.r_regionkey = n.n_regionkey)
			INNER JOIN dbo.customers AS c
			ON (n.n_nationkey = c.c_nationkey)
			INNER JOIN dbo.orders AS o
			ON (c.c_custkey = o.o_custkey)
			CROSS JOIN
			(
				SELECT	COUNT_BIG(*) * 1.0 AS total_orders
				FROM	dbo.orders
				WHERE	o_orderdate >= @start_date
						AND o_orderdate <= @end_date
			) AS t_o
	WHERE	o.o_orderdate >= @start_date
			AND o.o_orderdate <= @end_date
	GROUP BY
			t_o.total_orders,
			r.r_name,
			n.n_name
	OPTION	(RECOMPILE);
END
GO

BEGIN
	DECLARE @start_date	DATE = '2019-01-01';
	DECLARE @end_date	DATE = '2019-12-31';

	WITH t_o
	AS
	(
		SELECT	COUNT_BIG(*) * 1.0 AS total_orders
		FROM	dbo.orders
		WHERE	o_orderdate >= @start_date
				AND o_orderdate <= @end_date
	)
	SELECT	r.r_name						AS	region_name,
			n.n_name						AS	nation_name,
			MIN(o.o_orderdate)				AS	first_orderdate,
			MAX(o.o_orderdate)				AS	last_orderdate,
			COUNT_BIG(*)					AS	num_orders,
			FORMAT
			(
				COUNT_BIG(*) / t_o.total_orders,
				'##0.00%',
				'en-us'
			)	AS	percentage_share
	FROM	dbo.regions AS r
			INNER JOIN dbo.nations AS n
			ON (r.r_regionkey = n.n_regionkey)
			INNER JOIN dbo.customers AS c
			ON (n.n_nationkey = c.c_nationkey)
			INNER JOIN dbo.orders AS o
			ON (c.c_custkey = o.o_custkey)
			CROSS JOIN t_o
	WHERE	o.o_orderdate >= @start_date
			AND o.o_orderdate <= @end_date
	GROUP BY
			t_o.total_orders,
			r.r_name,
			n.n_name
	OPTION	(RECOMPILE);
END
GO