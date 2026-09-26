# Backstage
https://backstage.io/docs/deployment/docker/<br>
https://backstage.io/docs/features/software-templates/<br>

Requires the PostgreSQL stack (`Databases/PostgreSQL`) to be running. Backstage creates its own
`backstage_plugin_*` databases on first start, so the Postgres user needs CREATEDB (the default superuser has it).

To compile ...<br>
Run `SetupBackstage.bat` (name the app `backstage` so it lands in the git-ignored `backstage` folder)<br>
`cd backstage`<br>
`yarn install --immutable`<br>
`yarn tsc`<br>
`yarn build:backend`<br>
`docker image build . -f packages/backend/Dockerfile --tag backstage`<br>
`cd ..`<br>
`docker compose up -d`<br>

UI: http://localhost:7007
