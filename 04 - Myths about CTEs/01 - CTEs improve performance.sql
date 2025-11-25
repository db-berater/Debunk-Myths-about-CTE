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
GO

USE ERP_Demo;
GO

/*
	We create necessary indexes on the dbo.orders table to calculate
	for each country the number of orders and their percentage to all
	orders for a given year
*/
EXEC sp_create_indexes_customers;
EXEC sp_create_indexes_nations;
EXEC sp_create_indexes_regions;
EXEC sp_create_indexes_orders @column_list = N'o_orderkey, o_orderdate, o_custkey';
GO

CREATE OR ALTER PROCEDURE dbo.get_percentage_share_default
	@start_date	DATE = '2019-01-01',
	@end_date	DATE = '2019-12-31'
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	n.n_name,
			MIN(o_orderdate)				AS	first_orderdate,
			MAX(o_orderdate)				AS	last_orderdate,
			COUNT_BIG(*)					AS	num_orders,
			COUNT_BIG(*) / t_o.total_orders	AS	percentage_share
	FROM	dbo.nations AS n
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
			n.n_name
	OPTION	(RECOMPILE);
END
GO

CREATE OR ALTER PROCEDURE dbo.get_percentage_share_cte
	@start_date	DATE = '2019-01-01',
	@end_date	DATE = '2019-12-31'
AS
BEGIN
	SET NOCOUNT ON;

	;WITH nation_count
	AS
	(
		SELECT	n.n_name,
				MIN(o_orderdate)				AS	first_orderdate,
				MAX(o_orderdate)				AS	last_orderdate,
				COUNT_BIG(*)					AS	num_orders
		FROM	dbo.nations AS n
				INNER JOIN dbo.customers AS c
				ON (n.n_nationkey = c.c_nationkey)
				INNER JOIN dbo.orders AS o
				ON (c.c_custkey = o.o_custkey)
	),
	total_count
	AS
	(
		SELECT	COUNT_BIG(*) * 1.0 AS total_orders
		FROM	dbo.orders
		WHERE	o_orderdate >= @start_date
				AND o_orderdate <= @end_date
	)

			CROSS JOIN t_o
	WHERE	o.o_orderdate >= @start_date
			AND o.o_orderdate <= @end_date
	GROUP BY
			t_o.total_orders,
			n.n_name
	OPTION	(RECOMPILE);
END
GO