# Backstage
https://backstage.io/docs/deployment/docker/<br>
https://backstage.io/docs/features/software-templates/<br>
To Compile ...<br>
Run `SetupBackstage.bat`<br>
`cd backstage`<br>
`yarn install --frozen-lockfile`<br>
`yarn tsc`<br>
`yarn build:backend --config ../../app-config.yaml`<br>
`docker image build . -f packages/backend/Dockerfile --tag backstage`<br>
Need to create the PostGreSQL package and setup the "backstage_plugin_catalog" database catalog<br>
`docker compose up -d`