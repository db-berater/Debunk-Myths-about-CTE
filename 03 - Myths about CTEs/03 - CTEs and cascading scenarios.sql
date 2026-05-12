/*
	============================================================================
	File:		03 - avoid cascading CTE for better performance.sql

	Summary:	This demo shows that simplification is the silver bullet
				to avoid unnecessary calls of query objects!

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

EXEC dbo.sp_activate_query_store;
GO

/*
	Statement:	Use a CTE to prefilter the required data.
				Afterwards filter the rowset from CTE #1
				in another CTE!
*/

;WITH a
AS
(
	/* All data from 2019 */
	SELECT	o_orderkey,
			o_orderdate
	FROM	dbo.orders
	WHERE	o_orderdate >= '2019-01-01'
			AND o_orderdate <= '2019-12-31'
),
b
AS
(
	/* All data from February 2019 */
	SELECT	o_orderkey,
			o_orderdate
	FROM	a
	WHERE	a.o_orderdate >= '2019-02-01'
			AND a.o_orderdate < '2019-03-01'
),
c
AS
(
	/* All data from a specific date */
	SELECT	o_orderkey,
			o_orderdate
	FROM	b
	WHERE	b.o_orderdate = '2019-02-18'
)
SELECT * FROM c
ORDER BY
		o_orderkey;
GO