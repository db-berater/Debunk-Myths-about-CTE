/*
	============================================================================
	File:		04 - a CTE is executed once but can be reused multipe times.sql

	Summary:	This demo shows that simplification is the silver bullet
				to avoid unnecessary calls of query objects!

				THIS SCRIPT IS PART OF THE TRACK:
					"Debunk Myths About CTE"

	Date:		October 2025
	Revion:		November 2025

	SQL Server Version: >= 2016
	============================================================================
*/
SET STATISTICS TIME, IO ON;
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE ERP_Demo;
GO

;WITH o
AS
(
	SELECT	o_orderkey,
			o_orderdate,
			DATEPART(MONTH, o_orderdate)	AS	order_month,
			o_custkey
	FROM	dbo.orders
	WHERE	o_orderdate >= '2019-01-01'
			AND o_orderdate <= '2019-03-31'
)
SELECT	c.c_custkey,
		c.c_name,
		january.total_january,
		february.total_february,
		march.total_march
FROM	dbo.customers AS c
		CROSS APPLY
		(
			SELECT	COUNT_BIG(*)	AS	total_january
			FROM	o
			WHERE	o.o_custkey = c.c_custkey
					AND o.order_month = 1
		) AS january
		CROSS APPLY
		(
			SELECT	COUNT_BIG(*)	AS	total_february
			FROM	o
			WHERE	o.o_custkey = c.c_custkey
					AND o.order_month = 2
		) AS february
		CROSS APPLY
		(
			SELECT	COUNT_BIG(*)	AS	total_march
			FROM	o
			WHERE	o.o_custkey = c.c_custkey
					AND o.order_month = 3
		) AS march

WHERE	c.c_custkey <= 1000;
GO

/*
	The better solution will be a PIVOT table with the CTE.
	In this case the CTE will be executed only ONCE!
*/
;WITH o AS
(
	SELECT	o_orderkey,
			o_orderdate,
			DATEPART(MONTH, o_orderdate) AS order_month,
			o_custkey
    FROM	dbo.orders
    WHERE	o_orderdate >= '2019-01-01'
			AND o_orderdate <= '2019-06-30'
),
order_counts AS
(
	SELECT	o.o_custkey,
			o.order_month,
			COUNT_BIG(*)	AS total_orders
    FROM	o
    GROUP BY
			o.o_custkey,
			o.order_month
)
SELECT	c.c_custkey,
		c.c_name,
		ISNULL(p.[1],0) AS total_january,
		ISNULL(p.[2],0) AS total_february,
		ISNULL(p.[3],0) AS total_march
FROM	dbo.customers AS c
		LEFT JOIN
		(
			SELECT	*
			FROM	order_counts
			PIVOT
			(
				SUM(total_orders)
				FOR order_month IN ([1],[2],[3])
			) AS pvt
		) AS p
			ON c.c_custkey = p.o_custkey
WHERE c.c_custkey <= 1000;
GO
