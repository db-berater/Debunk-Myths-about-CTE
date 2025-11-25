/*
	============================================================================
	File:		01 - Preparation of demo databases.sql

	Summary:	This script restores the database ERP_Demo from
				the backup medium for distribution of data.
				
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

/*
	The following query should list all supplier
	who have more than the avg quantity of a specific
	product available
*/
SELECT	o.o_orderkey,
		o.o_orderdate,
		l.l_linenumber,
		l.l_partkey,
		p.p_name,
		DATEDIFF(DAY, l.l_shipdate, l.l_receiptdate)	AS	delivery_days,
		avg_delivery.delivery_time						AS	avg_delivery_days
FROM	dbo.orders AS o
		INNER JOIN dbo.lineitems AS l
		ON (o.o_orderkey = l.l_orderkey)
		INNER JOIN dbo.parts AS p
		ON (l.l_partkey = p.p_partkey)
		INNER JOIN
		(
			SELECT	li.l_partkey,
					AVG
					(
						DATEDIFF(DAY, li.l_shipdate, li.l_receiptdate)
					)			AS delivery_time
			FROM	dbo.lineitems AS li
			GROUP BY
					li.l_partkey
		) AS avg_delivery
		ON l.l_partkey = avg_delivery.l_partkey
WHERE	o.o_orderdate >= '2010-01-01'
		AND o.o_orderdate <= '2010-01-31'
		AND DATEDIFF(DAY, l.l_shipdate, l.l_receiptdate) > avg_delivery.delivery_time
ORDER BY
		o.o_orderkey,
		l.l_linenumber
GO

/*
	What Information can we get out of the query:
	- We want only orders from 2010-01-01 to 2010-01-31
	- We want to know the parts name for each lineitem
	- We want to know the total delivery days for the lineitem
	- We only want lineitems where the total delivery time is larger than the avg delivery time

	Now we split this information in smaller chunks to "optimize" the query
	- Let's first get the delivery days for each partkey in the lineitems	(dates_per_part)
	- calculate the avg delivery time for each partkey						(avg_per_part)
	- Search for all lineitems where the delivery of the part took longer than the avg

	Watch out for the costs!!!
*/
;WITH dates_per_part
AS
(
	SELECT	l.l_orderkey,
			l.l_linenumber,
			l.l_partkey,
			l.l_shipdate,
			l.l_receiptdate,
			DATEDIFF(DAY, l.l_shipdate, l.l_receiptdate)	AS	days_shipped
	FROM	dbo.lineitems AS l
),
avg_per_part
AS
(
	SELECT	dpp.l_partkey,
			AVG(dpp.days_shipped)	AS	avg_days_shipped
	FROM	dates_per_part AS dpp
	GROUP BY
			dpp.l_partkey
)
SELECT	o.o_orderkey,
		o.o_orderdate,
		l.l_linenumber,
		l.l_partkey,
		p.p_name,
		dpp.days_shipped		AS	delivery_days,
		app.avg_days_shipped	AS	avg_days_shipped
FROM	dbo.orders AS o
		INNER JOIN dbo.lineitems AS l
		ON (o.o_orderkey = l.l_orderkey)
		INNER JOIN dbo.parts AS p
		ON (l.l_partkey = p.p_partkey)
		INNER JOIN dates_per_part AS dpp
		ON
		(
			l.l_orderkey = dpp.l_orderkey
			AND l.l_linenumber = dpp.l_linenumber
		)
		INNER JOIN avg_per_part AS app
		ON (l.l_partkey = app.l_partkey)
WHERE	o.o_orderdate >= '2010-01-01'
		AND o.o_orderdate <= '2010-01-31'
		AND dpp.days_shipped > app.avg_days_shipped
ORDER BY
		o.o_orderkey,
		l.l_linenumber;
GO

