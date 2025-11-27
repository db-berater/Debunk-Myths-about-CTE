/*
	============================================================================
	File:		03 - reuse of ctes.sql

	Summary:	This scripts demonstrates how CTE can be reused
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

USE ERP_demo;
GO

/*
	Another usage for CTE is the filtering for a specific number of rows
	What day of the week did we have the most orders?
*/
SET STATISTICS IO, TIME ON;
GO

;WITH l
AS
(
	SELECT	o_orderdate,
			DATEPART(WEEK, o_orderdate)	AS	calendar_week,
			COUNT_BIG(*)	AS	num_orders
	FROM	dbo.orders
	WHERE	o_orderdate >= '2020-01-01'
			AND o_orderdate < '2020-02-01'
	GROUP BY
			o_orderdate
),
r
AS
(
	SELECT	ROW_NUMBER() OVER (PARTITION BY calendar_week ORDER BY num_orders DESC) AS rn,
			* FROM l
)
SELECT	*
FROM	r
WHERE	rn = 1;
GO