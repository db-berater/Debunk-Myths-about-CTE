/*
	============================================================================
	File:		02 - CTEs are materialized - 02.sql

	Summary:	A common misconception about CTEs is that they are materialized
				in Microsoft SQL Server. This is not true.

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

SET STATISTICS IO ON;
GO

CREATE OR ALTER PROCEDURE dbo.get_num_orders_cte
	@o_orderdate_begin	DATE,
	@o_orderdate_end	DATE,
	@brand_name			CHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	WITH o
	AS
	(
		SELECT	o_orderkey
		FROM	dbo.orders
		WHERE	o_orderdate >= @o_orderdate_begin
				AND o_orderdate <= @o_orderdate_end
	),
	p
	AS
	(
		SELECT	p_partkey
		FROM	dbo.parts
		WHERE	p_brand = @brand_name
	)
	SELECT	COUNT_BIG(*)	AS	total_order_count
	FROM	o INNER JOIN dbo.lineitems AS l
			ON (o.o_orderkey = l.l_orderkey)
			INNER JOIN p
			ON (l.l_partkey = p.p_partkey);
END
GO

CREATE OR ALTER PROCEDURE dbo.get_num_orders_tmp_table
	@o_orderdate_begin	DATE,
	@o_orderdate_end	DATE,
	@brand_name			CHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #o (o_orderkey BIGINT NOT NULL PRIMARY KEY CLUSTERED);
	CREATE TABLE #p (p_partkey BIGINT NOT NULL PRIMARY KEY CLUSTERED);

	BEGIN
		INSERT INTO #o (o_orderkey)
		SELECT	o_orderkey
		FROM	dbo.orders
		WHERE	o_orderdate >= @o_orderdate_begin
				AND o_orderdate <= @o_orderdate_end

		INSERT INTO #p (p_partkey)
		SELECT	p_partkey
		FROM	dbo.parts
		WHERE	p_brand = @brand_name
	END

	SELECT	COUNT_BIG(*)	AS	total_order_count
	FROM	#o AS o INNER JOIN dbo.lineitems AS l
			ON (o.o_orderkey = l.l_orderkey)
			INNER JOIN #p AS p
			ON (l.l_partkey = p.p_partkey)
	OPTION	(MAXDOP 4);
END
GO