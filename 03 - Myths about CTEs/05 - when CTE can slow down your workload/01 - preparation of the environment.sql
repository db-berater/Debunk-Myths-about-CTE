/*
	============================================================================
	File:		01 - preparation of the environment.sql

	Summary:	This script prepares a scenario for the demonstration of
				Tipps & Tricks

				THIS SCRIPT IS PART OF THE TRACK:
					"Debunk Myths About CTE"

	SQL Server Version: >= 2019
	============================================================================
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE ERP_Demo;
GO

/*
	First we clean and recreate the demo schema for the demos.
*/
EXEC dbo.sp_clean_demo_environment;
EXEC dbo.sp_create_demo_schema;
GO

EXEC dbo.sp_create_indexes_customers;
EXEC dbo.sp_create_indexes_orders
	@column_list = N'o_orderkey,o_custkey,o_orderdate';
GO

IF NOT EXISTS
(
	SELECT	i.*
	FROM	sys.indexes AS i
	WHERE	i.name = N'nix_orders_o_custkey_o_orderdate'
			AND i.object_id = OBJECT_ID(N'dbo.orders')
)
CREATE NONCLUSTERED INDEX nix_orders_o_custkey_o_orderdate
ON dbo.orders
(
	o_custkey,
	o_orderdate
)
WITH
(
	DATA_COMPRESSION = PAGE,
	SORT_IN_TEMPDB = ON
);
GO

/* We make sure all settings required for this demos are configured correctly! */
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

/*
	This demo shows tips and tricks to improve scalar UDF in general

	1. We create a table demo.customer_orders
	2. We create a user defined scalar function demo.get_customer_rating
*/
DROP FUNCTION IF EXISTS demo.get_customer_orders;
DROP TABLE IF EXISTS demo.customer_orders;
GO

RAISERROR ('creating table [demo].[customer_orders]', 0, 1) WITH NOWAIT;
CREATE TABLE demo.customer_orders
(
	c_custkey			BIGINT		NOT NULL,
	c_name				VARCHAR(25)	NOT NULL,
	c_last_orderdate	DATE		NULL,

	CONSTRAINT pk_demo_customer_orders PRIMARY KEY CLUSTERED (c_custkey)
	WITH (DATA_COMPRESSION = PAGE)
);
GO

RAISERROR ('creating function [demo].[get_customer_rating] in database', 0, 1) WITH NOWAIT;
GO

CREATE OR ALTER FUNCTION demo.get_customer_rating
(
	@c_custkey		BIGINT,
	@last_orderdate	DATE
)
RETURNS CHAR(1)
AS
BEGIN
	DECLARE	@return_value CHAR(1);

	;WITH num_orders
	AS
	(
		SELECT	COUNT_BIG(*)	AS	num_orders
		FROM	dbo.orders
		WHERE	o_custkey = @c_custkey
				AND o_orderdate >= DATEFROMPARTS(YEAR(@last_orderdate), 1, 1)
				AND o_orderdate <= DATEFROMPARTS(YEAR(@last_orderdate), 12, 31)
	)
	SELECT	@return_value = 
			CASE
					WHEN num_orders > 30				THEN 'A'
					WHEN num_orders BETWEEN 21 AND 30	THEN 'B'
					WHEN num_orders BETWEEN 11 AND 20	THEN 'C'
					WHEN num_orders BETWEEN 1 AND 10	THEN 'D'
					ELSE 'E'
			END
	FROM	num_orders;

	RETURN	@return_value;
END
GO

RAISERROR ('creating function [demo].[get_last_order_days_left] in database', 0, 1) WITH NOWAIT;
GO

CREATE OR ALTER FUNCTION demo.get_last_order_days_left
(@last_orderdate DATE)
RETURNS INTEGER
AS
BEGIN
	DECLARE	@return_value INTEGER;

	SET	@return_value = DATEDIFF(DAY, @last_orderdate, GETDATE());

	RETURN	@return_value;
END
GO

RAISERROR ('filling table [demo].[customer_orders] with 1,600,000 rows', 0, 1) WITH NOWAIT;
GO
BEGIN
	INSERT INTO demo.customer_orders WITH (TABLOCK)
	(c_custkey, c_name, c_last_orderdate)
	SELECT	c.c_custkey,
			c.c_name,
			MAX(o.o_orderdate)	AS	c_last_orderdate
	FROM	dbo.customers AS c
			LEFT JOIN dbo.orders AS o
			ON (c.c_custkey = o.o_custkey)
	GROUP BY
			c.c_custkey,
			c.c_name;
END
GO

SELECT	o.name				AS	function_name,
		o.type				AS	function_type,
		sm.is_inlineable	AS	is_inlineable,
		sm.is_schema_bound	AS	is_schema_bound
FROM	sys.sql_modules AS sm
		INNER JOIN sys.objects AS o
		ON (sm.object_id = o.object_id)
WHERE	(
			o.type = N'FN'
			OR o.type = N'IF'
		)
		AND o.schema_id = SCHEMA_ID(N'demo');
GO

SELECT	TOP (10)
		c_custkey,
        c_name,
        c_last_orderdate
FROM	demo.customer_orders;