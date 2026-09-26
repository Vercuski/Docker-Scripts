# Docker Registry
Registry API: http://localhost:5000<br>
Registry UI: http://localhost:5001<br>

Push an image:<br>
`docker tag myimage:latest localhost:5000/myimage:latest`<br>
`docker push localhost:5000/myimage:latest`<br>

Deleted images only free disk space after garbage collection:<br>
`docker exec registry-server registry garbage-collect /etc/distribution/config.yml`
