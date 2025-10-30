# Session - Debunk Myths About CTE
This repository is dedicated to exploring and debunking common myths about Common Table Expressions (CTEs) in SQL Server. Through real-world examples, execution plan analysis, and performance comparisons, we aim to clarify how CTEs actually behave—and when they’re the right tool for the job.

To work with the scripts it is required to have the workshop database [ERP_Demo](https://www.db-berater.de/downloads/ERP_DEMO_2012.BAK) installed on your SQL Server Instance.
The last version of the demo database can be downloaded here:

**https://www.db-berater.de/downloads/ERP_DEMO_2012.BAK**

> Written by
>	[Uwe Ricken](https://www.db-berater.de/uwe-ricken/), 
>	[db Berater GmbH](https://db-berater.de)
> 
> All scripts are intended only as a supplement to demos and lectures
> given by Uwe Ricken.  
>   
> **THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
> ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
> TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
> PARTICULAR PURPOSE.**

**Note**
The database contains a framework for all workshops / sessions from db Berater GmbH
+ Stored Procedures
+ User Definied Inline Functions

Session Scripts for SQL Server Workshop "Debung Myths about CTE"
Version:	1.00.100
Date:		2025-10-14

## Objectives
+ Identify and explain common misconceptions about CTEs
+ Compare CTEs with temp tables, derived tables, and views
+Analyze execution plans and performance implications
+Provide reproducible demos and benchmarks
+Support technical education and myth-busting outreach

## Repository Structure
/01 - Documents and Preparation/           -- PPT and Restore-Script for ERP_Demo_ 
/02 - Basics/        -- Performance comparison queries and results  
/docs/              -- Explanations, diagrams, and session slides  
/tests/             -- Reproducible test cases with expected outcomes  
README.md           -- This file  
LICENSE             -- License information  

## Topics Covered
+ "CTEs are always slower than temp tables"
+ "CTEs materialize results before execution"
+ "CTEs are recursive by default"
+ "CTEs can't be reused or optimized"
+ "CTEs are bad for large datasets"

## Each myth is addressed with:
+ A clear explanation
+ A reproducible SQL example
+ Execution plan insights
+ Performance notes and alternatives

Getting Started
- Clone the repo:
git clone https://github.com/your-org/debunk-cte-myths.git
- Open scripts/demo_cte_vs_temp.sql in SSMS
- Run the examples and review execution plans
- Explore /benchmarks for performance comparisons

## Audience
This content is designed for:
- SQL Server developers and DBAs
- Technical educators and trainers
- Performance analysts and architects
- Anyone curious about how CTEs really work

## License
MIT License. See LICENSE for details.