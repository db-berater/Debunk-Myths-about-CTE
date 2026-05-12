/*
	============================================================================
	File:		05 - feature inlining.sql

	Summary:	This demo script shows the limitations to make a scalar function
				inlineable

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

/* We check the status before the rewrite ...*/
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

/*
	The reason for preventing the function work inlining is the
	used CTE inside the scalar UDF!

	So we rewrite the UDF that it can be used as inlining function.
*/
CREATE OR ALTER FUNCTION demo.get_customer_rating
(
	@c_custkey		BIGINT,
	@last_orderdate	DATE
)
RETURNS CHAR(1)
WITH
	SCHEMABINDING,
	RETURNS NULL ON NULL INPUT
AS
BEGIN
	DECLARE	@return_value CHAR(1);

	SELECT	@return_value = 
			CASE
					WHEN num_orders > 30				THEN 'A'
					WHEN num_orders BETWEEN 21 AND 30	THEN 'B'
					WHEN num_orders BETWEEN 11 AND 20	THEN 'C'
					WHEN num_orders BETWEEN 1 AND 10	THEN 'D'
					ELSE 'E'
			END
	FROM	(
				SELECT	COUNT_BIG(*)	AS	num_orders
				FROM	dbo.orders
				WHERE	o_custkey = @c_custkey
						AND o_orderdate >= DATEFROMPARTS(YEAR(@last_orderdate), 1, 1)
						AND o_orderdate <= DATEFROMPARTS(YEAR(@last_orderdate), 12, 31)
			) AS num_orders;

	RETURN	@return_value;
END
GO

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

/*
	When all restrictions are considered and eliminiated
	the query will run shiny and bright :)
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
WHERE	c_custkey <= CAST(100000 AS BIGINT)
ORDER BY
		c.c_name ASC;
GO