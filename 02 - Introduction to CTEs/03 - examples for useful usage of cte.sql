/*
	============================================================================
	File:		03 - examples for useful usage of cte.sql

	Summary:	This script demonstrates a few useful scenarios where CTE
				can help making the code easier to read.
				
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
	Challenge:	For a given month we want to know for each week the
				weekday with the highest number of orders
*/
SELECT	o_orderdate,
		calendar_week,
		num_orders
FROM	(
			SELECT	ROW_NUMBER() OVER (PARTITION BY calendar_week ORDER BY num_orders DESC) AS day_rank,
					o_orderdate,
					calendar_week,
					num_orders
			FROM	(
						SELECT	o_orderdate,
								DATEPART(WEEK, o_orderdate) AS calendar_week,
								COUNT_BIG(*) AS num_orders
						FROM	dbo.orders
						WHERE	o_orderdate >= '2020-01-01'
								AND o_orderdate < '2020-02-01'
						GROUP BY
								o_orderdate
					) AS daily_counts
		) AS ranked_days
WHERE	day_rank = 1
ORDER BY
		calendar_week;
GO


/*
	Challenge:	For a given month we want to know for each week the
				weekday with the highest number of orders
*/
;WITH l
AS
(
	/* Let's first get the required rowset for further analysis */
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
	/* Now we use the previous rowset for further data operations */
	SELECT	ROW_NUMBER() OVER (PARTITION BY calendar_week ORDER BY num_orders DESC) AS rn,
			l.o_orderdate,
            l.calendar_week,
            l.num_orders
	FROM l
)
SELECT	rn,
		o_orderdate,
		calendar_week,
		num_orders
FROM	r
WHERE	rn = 1;
GO