/*
	============================================================================
	File:		01 - CTEs improve performance 01.sql

	Summary:	This demo shows that CTEs are equally treaten by the query
				optimizer to JOIN / SubQueries

				THIS SCRIPT IS PART OF THE TRACK:
					"Debunk Myths About CTE"

	Date:		October 2025
	Revion:		November 2025

	SQL Server Version: >= 2016
	============================================================================
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET STATISTICS IO, TIME ON;
GO

USE ERP_Demo;
GO

SELECT  c.c_custkey,
        c.c_name,
        n.n_name,
        r.r_name
FROM    dbo.customers AS c
        INNER JOIN dbo.nations AS n
        ON (c.c_nationkey = n.n_nationkey)
        INNER JOIN dbo.regions AS r
        ON (n.n_regionkey = r.r_regionkey)
WHERE   c.c_mktsegment = 'AUTOMOBILE'
        AND n.n_name = 'Slovenia'
        AND r.r_name = 'EUROPE'
ORDER BY
        c.c_custkey;
GO

/* Maybe the usage of subqueries will improve the query? */
SELECT  c.c_custkey,
        c.c_name,
        n.n_name,
        r.r_name
FROM    (
            SELECT  *
            FROM    dbo.customers AS c
            WHERE   c.c_mktsegment = 'AUTOMOBILE'
        ) AS c
        INNER JOIN
        (
            SELECT  *
            FROM    dbo.nations AS n
            WHERE   n.n_name = 'SLOVENIA'
        ) AS n
        ON (c.c_nationkey = n.n_nationkey)
        INNER JOIN
        (
            SELECT * FROM dbo.regions AS r
            WHERE   r.r_name = 'EUROPE'
        ) AS r
        ON (r.r_regionkey = n.n_regionkey)
ORDER BY
       c.c_custkey;
GO

/* OK - but the experts say, CTE will improve the query! */
;WITH c AS
(
    SELECT  *
    FROM    dbo.customers AS c
    WHERE   c.c_mktsegment = 'AUTOMOBILE'
),
n AS
(
    SELECT  *
    FROM    dbo.nations AS n
    WHERE   n.n_name = 'SLOVENIA'
),
r AS
(
    SELECT  *
    FROM    dbo.regions AS r
    WHERE   r.r_name = 'EUROPE'
)
SELECT  c.c_custkey,
        c.c_name,
        n.n_name,
        r.r_name
FROM    c INNER JOIN n
        ON (c.c_nationkey = n.n_nationkey)
        INNER JOIN r
        ON (r.r_regionkey = n.n_regionkey)
ORDER BY
       c.c_custkey;
GO