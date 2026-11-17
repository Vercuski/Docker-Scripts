# Verdaccio
Private npm registry that also caches npmjs.org.<br>
UI + registry: http://localhost:4873 (from other containers: `http://verdaccio:4873`)<br>

```sh
npm adduser --registry http://localhost:4873/       # first time: creates the account
npm publish --registry http://localhost:4873/
npm install --registry http://localhost:4873/       # or: npm set registry http://localhost:4873/
```
Packages in the `@local` scope are private (login required to read or publish) and never looked up on npmjs.org;
everything else is proxied from npmjs.org and cached in the `storage` volume. Users live in
`storage/htpasswd`; set `max_users: -1` in `config.yaml` to stop further sign-ups.

https://verdaccio.org/docs/what-is-verdaccio
