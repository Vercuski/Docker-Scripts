Log in to the Oracle registry and accept the Enterprise Edition license at https://container-registry.oracle.com first:<br>
`docker login container-registry.oracle.com`<br>
<br>
First start takes several minutes while the database is created (watch `docker logs -f OracleDb`).<br>
Connect: `sys/Password123@//localhost:1521/ORCLCDB as sysdba` (PDB: ORCLPDB1)<br>
<br>
Tip: for local development `container-registry.oracle.com/database/free:latest` needs no license acceptance and is much smaller.
