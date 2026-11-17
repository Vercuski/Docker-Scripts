# Rocket.Chat
Open-source team chat: channels, threads, DMs, file sharing, video calls (Jitsi), omnichannel/livechat, a
marketplace of apps, bots and incoming/outgoing webhooks.<br>
UI + API: http://localhost:3015 (`admin` / `Password123`; from other stacks `http://rocketchat:3000`)<br>

Self-contained: Rocket.Chat needs MongoDB running as a replica set (it tails the oplog), so the stack brings its own
`rocketchat-mongo` (MongoDB 8.0, single-member set `rs0`, not published to the host) and `rocketchat-mongo-init`
initialises the set once. On an empty database the admin comes from `.env` (`ADMIN_USERNAME` / `ADMIN_PASS`) and the
setup wizard is marked complete (`OVERWRITE_SETTING_Show_Setup_Wizard`); later password changes are made in the UI.
Email goes to the **Mailpit** stack.

Any admin setting can be pinned from compose with `OVERWRITE_SETTING_<SettingId>` (forced on every start) or
seeded with `<SettingId>` (first start only).

Alerts: *Administration > Workspace > Integrations > New > Incoming* gives a URL like
`http://localhost:3015/hooks/<id>/<token>` (from other stacks `http://rocketchat:3000/hooks/...`):
```sh
curl -H "Content-Type: application/json" http://localhost:3015/hooks/<id>/<token> -d '{"text":"Deploy finished"}'
```
If saving fails with *lacks the 'message-impersonate' permission*, set *Post as* to a user that is allowed to post
(or give the admin role `message-impersonate` under *Administration > Permissions*). Grafana has a *Webhook* contact point that works with this URL; the REST API is under `/api/v1`
(log in with `POST /api/v1/login`, then send `X-User-Id` / `X-Auth-Token`).

Rocket.Chat contacts its cloud on start (license, statistics); without internet those calls fail and are logged as
errors, which is harmless for local use.

https://docs.rocket.chat/
