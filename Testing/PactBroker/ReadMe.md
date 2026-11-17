# Pact Broker
Hub for consumer-driven contract testing: consumers publish pacts (e.g. from PactNet tests), providers fetch and
verify them and publish the results, and `can-i-deploy` tells CI whether a version is safe to release.<br>
UI + HAL API: http://localhost:9292 (`pact` / `Password123`; read-only `pact-reader` / `Password123`)<br>
From other stacks (CI runners): `http://pact-broker:9292`<br>

Requires the **PostgreSQL** stack (`pact-broker-db-init` creates the `pact_broker` role and database).
`/diagnostic/status/heartbeat` is public (used by the healthcheck); everything else needs basic auth.

PactNet (provider verification):
```csharp
verifier.WithHttpEndpoint(new Uri("http://localhost:5000"))
        .WithPactBrokerSource(new Uri("http://localhost:9292"), o => o
            .BasicAuthentication("pact", "Password123")
            .PublishResults(version))
        .Verify();
```
Publish a pact and ask can-i-deploy with the Pact CLI image:
```sh
docker run --rm --network GroupNetwork -v ${PWD}/pacts:/pacts pactfoundation/pact-cli \
  pact-broker publish /pacts --consumer-app-version 1.0.0 --broker-base-url http://pact-broker:9292 -u pact -p Password123
docker run --rm --network GroupNetwork pactfoundation/pact-cli \
  pact-broker can-i-deploy --pacticipant WebShop --version 1.0.0 --to-environment production \
  --broker-base-url http://pact-broker:9292 -u pact -p Password123
```

https://docs.pact.io/pact_broker
