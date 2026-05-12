/*
	============================================================================
	File:		02 - feature description.sql

	Summary:	This script demonstrates the general functionality of the 
				feature "Scalar UDF inlining"

	NOTE:		Run this demo with "Actual Execution Plan" to check the estimates

				Scalar UDF inlining is a SQL Server feature that takes a scalar 
				user‑defined function and automatically rewrites it into the calling 
				query so it no longer runs row‑by‑row.

	Date:		March 2026
	Session:	Evolution of User Defined Functions

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
	Let's start with the basics:
	- A scalar UDF will be executed row by row as a default!
*/
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.sp_clear_query_store;
GO

/*
	Now we check the execution problems with scalar udf's by
	monitoring the execution with an extended event session

	Implement .\80 - Extended Events\xe - scalar udf execution.sql
	before you run the following query again!
*/
SELECT	c.c_custkey,
		c.c_name,
		c.c_last_orderdate,
		demo.get_customer_rating
		(
			c.c_custkey,
			c.c_last_orderdate
		)							AS classification
FROM	demo.customer_orders AS c
WHERE	c_custkey <= CAST(100 AS BIGINT)
ORDER BY
		c.c_name ASC;
GO

/* What is the performance with 1.000 rows? */
SELECT	c.c_custkey,
		c.c_name,
		c.c_last_orderdate,
		demo.get_customer_rating
		(
			c.c_custkey,
			c.c_last_orderdate
		)							AS classification
FROM	demo.customer_orders AS c
WHERE	c_custkey <= CAST(1000 AS BIGINT)
ORDER BY
		c.c_name ASC;
GO

SELECT	c.c_custkey,
		c.c_name,
		c.c_last_orderdate,
		demo.get_customer_rating
		(
			c.c_custkey,
			c.c_last_orderdate
		)							AS classification
FROM	demo.customer_orders AS c
WHERE	c_custkey <= CAST(10000 AS BIGINT)
ORDER BY
		c.c_name ASC;
GO

/*
	Why is this function not going in parallel execution?
*/
SELECT	o.name												AS	function_name,
		o.type												AS	function_type,
		sm.is_inlineable									AS	is_inlineable,
		sm.is_schema_bound									AS	is_schema_bound,
		OBJECTPROPERTYEX(o.object_id, 'SYSTEMDATAACCESS')	AS	check_system_data_access,
		OBJECTPROPERTYEX(o.object_id, 'UserDataAccess')		AS	check_user_data_access
FROM	sys.sql_modules AS sm
		INNER JOIN sys.objects AS o
		ON (sm.object_id = o.object_id)
WHERE	(
			o.type = N'FN'
			OR o.type = N'IF'
		)
		AND
		(
			o.name = 'get_customer_rating'
			OR o.name = 'get_last_order_days_left'
		)
ORDER BY
		function_name ASC;
GO