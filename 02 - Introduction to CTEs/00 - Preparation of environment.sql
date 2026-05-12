/*
	============================================================================
	File:		00 - preparation of environment.sql

	Summary:	This scripts prepares all tables with necessary indexes
				and clear the Query Store
				
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

/* In the first step we create necessary indexes for better performance */
EXEC dbo.sp_create_indexes_customers;
EXEC dbo.sp_create_indexes_orders @column_list = N'o_orderkey, o_custkey, o_orderdate';
GO

IF NOT EXISTS
(
	SELECT	*
	FROM	sys.indexes AS i
	WHERE	i.object_id = OBJECT_ID(N'dbo.orders')
			AND i.name = N'nix_orders_o_orderdate_o_totalprice'
)
CREATE NONCLUSTERED INDEX nix_orders_o_orderdate_o_totalprice
ON dbo.orders (o_orderdate)
INCLUDE (o_totalprice)
WITH
(
	DATA_COMPRESSION = PAGE,
	SORT_IN_TEMPDB = ON
);
GO

/*
	This part will be used for the demonstration of recursive queries
*/
EXEC sp_create_demo_schema;
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

IF NOT EXISTS
(
	SELECT	*
	FROM	sys.indexes AS i
	WHERE	i.name = N'nix_demo_orders_o_orderdate'
			AND i.object_id = OBJECT_ID(N'demo.orders')
)
    CREATE NONCLUSTERED INDEX nix_demo_orders_o_orderdate
    ON demo.orders (o_orderdate)
    WITH
    (
    	DATA_COMPRESSION = PAGE,
    	SORT_IN_TEMPDB = ON
    );
    GO


/* Afterwards we clear the query store to start with a fresh and clear version store */
EXEC dbo.sp_clear_query_store;
GO

