/*
	============================================================================
	File:		04 - recursive ctes.sql

	Summary:	This scripts demonstrates the concept of recursion with CTEs
				
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
	Let's create a demo table with hierarchically data structures
*/
EXEC sp_create_demo_schema;
GO

/*
	recursive CTE are perfect for date ranges and/or number ranges
*/
;WITH d
AS
(
	SELECT	CAST(GETDATE() AS DATE)		AS	date_col
	UNION ALL

	SELECT	DATEADD(DAY, 1, date_col)	AS	date_col
	FROM	d
)
SELECT	*
FROM	d
WHERE	d.date_col <= DATEADD(DAY, 7, GETDATE());
GO

;WITH d
AS
(
	SELECT	CAST(GETDATE() AS DATE)		AS	date_col
	UNION ALL

	SELECT	DATEADD(DAY, 1, date_col)	AS	date_col
	FROM	d
	WHERE	d.date_col <= DATEADD(DAY, 7, GETDATE())
)
SELECT	*
FROM	d
GO

/*
	Before SQL Server 2022 we didn't hat GENERATE_SERIES()
	So we tried it with CTE(s)
*/
DECLARE	@start_point BIGINT = 10;
DECLARE	@end_point	BIGINT	= 1000;
DECLARE	@interval	INT		= 5;
WITH s
AS
(
	SELECT	@start_point		AS	value

	UNION ALL

	SELECT	value + @interval	AS	value
	FROM	s
	WHERE	value < @end_point
)
SELECT value FROM s
OPTION (MAXRECURSION 0);
GO

/*
	Let's see all orders from a given week.
	We want include all days which did not have any orders
*/
EXEC dbo.sp_create_demo_schema;
GO

DROP TABLE IF EXISTS demo.orders;
GO

SELECT	*
INTO	demo.orders
FROM	dbo.orders AS o
WHERE	o.o_orderdate >= '2019-01-01'
		AND o.o_orderdate < '2019-07-01'
		AND DATEPART(WEEKDAY, o.o_orderdate) <> 1;
GO

ALTER TABLE demo.orders ADD CONSTRAINT pk_demo_orders
PRIMARY KEY CLUSTERED (o_orderkey)
WITH
(
	DATA_COMPRESSION = PAGE,
	SORT_IN_TEMPDB = ON
);
GO

CREATE NONCLUSTERED INDEX nix_demo_orders_o_orderdate
ON demo.orders (o_orderdate)
WITH
(
	DATA_COMPRESSION = PAGE,
	SORT_IN_TEMPDB = ON
);
GO

DECLARE	@start_date	DATE = '2019-01-01';
DECLARE	@end_date	DATE = '2019-01-07';

SELECT	o.o_orderdate,
		COUNT_BIG(o.o_orderdate)	AS	num_orders
FROM	demo.orders AS o
WHERE	o.o_orderdate >= @start_date
		AND o.o_orderdate <= @end_date
GROUP BY
		o.o_orderdate
OPTION	(RECOMPILE);
GO

DECLARE	@start_date	DATE = '2019-01-01';
DECLARE	@end_date	DATE = '2019-01-07';

WITH d
AS
(
	SELECT	@start_date	AS	o_orderdate

	UNION ALL

	SELECT	DATEADD(DAY, 1, o_orderdate)
	FROM	d
	WHERE	o_orderdate < @end_date
)
SELECT	d.o_orderdate,
		COUNT_BIG(o.o_orderkey)	AS	num_orders
FROM	d LEFT JOIN demo.orders AS o
		ON (d.o_orderdate = o.o_orderdate)
GROUP BY
		d.o_orderdate
ORDER BY
		d.o_orderdate
OPTION	(RECOMPILE);
GO