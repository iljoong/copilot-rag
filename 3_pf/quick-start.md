# Quick Start

## Setup

create a new pf project and create connections

```bash
pf flow init --flow ./azchatbot --type chat

pf connection create --file ./azchatbot/azure_openai.yaml --set api_key={aoai_api_key} api_base=https://{your_aoai}.openai.azure.com/ --name azure_open_ai_connection
```

link connection and run flow

```
pf flow test --flow ./azchatbot --interactive
```

## Update flow

0. Modify input/out
    - input: chat_history, chat_input
    - outout: chat_output

1. Add `LLM` flow, 'modify_query_with_history'

2. Add `Embedding` flow, 'embed_the_question'

3. Add `Vector DB Lookup` flow, 'azure_search_lookup'
    - add connection using UI tool.

4. Add `Python` flow, 'generate_prompt_context'

5. Add `Prompt` flow, 'prompt_variants'

6. Modify original chat flow.

## Test

Console UI
```
pf flow test --flow ./azchatbot --interactive
```

Web UI
```
pf flow serve --source ./azchatbot --port 8080 --host localhost
```

## Deploy

> https://microsoft.github.io/promptflow/cloud/azureai/deploy-to-azure-appservice.html

Generate source for `docker` build

```
pf flow build --source ./azchatbot --output dist --format docker
```

Create connections
    - create an yaml file for each connection. name of yaml file should be same as connection name.
        - see `dist/runit/prompt-serve/run` script how `pf` create a connection.
    - update secret string with environment variable.     

Docker build

```
docker build -t azchatbot:latest ./dist
```

Docekr run

```
docker run --rm --name azchatbot -p 5000:8080 -e "AZURE_OPENAI_KEY={aoai_api_key}" \
   -e "AZURE_OPENAI_ENDPOINT=https://{your_aoai}.openai.azure.com/" \
   -e "AZURE_COGNITIVE_SEARCH_KEY={acsh_api_key}" \
   -e "AZURE_COGNITIVE_SEARCH_ENDPOINT=https://{azsch}.search.windows.net" \
   -d azchatbot:latest
```
> Note: Web UI is not working, only `/score` endpoint is working.

Test

```
curl -i -X POST -H "Content-Type: application/json" --data '{"chat_input": "what is app service", "chat_history": []}' localhost:5000/score
```

## Debug

```
# see any error output
docker logs azchatbot

# check container
docker exec -it azchatbot bash
```

## Additional work

Managing token limit:
    - make answer shorter and let reference link to read more.
    - keep conversation history minimum (2~3 turns) and limit to max 50% of max token.
    - use `gpt-35-turbo-16k` model.