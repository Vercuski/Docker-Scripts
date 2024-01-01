Pre Installation Steps

1. Create the SonarQube database on your DB Server
   
      | Database | Script |
      | -------- | ------ |
      | MSSQL    | CreateMSSQLDbScript.sql |
      | PostgreSQL | CreatePostgreSQLDbScript.sql |

2. To solve the memory issue with elastic search when starting sonarqube<br>
`wsl -d docker-desktop`<br>
`sysctl -w vm.max_map_count=262144`