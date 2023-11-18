To solve the memory issue with elastic search when starting sonarqube<br>
`wsl -d docker-desktop`<br>
`sysctl -w vm.max_map_count=262144`