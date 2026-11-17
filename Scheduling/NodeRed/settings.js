// Node-RED settings for the Docker-Scripts stack (mounted read-only as /data/settings.js).
// Credentials come from the container environment (docker-compose.yml / .env): the admin password is hashed with
// bcrypt here at start, so .env holds plain text like the other stacks.
const bcrypt = require("bcryptjs");

module.exports = {
    uiPort: 1880,
    flowFile: "flows.json",
    flowFilePretty: true,
    // Encrypts credentials stored in flows_cred.json - keep it once flows with credentials exist
    credentialSecret: process.env.NODE_RED_CREDENTIAL_SECRET,

    // Editor and admin API login
    adminAuth: {
        type: "credentials",
        users: [{
            username: process.env.NODE_RED_ADMIN_USER || "admin",
            password: bcrypt.hashSync(process.env.NODE_RED_ADMIN_PASSWORD || "Password123", 8),
            permissions: "*"
        }]
    },

    // HTTP-in endpoints of your flows (/hello etc.) stay open; protect them in the flow if needed
    diagnostics: { enabled: true, ui: true },
    runtimeState: { enabled: false, ui: false },
    telemetry: { enabled: false },
    logging: { console: { level: process.env.NODE_RED_LOG_LEVEL || "info", metrics: false, audit: false } },
    exportGlobalContextKeys: false,
    externalModules: {},
    editorTheme: {
        projects: { enabled: false },
        codeEditor: { lib: "monaco" },
        tours: false
    },
    functionExternalModules: true,
    functionTimeout: 0,
    debugMaxLength: 1000,
    mqttReconnectTime: 15000,
    serialReconnectTime: 15000
};
