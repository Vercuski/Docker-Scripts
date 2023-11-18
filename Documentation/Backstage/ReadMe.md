# Backstage
https://backstage.io/docs/deployment/docker/<br>
To Compile ...<br>
Run `SetupBackstage.bat`<br>
`cd backstage`<br>
`docker image build . -f backstage/packages/backend/Dockerfile --tag backstage`<br>
Need to create the PostGreSQL package and setup the "backstage_plugin_catalog" database catalog<br>
`docker compose up -d`