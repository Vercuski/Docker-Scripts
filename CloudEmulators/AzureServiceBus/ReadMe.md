# Azure Service Bus emulator
Requires the MSSQL stack (`Databases/MSSQL`) - the emulator creates its own databases there using the `sa` login.

Entities are declared in `Config.json` (namespace must stay `sbemulatorns`). Edit it, then `docker compose restart`.

Connection string from the host (note the AMQP port):<br>
`Endpoint=sb://localhost:5673;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;`

From a container on GroupNetwork:<br>
`Endpoint=sb://servicebus-emulator;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;`

Health: http://localhost:5300/health
