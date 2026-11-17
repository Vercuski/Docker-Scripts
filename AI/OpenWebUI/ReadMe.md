# Open WebUI
Self-hosted ChatGPT-style interface for local models: chats with history, model switching, document uploads and
RAG, prompt library, image input for vision models, multiple users with roles. Talks to the **Ollama** stack.<br>
UI: http://localhost:3013 (`admin@example.com` / `Password123`)<br>

Requires the **Ollama** stack (`http://ollama:11434`); the models pulled there appear in the model picker.
On the first start the admin account is created from `.env` and public sign-up is switched off; add users in
*Admin Panel > Users*. Settings changed in the UI are stored in the `data` volume and win over environment variables
afterwards (Open WebUI's persistent config).

- Document uploads / RAG embed with Ollama's `nomic-embed-text` (pull it in the Ollama stack), so nothing is
  downloaded from Hugging Face.
- Cloud models or the **LiteLLM** gateway: *Admin Panel > Settings > Connections > OpenAI*, URL
  `http://litellm:4000/v1` with a LiteLLM key.

API (OpenAI-compatible, key from *Settings > Account > API keys*):
```sh
curl http://localhost:3013/api/chat/completions -H "Authorization: Bearer <key>" -H "Content-Type: application/json" \
  -d '{"model":"llama3.2:3b","messages":[{"role":"user","content":"Hello"}]}'
```

https://docs.openwebui.com/
