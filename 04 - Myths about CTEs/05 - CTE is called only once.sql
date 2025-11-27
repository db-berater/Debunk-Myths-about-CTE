
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE ERP_Demo;
GO

;WITH l
AS
(
	SELECT	*
	FROM	dbo.orders
	WHERE	o_orderdate >= '2019-01-01'
			AND o_orderdate < '2020-01-01'
)
SELECT * FROM l;