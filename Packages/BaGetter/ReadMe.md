# BaGetter
Lightweight NuGet and symbol server written in .NET (the maintained fork of BaGet).<br>
UI: http://localhost:5555 · feed: `http://localhost:5555/v3/index.json` (from other containers:
`http://bagetter:8080/v3/index.json`)<br>

```sh
dotnet nuget add source http://localhost:5555/v3/index.json -n bagetter
dotnet nuget push MyLib.1.0.0.nupkg -s http://localhost:5555/v3/index.json -k Password123
```
Pushing and deleting need `BAGETTER_API_KEY`. Packages not found locally are fetched from nuget.org and cached
(`BAGETTER_MIRROR_ENABLED`). Re-pushing the same version overwrites it, which suits local iteration.<br>
SQLite database and package files are in the `data` volume.

https://www.bagetter.com/docs/
