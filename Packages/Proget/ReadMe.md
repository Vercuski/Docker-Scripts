# ProGet
Requires the MSSQL stack (`Databases/MSSQL`). Create the login and database first, e.g.:<br>
```sql
CREATE LOGIN [Proget] WITH PASSWORD = N'Password123', CHECK_POLICY = OFF;
CREATE DATABASE [Proget];
GO
USE [Proget];
CREATE USER [Proget] FOR LOGIN [Proget];
ALTER ROLE db_owner ADD MEMBER [Proget];
```
`docker compose up -d`<br>
`docker compose down`<br>
http://localhost:8091 (https://localhost:8092)<br>
