"""Registers the Databases round in the repo-wide files: 10 new stacks (RavenDB, Garnet, Valkey, Qdrant, CouchDB,
Couchbase, ScyllaDB, TimescaleDB, Memcached, CloudBeaver), EventStoreDb -> KurrentDB, Prometheus moved to
Observability, PostgreSQL on the pgvector image.
Run from the repo root. Keeps line endings; refuses to apply twice."""
import sys

MARK = 'KurrentDB'


def patch(path, edits, mark=MARK):
    raw = open(path, 'rb').read()
    crlf = b'\r\n' in raw
    text = raw.decode('utf-8').replace('\r\n', '\n')
    if mark in text:
        print(f'skip {path}: already patched'); return
    for old, new in edits:
        n = text.count(old)
        if n != 1:
            sys.exit(f'{path}: anchor found {n} times: {old[:70]!r}')
        text = text.replace(old, new)
    if crlf:
        text = text.replace('\n', '\r\n')
    open(path, 'wb').write(text.encode('utf-8'))
    print(f'patched {path} ({"CRLF" if crlf else "LF"})')


# ---------------------------------------------------------------- CreateVolumes.sh
V = 'mkdir -p "$ROOT/docker/volumes/'
patch('CreateVolumes.sh', [
    (V + 'Databases/ClickHouse/logs"\n',
     V + 'Databases/ClickHouse/logs"\n' + V + 'Databases/CloudBeaver/workspace"\n'),
    (V + 'Databases/CockroachDB/data"\n'
     + V + 'Databases/EventStoreDb/data"\n'
     + V + 'Databases/EventStoreDb/logs"\n',
     V + 'Databases/CockroachDB/data"\n'
     + V + 'Databases/Couchbase/data"\n'
     + V + 'Databases/CouchDB/data"\n'
     + V + 'Databases/Garnet/data"\n'),
    (V + 'Databases/InfluxDb/data"\n',
     V + 'Databases/InfluxDb/data"\n'
     + V + 'Databases/KurrentDB/data"\n'
     + V + 'Databases/KurrentDB/logs"\n'),
    (V + 'Databases/PostgreSQL/pgadmin4data"\n'
     + V + 'Databases/Prometheus/prometheus_data"\n'
     + V + 'Databases/Prometheus/alertmanager"\n'
     + V + 'Databases/Redis/cache"\n',
     V + 'Databases/PostgreSQL/pgadmin4data"\n'
     + V + 'Databases/Qdrant/storage"\n'
     + V + 'Databases/RavenDB/data"\n'
     + V + 'Databases/Redis/cache"\n'
     + V + 'Databases/ScyllaDB/data"\n'
     + V + 'Databases/TimescaleDB/data"\n'
     + V + 'Databases/Valkey/data"\n'),
    (V + 'Observability/OpenTelemetry/loki"\n',
     V + 'Observability/OpenTelemetry/loki"\n'
     + V + 'Observability/Prometheus/prometheus_data"\n'
     + V + 'Observability/Prometheus/alertmanager"\n'),
    ('  own 1000:1000   Databases/EventStoreDb/data Databases/EventStoreDb/logs\n',
     '  own 1654:1654   Databases/Garnet/data                                                          # garnet\n'
     '  own 1001:1001   Databases/KurrentDB/data Databases/KurrentDB/logs                               # kurrent\n'),
    ('  own 65534:65534 Databases/Prometheus/prometheus_data Databases/Prometheus/alertmanager          # nobody\n',
     '  own 999:999     Databases/RavenDB/data                                                         # ravendb\n'
     '  own 998:1000    Databases/ScyllaDB/data                                                        # scylla\n'),
    ('  own 10001:10001 Observability/OpenTelemetry/tempo Observability/OpenTelemetry/loki\n',
     '  own 10001:10001 Observability/OpenTelemetry/tempo Observability/OpenTelemetry/loki\n'
     '  own 65534:65534 Observability/Prometheus/prometheus_data Observability/Prometheus/alertmanager  # nobody\n'),
])

# ---------------------------------------------------------------- CreateVolumes.bat
M = 'call :mk '
patch('CreateVolumes.bat', [
    (M + 'Databases\\ClickHouse\\logs\n',
     M + 'Databases\\ClickHouse\\logs\n' + M + 'Databases\\CloudBeaver\\workspace\n'),
    (M + 'Databases\\CockroachDB\\data\n'
     + M + 'Databases\\EventStoreDb\\data\n'
     + M + 'Databases\\EventStoreDb\\logs\n',
     M + 'Databases\\CockroachDB\\data\n'
     + M + 'Databases\\Couchbase\\data\n'
     + M + 'Databases\\CouchDB\\data\n'
     + M + 'Databases\\Garnet\\data\n'),
    (M + 'Databases\\InfluxDb\\data\n',
     M + 'Databases\\InfluxDb\\data\n'
     + M + 'Databases\\KurrentDB\\data\n'
     + M + 'Databases\\KurrentDB\\logs\n'),
    (M + 'Databases\\PostgreSQL\\pgadmin4data\n'
     + M + 'Databases\\Prometheus\\prometheus_data\n'
     + M + 'Databases\\Prometheus\\alertmanager\n'
     + M + 'Databases\\Redis\\cache\n',
     M + 'Databases\\PostgreSQL\\pgadmin4data\n'
     + M + 'Databases\\Qdrant\\storage\n'
     + M + 'Databases\\RavenDB\\data\n'
     + M + 'Databases\\Redis\\cache\n'
     + M + 'Databases\\ScyllaDB\\data\n'
     + M + 'Databases\\TimescaleDB\\data\n'
     + M + 'Databases\\Valkey\\data\n'),
    (M + 'Observability\\OpenTelemetry\\loki\n',
     M + 'Observability\\OpenTelemetry\\loki\n'
     + M + 'Observability\\Prometheus\\prometheus_data\n'
     + M + 'Observability\\Prometheus\\alertmanager\n'),
])

# ---------------------------------------------------------------- README.md
patch('README.md', [
    ('Spark, Flink, JupyterLab, Oracle, EventStoreDB, Wazuh), using `sudo`.',
     'Spark, Flink, JupyterLab, Oracle, KurrentDB, Garnet, RavenDB, ScyllaDB, Wazuh), using `sudo`.'),
    ('|CockroachDB|CockroachDB| 172.20.6.30|\n'
     '|EventStoreDb|EventStoreDB| 172.20.6.40|\n',
     '|CockroachDB|CockroachDB| 172.20.6.30|\n'
     '|KurrentDB|KurrentDB (formerly EventStoreDB)| 172.20.6.40|\n'),
    ('|PostgreSQL|PostgreSQL| 172.20.6.130|\n', '|PostgreSQL|PostgreSQL (with pgvector)| 172.20.6.130|\n'),
    ('|Prometheus|Prometheus| 172.20.6.140|\n'
     '|Prometheus|Prometheus Node Exporter| 172.20.6.141|\n'
     '|Prometheus|Prometheus Alertmanager| 172.20.6.142|\n'
     '|Redis|Redis| 172.20.6.150|\n',
     '| *(.140-.149 free: Prometheus moved to Observability)*| | |\n'
     '|Redis|Redis| 172.20.6.150|\n'
     '|RavenDB|RavenDB| 172.20.6.160|\n'
     '|CouchDB|CouchDB| 172.20.6.170|\n'
     '|CouchDB|CouchDB setup (one-shot)| 172.20.6.171|\n'
     '|Couchbase|Couchbase Server CE| 172.20.6.180|\n'
     '|Couchbase|Couchbase setup (one-shot)| 172.20.6.181|\n'
     '|Garnet|Garnet| 172.20.6.190|\n'
     '|Memcached|Memcached| 172.20.6.200|\n'
     '|Qdrant|Qdrant| 172.20.6.210|\n'
     '|ScyllaDB|ScyllaDB| 172.20.6.220|\n'
     '|CloudBeaver|CloudBeaver| 172.20.6.230|\n'
     '|TimescaleDB|TimescaleDB| 172.20.6.240|\n'
     '|Valkey|Valkey| 172.20.6.250|\n'),
    ('|OpenTelemetry|Loki| 172.20.11.22|\n',
     '|OpenTelemetry|Loki| 172.20.11.22|\n'
     '|Prometheus|Prometheus| 172.20.11.30|\n'
     '|Prometheus|Prometheus Node Exporter| 172.20.11.31|\n'
     '|Prometheus|Prometheus Alertmanager| 172.20.11.32|\n'),
])

# ---------------------------------------------------------------- CLAUDE.md
patch('CLAUDE.md', [
    ('and Prometheus (`Databases/Prometheus`, which scrapes',
     'and Prometheus (`Observability/Prometheus`, which scrapes'),
    ('- Grafana provisions Prometheus,',
     '- CloudBeaver → PostgreSQL, TimescaleDB, MSSQL, MySQL, MariaDB and ClickHouse stacks (connections seeded from `Databases/CloudBeaver/initial-data-sources.conf` into an empty workspace)\n'
     '- RavenDB and Couchbase publish host-reachable addresses (`localhost:<port>`) to their clients; clients on GroupNetwork use the alias (RavenDB also needs `DisableTopologyUpdates`)\n'
     '- Grafana provisions Prometheus,'),
], mark='Observability/Prometheus')

# ---------------------------------------------------------------- REVIEW.md
patch('REVIEW.md', [
    (' · 1113/2113 EventStore · ', ' · 2113 KurrentDB · '),
    (' · 8104 Harbor\n',
     ' · 8104 Harbor · 8105/38888 RavenDB · 6380 Garnet · 6381 Valkey · 11211 Memcached · 6333/6334 Qdrant'
     ' · 5984 CouchDB · 8107-8110/11210 Couchbase · 9043/8106 ScyllaDB CQL/Alternator · 5433 TimescaleDB · 8978 CloudBeaver\n'),
    ('1. **EventStoreDB** `20.10.2-buster-slim` is from 2021.',
     '1. ~~**EventStoreDB**~~ *Done 2026-11-16: replaced by `Databases/KurrentDB`.* `20.10.2-buster-slim` is from 2021.'),
], mark='2113 KurrentDB')
raw = open('REVIEW.md', 'rb').read()
if b'## New stacks added (2026-11-16): Databases' not in raw:
    nl = '\r\n' if b'\r\n' in raw else '\n'
    section = '''
## New stacks added (2026-11-16): Databases

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| RavenDB 7.2 | Databases/RavenDB | .160 | 8105, 38888 | Unsecured dev mode. Listens on the host port numbers inside the container (it calls itself on its public URL `http://localhost:8105`). |
| CouchDB 3.5.3 | Databases/CouchDB | .170/.171 | 5984 | `couchdb-init` runs `_cluster_setup` single-node once. |
| Couchbase Server CE 8.0.2 | Databases/Couchbase | .180/.181 | 8107-8110, 11210 | `couchbase-init` initialises the cluster and bucket `dev`, and registers the remapped ports as external alternate addresses. |
| Garnet 2.1 | Databases/Garnet | .190 | 6380 | Redis protocol; checkpoints to the data folder and recovers on start. |
| Memcached 1.6 | Databases/Memcached | .200 | 11211 | No volume. |
| Qdrant v1.20.2 | Databases/Qdrant | .210 | 6333, 6334 | API key `Password123`. |
| ScyllaDB 2026.3 | Databases/ScyllaDB | .220 | 9043, 8106 | Developer mode; CQL plus Alternator (DynamoDB API). |
| CloudBeaver 26.2.5 | Databases/CloudBeaver | .230 | 8978 | Auto-configured admin; six seeded connections to the SQL stacks. |
| TimescaleDB 2.32.0-pg18 | Databases/TimescaleDB | .240 | 5433 | PostgreSQL 18 + TimescaleDB. |
| Valkey 9.0 | Databases/Valkey | .250 | 6381 | AOF persistence. |

Changes to existing stacks:
- **PostgreSQL** now uses `pgvector/pgvector:pg18-trixie` (same Debian base as `postgres:18`; tested against a data folder created by `postgres:18`). The image variable is now `PGVECTOR_VERSION`.
- **EventStoreDb → KurrentDB** (`kurrentplatform/kurrentdb:26.2`): new folder, container `kurrentdb`, new data folder `Databases/KurrentDB`, gRPC on 2113 only (port 1113 is gone), `KURRENTDB_*` settings. The `eventstoredb` alias is kept. The old `Databases/EventStoreDb` volume folder is not touched; the old Docker volumes `eventstore-volume-data` / `eventstore-volume-logs` can be removed with `docker volume rm`.
- **Prometheus** moved to `Observability/Prometheus`: IPs 172.20.11.30-.32, data under `docker/volumes/Observability/Prometheus`. The alias `prometheus`, port 9090 and the volume names are unchanged, so Docker must forget the old volume definitions once (`docker volume rm prometheus_data alertmanager_data`, which doesn't delete the files).
'''
    open('REVIEW.md', 'ab').write(section.replace('\n', nl).encode('utf-8'))
    print('appended REVIEW.md section')

# ---------------------------------------------------------------- Claude outputs/Home.html
def row(cat, name, ports, ip):
    return ('                        <tr>\n'
            f'                            <td>{cat}</td>\n'
            f'                            <td>{name}</td>\n'
            f'                            <td>{ports}</td>\n'
            f'                            <td>{ip}</td>\n'
            '                        </tr>\n')

def link(port, path=''):
    return f'<a href="http://localhost:{port}/{path}" target="_blank">:{port}</a>'

def copy(text):
    return (f'<span style="cursor: pointer" onclick="ClipBoardText(\'{text}\')"><i\n'
            '                                class="fa-regular fa-copy"></i></span>')

def item(title, lines):
    body = ''.join(f'                        {l}<br />\n' for l in lines)
    return ('                    <li>\n'
            f'                        <font style="font-size: 1.2rem; font-weight: bold">{title}</font><br />\n'
            + body + '                    </li>\n')

ES_ROW = row('Databases', 'EventStoreDB', link(2113) + ' HTTP, :1113 TCP', '6.40')
PROM_ROW = ('                        <tr>\n'
            '                            <td>Databases</td>\n'
            '                            <td>Prometheus</td>\n'
            '                            <td><a href="http://localhost:9090/" target="_blank">:9090</a>, :9100 node exporter, <a\n'
            '                                    href="http://localhost:9093/" target="_blank">:9093</a> Alertmanager</td>\n'
            '                            <td>6.140 / 6.141 / 6.142</td>\n'
            '                        </tr>\n')
REDIS_ROW = row('Databases', 'Redis', ':6379', '6.150')
NEW_ROWS = (REDIS_ROW
            + row('Databases', 'RavenDB', link(8105) + ' Studio, :38888 TCP', '6.160')
            + row('Databases', 'CouchDB', link(5984, '_utils') + ' Fauxton + API', '6.170')
            + row('Databases', 'Couchbase CE', link(8107) + ' console, :8108-8110 views/query/search, :11210 KV', '6.180')
            + row('Databases', 'Garnet', ':6380', '6.190')
            + row('Databases', 'Memcached', ':11211', '6.200')
            + row('Databases', 'Qdrant', link(6333, 'dashboard') + ' REST + dashboard, :6334 gRPC', '6.210')
            + row('Databases', 'ScyllaDB', ':9043 CQL, :8106 Alternator (DynamoDB API)', '6.220')
            + row('Databases', 'CloudBeaver', link(8978), '6.230')
            + row('Databases', 'TimescaleDB', ':5433', '6.240')
            + row('Databases', 'Valkey', ':6381', '6.250'))
LOKI_ROW = row('Observability', 'Tempo / Loki', ':3200 Tempo, :3100 Loki', '11.21 / 11.22')
PROM_OBS_ROW = ('                        <tr>\n'
                '                            <td>Observability</td>\n'
                '                            <td>Prometheus</td>\n'
                '                            <td><a href="http://localhost:9090/" target="_blank">:9090</a>, :9100 node exporter, <a\n'
                '                                    href="http://localhost:9093/" target="_blank">:9093</a> Alertmanager</td>\n'
                '                            <td>11.30 / 11.31 / 11.32</td>\n'
                '                        </tr>\n')

OLD_ES_ITEM = '''                    <li>
                        <font style="font-size: 1.2rem; font-weight: bold">Event Store DB</font><br />
                        Connection String: esdb://localhost:2113?tls=false <span style="cursor: pointer"
                            onclick="ClipBoardText('esdb://localhost:2113?tls=false')"><i
                                class="fa-regular fa-copy"></i></span><br />
                        Management URL (http): <a href="http://localhost:2113/"
                            target="_blank">http://localhost:2113/</a><br />
                        TCP Port: localhost:1113<br />
                    </li>
'''
CB_ITEM = item('CloudBeaver', [
    'URL: <a href="http://localhost:8978/" target="_blank">http://localhost:8978/</a> (cbadmin / Password123 ' + copy('Password123') + ')',
    '<span class="note">Log in to see the seeded connections: PostgreSQL, TimescaleDB, SQL Server, MySQL, MariaDB, ClickHouse.</span>',
])
CBASE_ITEM = item('Couchbase Server CE', [
    'Username: Administrator ' + copy('Administrator'),
    'Password: Password123 ' + copy('Password123'),
    'Connection String: couchbase://localhost ' + copy('couchbase://localhost') + ' (bucket <code>dev</code>)',
    'Web Console: <a href="http://localhost:8107/" target="_blank">http://localhost:8107/</a>',
    '<span class="note">From other containers: <code>couchbase://couchbase</code>. Services are remapped to 8107-8110.</span>',
])
COUCH_ITEM = item('CouchDB', [
    'Username: admin ' + copy('admin'),
    'Password: Password123 ' + copy('Password123'),
    'API: http://localhost:5984 ' + copy('http://localhost:5984'),
    'Fauxton: <a href="http://localhost:5984/_utils" target="_blank">http://localhost:5984/_utils</a>',
])
GARNET_ITEM = item('Garnet', [
    'Connection String: localhost:6380,password=Password123 ' + copy('localhost:6380,password=Password123'),
    '<span class="note">Redis protocol (StackExchange.Redis); from other containers <code>garnet:6379</code>.</span>',
])
KURRENT_ITEM = item('KurrentDB (formerly EventStoreDB)', [
    'Connection String: kurrentdb://localhost:2113?tls=false ' + copy('kurrentdb://localhost:2113?tls=false'),
    'Admin UI: <a href="http://localhost:2113/" target="_blank">http://localhost:2113/</a>',
    '<span class="note">gRPC only (no TCP 1113). From other containers <code>kurrentdb:2113</code> (or the old <code>eventstoredb</code> alias).</span>',
])
MEMCACHED_ITEM = item('Memcached', [
    'Server: localhost:11211 ' + copy('localhost:11211') + ' (no authentication, no persistence)',
])
QDRANT_ITEM = item('Qdrant', [
    'API Key: Password123 ' + copy('Password123'),
    'REST: http://localhost:6333 ' + copy('http://localhost:6333') + ', gRPC: localhost:6334',
    'Dashboard: <a href="http://localhost:6333/dashboard" target="_blank">http://localhost:6333/dashboard</a>',
])
RAVEN_ITEM = item('RavenDB', [
    'URL: http://localhost:8105 ' + copy('http://localhost:8105') + ' (unsecured, no login)',
    'Studio: <a href="http://localhost:8105/" target="_blank">http://localhost:8105/</a>',
    '<span class="note">From other containers <code>http://ravendb:8105</code> with <code>Conventions.DisableTopologyUpdates = true</code>.</span>',
])
SCYLLA_ITEM = item('ScyllaDB', [
    'CQL: localhost:9043 ' + copy('localhost:9043') + ' (no authentication)',
    'Alternator (DynamoDB API): http://localhost:8106 ' + copy('http://localhost:8106') + ' (any access key)',
])
TIMESCALE_ITEM = item('TimescaleDB', [
    'Connection String: Host=localhost;Port=5433;Database=tsdb;Username=user@user.com;Password=Password123; '
    + copy('Host=localhost;Port=5433;Database=tsdb;Username=user@user.com;Password=Password123;'),
])
VALKEY_ITEM = item('Valkey', [
    'Connection String: localhost:6381,password=Password123 ' + copy('localhost:6381,password=Password123'),
])
OLD_PROM_ITEM = '''                    <li>
                        <font style="font-size: 1.2rem; font-weight: bold">Prometheus</font><br />
                        Prometheus DB: <a href="http://localhost:9090/" target="_blank">http://localhost:9090/</a><br />
                        Node Exporter: <a href="http://localhost:9100/metrics"
                            target="_blank">http://localhost:9100/metrics</a><br />
                        Alert Manager: <a href="http://localhost:9093/" target="_blank">http://localhost:9093/</a><br />
                        <span class="note">Config in <code>prometheus.yml</code> / <code>alertmanager.yml</code>.
                            Reload: <code>curl -X POST http://localhost:9090/-/reload</code>. Scrapes the OTel collector
                            and accepts remote write from Tempo.</span><br />
                    </li>
'''
LOKI_ITEM_END = '''                        <span class="note">Retention 7 days. View in Grafana (Loki data source).</span><br />
                    </li>
'''
PG_NOTE = 'PostgreSQL</font><br />\n'
patch('Claude outputs/Home.html', [
    (ES_ROW, row('Databases', 'KurrentDB', link(2113) + ' gRPC + UI', '6.40')),
    (PROM_ROW, ''),
    (REDIS_ROW, NEW_ROWS),
    (LOKI_ROW, LOKI_ROW + PROM_OBS_ROW),
    # Databases page: insert alphabetically
    ('''                    <li>
                        <font style="font-size: 1.2rem; font-weight: bold">CockroachDB</font><br />''',
     CB_ITEM + '''                    <li>
                        <font style="font-size: 1.2rem; font-weight: bold">CockroachDB</font><br />'''),
    (OLD_ES_ITEM, CBASE_ITEM + COUCH_ITEM + GARNET_ITEM),
    ('''                    <li>
                        <font style="font-size: 1.2rem; font-weight: bold">MariaDb</font><br />''',
     KURRENT_ITEM + '''                    <li>
                        <font style="font-size: 1.2rem; font-weight: bold">MariaDb</font><br />'''),
    ('''                    <li>
                        <font style="font-size: 1.2rem; font-weight: bold">Milvus</font><br />''',
     MEMCACHED_ITEM + '''                    <li>
                        <font style="font-size: 1.2rem; font-weight: bold">Milvus</font><br />'''),
    (OLD_PROM_ITEM, QDRANT_ITEM + RAVEN_ITEM),
    ('''                        Application: <a href="https://github.com/qishibo/AnotherRedisDesktopManager"
                            target="_blank">Another Redis Desktop Manager</a><br />
                    </li>
''', '''                        Application: <a href="https://github.com/qishibo/AnotherRedisDesktopManager"
                            target="_blank">Another Redis Desktop Manager</a><br />
                    </li>
''' + SCYLLA_ITEM + TIMESCALE_ITEM + VALKEY_ITEM),
    ('                        pgAdmin: <a href="http://localhost:5050" target="_blank">http://localhost:5050</a>\n'
     '                        (user@user.com / Password123)<br />\n',
     '                        pgAdmin: <a href="http://localhost:5050" target="_blank">http://localhost:5050</a>\n'
     '                        (user@user.com / Password123)<br />\n'
     '                        <span class="note">Includes pgvector: <code>CREATE EXTENSION vector;</code> per database.</span><br />\n'),
    # Observability page: Prometheus after Loki
    (LOKI_ITEM_END, LOKI_ITEM_END + OLD_PROM_ITEM),
])
