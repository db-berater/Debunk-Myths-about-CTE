/*
	============================================================================
	File:		02 - CTEs improve performance.sql

	Summary:	A common misconception about CTEs is that they only use the
				objects they address once. This is completely false.
				A CTE is executed again with EVERY invocation.

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

/*
	A typical scenario under the impression of the
	manifestation of CTE is the following example.
*/
;WITH p
AS
(
	SELECT	p.p_partkey,
			p.p_retailprice
	FROM	dbo.parts AS p
	WHERE	p.p_brand = 'Brand#23'
),
num_recs
AS
(
	SELECT	COUNT_BIG(*)			AS	num_articles
	FROM	p
),
max_price
AS
(
	SELECT	MAX(p.p_retailprice)	AS	max_retail_price
	FROM	p
),
min_price
AS
(
	SELECT	MIN(p.p_retailprice)	AS	min_retail_price
	FROM	p
)
SELECT	*
FROM	num_recs,
		max_price,
		min_price;
GO

CREATE OR ALTER PROCEDURE dbo.get_article_information_default
	@p_brand CHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	COUNT_BIG(*)			AS	num_articles,
			MAX(p.p_retailprice)	AS	max_retailprice,
			MIN(p.p_retailprice)	AS	min_retailprice
	FROM	dbo.parts AS p
	WHERE	p.p_brand = @p_brand
	OPTION	(RECOMPILE, MAXDOP 4);
END
GO

CREATE OR ALTER PROCEDURE dbo.get_article_information_cte
	@p_brand CHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	;WITH p
	AS
	(
		SELECT	p.p_partkey,
				p.p_retailprice
		FROM	dbo.parts AS p
		WHERE	p.p_brand = @p_brand
	),
	num_recs
	AS
	(
		SELECT	COUNT_BIG(*)			AS	num_articles
		FROM	p
	),
	max_price
	AS
	(
		SELECT	MAX(p.p_retailprice)	AS	max_retail_price
		FROM	p
	),
	min_price
	AS
	(
		SELECT	MIN(p.p_retailprice)	AS	min_retail_price
		FROM	p
	)
	SELECT	*
	FROM	num_recs,
			max_price,
			min_price;
END
GO

EXEC dbo.sp_clear_query_store;
GO