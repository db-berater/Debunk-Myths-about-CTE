/*
	============================================================================
	File:		04 - feature drawbacks.sql

	Summary:	This script shows the details about the feature drawbacks which
				should be taken into consideration.

	NOTE:		Run this demo with "Actual Execution Plan" to check the estimates

	Date:		March 2026
	Session:	Mastering Intelligent Query Processing

	SQL Server Version: >= 2019
	============================================================================
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET STATISTICS IO, TIME ON;
GO

USE ERP_Demo;
GO

/*
	remember that CTE inside a Scalar Function cannot be used
	for inlining?
*/
;WITH l
AS
(
	SELECT	c_custkey,
			c_name,
			c_last_orderdate
	FROM	demo.customer_orders
	WHERE	c_custkey <= 10000
)
SELECT	l.c_custkey,
        l.c_name,
        l.c_last_orderdate,
		demo.get_customer_rating(l.c_custkey, l.c_last_orderdate) AS rating
FROM	l
ORDER BY
		l.c_name;
GO