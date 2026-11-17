# LiteLLM
LLM gateway: one OpenAI-compatible API in front of local models (Ollama) and cloud providers (OpenAI, Azure OpenAI,
Anthropic, Bedrock, Gemini, ...), with virtual keys, per-key model access, budgets, rate limits, fallbacks, caching
and spend tracking.<br>
API: http://localhost:4000/v1 (from other stacks `http://litellm:4000/v1`) - Admin UI: http://localhost:4000/ui (`admin` / `Password123`)<br>
Master key: `sk-local-dev-litellm-master-key`<br>

Requires the **PostgreSQL** stack (`litellm-db-init` creates the `litellm` role and database: keys, spend logs,
models added in the UI). Local models come from the **Ollama** stack; every request is traced to the **Langfuse**
stack (`callbacks: ["langfuse_otel"]` - Langfuse v4 accepts only OpenTelemetry; with Langfuse stopped LiteLLM just
logs a warning).

Models are defined in `config.yaml`: `llama3.2` (Ollama `llama3.2:3b`) and `nomic-embed-text` (embeddings), plus
commented OpenAI / Azure OpenAI examples whose keys go in `.env` (`LITELLM_OPENAI_API_KEY`, `LITELLM_AZURE_*`).
Restart `litellm` after editing it. Models added in the UI are stored in the database instead.

Give each app its own key instead of the master key:
```sh
curl http://localhost:4000/key/generate -H "Authorization: Bearer sk-local-dev-litellm-master-key" \
  -H "Content-Type: application/json" -d '{"models":["llama3.2"],"max_budget":5,"key_alias":"my-api"}'
```
```csharp
// NuGet: Microsoft.Extensions.AI.OpenAI - same code for local and cloud models, only the model name changes
IChatClient chat = new OpenAI.Chat.ChatClient("llama3.2", new ApiKeyCredential("<virtual key>"),
        new OpenAIClientOptions { Endpoint = new Uri("http://localhost:4000/v1") }).AsIChatClient();
```
At start LiteLLM tries to download the latest model price list from GitHub; offline it falls back to the bundled copy.

https://docs.litellm.ai/docs/proxy/docker_quick_start
