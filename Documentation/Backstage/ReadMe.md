# Backstage
https://backstage.io/docs/deployment/docker/

To Compile ...
Run SetupBackstage.bat
cd backstage
docker image build . -f backstage/packages/backend/Dockerfile --tag backstage
Need to create the PostGreSQL package and setup the "backstage_plugin_catalog" database catalog
docker compose up -d