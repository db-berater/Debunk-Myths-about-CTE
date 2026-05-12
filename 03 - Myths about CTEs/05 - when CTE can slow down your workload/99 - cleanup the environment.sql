USE ERP_Demo;
GO

EXEC dbo.sp_clean_demo_environment;
GO

/*
    Drop extended event if exists
*/
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = N'scalar_udf_inlining')
    DROP EVENT SESSION [scalar_udf_inlining] ON SERVER;
GO

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = N'scalar_udf_execution')
    DROP EVENT SESSION [scalar_udf_execution] ON SERVER;
GO

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = N'returns_null_on_null')
    DROP EVENT SESSION [returns_null_on_null] ON SERVER;
GO
