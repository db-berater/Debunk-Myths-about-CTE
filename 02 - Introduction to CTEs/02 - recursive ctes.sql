/*
	============================================================================
	File:		02 - recursive ctes.sql

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
	Recursive cte can help to create temporary lists based on recursive
	elements (e.g. dates)

	Challenge:	We want to have the total number of orders for each
				day in a given time range.

				The problem:	Not all days have orders
				Requirement:	The date MUST be shown in the output
*/
DECLARE	@start_date		DATE = '2019-04-01';
DECLARE	@finish_date	DATE = '2019-04-10';

SELECT	o_orderdate,
		COUNT_BIG(o_orderkey)	AS	num_orders
FROM	demo.orders
WHERE	o_orderdate >= @start_date
		AND o_orderdate <= @finish_date
GROUP BY
		o_orderdate
ORDER BY
		o_orderdate
OPTION	(RECOMPILE);	/* SQL Server should sniff the parameter values! */
GO

/*
	A typical solution is working with temporary objects
	- table variables
	- temporary tables
*/
DECLARE	@start_date		DATE = '2019-04-01';
DECLARE	@finish_date	DATE = '2019-04-10';

DECLARE	@t TABLE (o_orderdate DATE PRIMARY KEY CLUSTERED);
WHILE @start_date <= @finish_date
BEGIN
	INSERT INTO @t (o_orderdate)
	SELECT	@start_date;

	SET	@start_date = DATEADD(DAY, 1, @start_date);
END;

SELECT	t.o_orderdate,
		COUNT_BIG(o.o_orderkey)	AS	num_orders
FROM	@t AS t
		LEFT JOIN demo.orders AS o
		ON (t.o_orderdate = o.o_orderdate)
GROUP BY
		t.o_orderdate
ORDER BY
		t.o_orderdate;
GO

/*
	Go and demonstrate the drawbacks of the baseline solution with SQLQueryStress
	the template is .\97 - SQL Query Stress Templates\02 - recursive CTE - baseline.json
*/

/*
	As an alternative we can avoid writing data into a temporary object
	by using an iterative approach with a recursive CTE.
*/
DECLARE	@start_date		DATE = '2019-04-01';
DECLARE	@finish_date	DATE = '2019-04-10';

;WITH d
AS
(
	SELECT	@start_date		AS	o_orderdate

	UNION ALL

	SELECT	DATEADD(DAY, 1, o_orderdate)
	FROM	d
)
SELECT	*
FROM	d
WHERE	d.o_orderdate < @finish_date;
GO

/*
	The breakpoint MUST be inside the CTE as a break condition!
*/
DECLARE	@start_date		DATE = '2019-04-01';
DECLARE	@finish_date	DATE = '2019-04-10';

;WITH d
AS
(
	SELECT	@start_date		AS	o_orderdate

	UNION ALL

	SELECT	DATEADD(DAY, 1, o_orderdate)
	FROM	d
	WHERE	d.o_orderdate < @finish_date
)
SELECT	*
FROM	d;
GO

/*
	It is important to define the stop condition INSIDE the CTE!
	If you have more than 100 iterations you must use MAXRECURSION!
*/
DECLARE	@start_date		DATE = '2019-01-01';
DECLARE	@finish_date	DATE = '2019-06-30';

;WITH d
AS
(
	SELECT	@start_date		AS	o_orderdate

	UNION ALL

	SELECT	DATEADD(DAY, 1, o_orderdate)
	FROM	d
	WHERE	d.o_orderdate < @finish_date
)
SELECT	*
FROM	d
OPTION (MAXRECURSION 0);
GO

/*
	... final solution for the challenge:
	- we build the date list with the CTE
	- we JOIN the CTE with the demo.orders - table!
*/
DECLARE	@start_date		DATE = '2019-04-01';
DECLARE	@finish_date	DATE = '2019-04-10';

;WITH d
AS
(
	SELECT	@start_date		AS	o_orderdate

	UNION ALL

	SELECT	DATEADD(DAY, 1, o_orderdate)
	FROM	d
	WHERE	d.o_orderdate < @finish_date
)
SELECT	d.o_orderdate,
		COUNT_BIG(o.o_orderkey)	AS	num_orders
FROM	d LEFT JOIN demo.orders AS o
		ON (d.o_orderdate = o.o_orderdate)
GROUP BY
		d.o_orderdate
ORDER BY
		d.o_orderdate;
GO

EXEC dbo.sp_clear_query_store;
GO