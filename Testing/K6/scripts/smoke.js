// Sample k6 test: a short ramp against the WireMock stack's sample stub (start Testing/WireMock first),
// or point TARGET_URL at your own service, e.g. -e TARGET_URL=http://host.docker.internal:5000/health
import http from 'k6/http';
import { check, sleep } from 'k6';

const target = __ENV.TARGET_URL || 'http://wiremock:8080/api/hello?name=k6';

export const options = {
  stages: [
    { duration: '10s', target: 5 },
    { duration: '20s', target: 5 },
    { duration: '5s', target: 0 },
  ],
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500'],
  },
};

export default function () {
  const res = http.get(target);
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
