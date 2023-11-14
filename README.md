# Copilot RAG

This sample demonstrate developing RAG pattern using Azure OpenAI's [Extension API](https://learn.microsoft.com/en-us/azure/ai-services/openai/reference#completions-extensions)(a.k.a Your Own Data) and [prompt flow](https://microsoft.github.io/promptflow/index.html).

## 1. Prep

Download sample data from github, then upload sample data to azure blob stroage

See list of [sample documents](./1_prep/download.txt). 

Use `azcopy` tool to upload to blob storage.

```
azcopy login
azcopy cp app-service/ https://ikapplog.blob.core.windows.net/data --recursive
```

## 2. Extension API (notebook)

- [Ingest Sample](./2_notebook/1_boyd-azure-search-ingest.ipynb)
- [Query Sample](./2_notebook/1_boyd-azure-search-query.ipynb)


## 3. Prompt Flow

See [Quick Start](./3_pf/quick-start.md)
