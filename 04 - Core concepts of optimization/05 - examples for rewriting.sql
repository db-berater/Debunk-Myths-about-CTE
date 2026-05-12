/*
	============================================================================
	File:		05 - examples for rewriting.sql

	Summary:	This script demonstrates the cost based execution plans
				from different variants of writing the same query.
				
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

/* Query 01: JOIN three tables and add the filter predicates! */
SELECT	c.c_custkey,
		c.c_name,
		n.n_name,
		r.r_name
FROM	dbo.customers AS c
		INNER JOIN dbo.nations AS n
		ON (c.c_nationkey = n.n_nationkey)
		INNER JOIN dbo.regions AS r
		ON (n.n_regionkey = r.r_regionkey)
WHERE	c.c_custkey <= 100
		AND r.r_name = 'EUROPE'
ORDER BY
		c.c_custkey;
GO

/* Query 02: Someone tells you to use subqueries because they are faster! */
SELECT	c.c_custkey,
		c.c_name,
		nr.n_name,
		nr.r_name
FROM	dbo.customers AS c
		INNER JOIN
		(
			SELECT	n.n_nationkey,
					n.n_name,
					r.r_name
			FROM	dbo.nations AS n
					INNER JOIN dbo.regions AS r
					ON (n.n_regionkey = r.r_regionkey)
		) AS nr
		ON (c.c_nationkey = nr.n_nationkey)
WHERE	c.c_custkey <= 100
		AND nr.r_name = 'EUROPE'
ORDER BY
		c.c_custkey;
GO

/* Query 03: Someone told you that order of joins matters! */
SELECT	c.c_custkey,
		c.c_name,
		n.n_name,
		r.r_name
FROM	dbo.customers AS c
		INNER JOIN dbo.nations AS n
		INNER JOIN dbo.regions AS r
		ON (n.n_regionkey = r.r_regionkey)
		ON (c.c_nationkey = n.n_nationkey)
WHERE	c.c_custkey <= 100
		AND r.r_name = 'EUROPE'
ORDER BY
		c.c_custkey;
GO

/* Query 04: Advice from INfluencers on LinkedIn - use subqueries! */
SELECT	c.c_custkey,
		c.c_name,
		n.n_name,
		r.r_name
FROM	(
			SELECT	c_custkey,
					c_name,
					c_nationkey
			FROM	dbo.customers
		) AS c
		INNER JOIN
		(
			SELECT	n_nationkey,
					n_name,
					n_regionkey
			FROM	dbo.nations
		) AS n
		ON (c.c_nationkey = n.n_nationkey)
		INNER JOIN
		(
			SELECT	r_regionkey,
					r_name
			FROM	dbo.regions
		) AS r
		ON (n.n_regionkey = r.r_regionkey)
WHERE	c.c_custkey <= 100
		AND r.r_name = 'EUROPE'
ORDER BY
		c.c_custkey;
GO

/* Query 05: Pretty cool tip: Filter the requested data inside the subquery! */
SELECT	c.c_custkey,
		c.c_name,
		n.n_name,
		r.r_name
FROM	(
			SELECT	c_custkey,
					c_name,
					c_nationkey
			FROM	dbo.customers
			WHERE	c_custkey <= 100
		) AS c
		INNER JOIN
		(
			SELECT	n_nationkey,
					n_name,
					n_regionkey
			FROM	dbo.nations
		) AS n
		ON (c.c_nationkey = n.n_nationkey)
		INNER JOIN
		(
			SELECT	r_regionkey,
					r_name
			FROM	dbo.regions
			WHERE	r_name = 'EUROPE'
		) AS r
		ON (n.n_regionkey = r.r_regionkey)
ORDER BY
		c.c_custkey;
GO