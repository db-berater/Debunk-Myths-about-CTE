
IF NOT EXISTS
(
	SELECT	*
	FROM	sys.indexes
	WHERE	object_id = OBJECT_ID(N'dbo.parts', N'U')
			AND name = N'nix_parts_p_retailprice'
)
	CREATE NONCLUSTERED INDEX nix_parts_p_retailprice
	ON dbo.parts (p_brand, p_retailprice)
	WITH
	(
		DATA_COMPRESSION = PAGE,
		SORT_IN_TEMPDB = ON
	);
GO

/* Find the brand#nn with the second highest price */
SELECT	TOP (1)
		p_partkey,
		p_brand,
		p_retailprice	AS	p_retailprice
FROM	dbo.parts
WHERE	p_brand = 'Brand#23'
		AND p_retailprice <
		(
			SELECT	MAX(p_retailprice)
			FROM	dbo.parts
			WHERE	p_brand = 'Brand#23'
		)
ORDER BY
		p_retailprice DESC;
GO

/* As an alternative we can use SELECT TOP in the sub query */
SELECT	TOP (1)
		p_partkey,
		p_brand,
		p_retailprice	AS	p_retailprice
FROM	dbo.parts
WHERE	p_brand = 'Brand#23'
		AND p_retailprice <
		(
			SELECT	TOP (1)
					p_retailprice
			FROM	dbo.parts
			WHERE	p_brand = 'Brand#23'
			ORDER BY
					p_retailprice DESC
		)
ORDER BY
		p_retailprice DESC;
GO

/* What about this solution? */
SELECT	p_brand,
		p_retailprice
FROM	dbo.parts
WHERE	p_brand = 'Brand#23'
ORDER BY
		p_retailprice DESC
OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY;
GO

/* But what about a window function: ROW_NUMBER()? */
SELECT	ROW_NUMBER() OVER (PARTITION BY p_brand ORDER BY p_retailprice DESC) AS rn,
		p_brand,
		p_retailprice
FROM	dbo.parts
WHERE	p_brand = 'Brand#23'
GO

;WITH l
AS
(
	SELECT	ROW_NUMBER() OVER (PARTITION BY p_brand ORDER BY p_retailprice DESC) AS rn,
			p_brand,
			p_retailprice
	FROM	dbo.parts
	WHERE	p_brand = 'Brand#23'
)
SELECT * FROM l
WHERE	rn = 2;
GO