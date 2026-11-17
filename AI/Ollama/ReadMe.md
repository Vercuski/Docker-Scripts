# Ollama
Runs open-weight LLMs (Llama, Qwen, Mistral, Gemma, Phi, ...) and embedding models locally behind an HTTP API, with
an OpenAI-compatible endpoint, so code written against OpenAI works by changing the base URL.<br>
API: http://localhost:11434 (native `/api/*`, OpenAI-compatible `/v1/*`) - from other stacks `http://ollama:11434`<br>

`ollama-init` pulls the models in `OLLAMA_MODELS` (default `llama3.2:3b` for chat, `nomic-embed-text` for
embeddings) into the `models` volume. The first pull downloads gigabytes; later runs only check for updates.
More models: `docker exec ollama ollama pull qwen3:8b` (catalogue: https://ollama.com/library).

**CPU vs GPU.** By default it runs on the CPU: fine for 1-4 B parameter models, slow for larger ones. With an NVIDIA
GPU (Docker Desktop + WSL2 on Windows, or the NVIDIA Container Toolkit on Linux) add the GPU file:
```sh
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
docker exec ollama nvidia-smi
```

```csharp
// NuGet: Microsoft.Extensions.AI.OpenAI - any OpenAI client works against /v1
IChatClient chat = new OpenAI.Chat.ChatClient("llama3.2:3b", new ApiKeyCredential("ollama"),
        new OpenAIClientOptions { Endpoint = new Uri("http://localhost:11434/v1") }).AsIChatClient();
var reply = await chat.GetResponseAsync("Summarise Dapr in one sentence.");
```
Semantic Kernel has an Ollama connector too (`Microsoft.SemanticKernel.Connectors.Ollama`).
```sh
curl http://localhost:11434/api/tags                         # installed models
curl http://localhost:11434/v1/chat/completions -H "Content-Type: application/json" \
  -d '{"model":"llama3.2:3b","messages":[{"role":"user","content":"Hello"}]}'
curl http://localhost:11434/api/embed -d '{"model":"nomic-embed-text","input":"hello"}'
```
Pair it with **Open WebUI** (chat UI), **LiteLLM** (one OpenAI-style gateway with keys and budgets in front of Ollama
and cloud models) and **Langfuse** (tracing) in this category, and Databases/Qdrant or pgvector for RAG.

https://docs.ollama.com/
