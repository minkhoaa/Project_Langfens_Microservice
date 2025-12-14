#!/usr/bin/env sh
set -eu

ES_URL="${ES_URL:-http://elasticsearch:9200}"
INDEX="${INDEX:-dictionary_v1}"
ALIAS="${ALIAS:-dictionary_current}"

echo "Waiting for Elasticsearch at $ES_URL ..."
until curl -sS "$ES_URL" >/dev/null 2>&1; do
  sleep 1
done

# đợi cluster xanh/vàng
until [ "$(curl -sS "$ES_URL/_cluster/health?pretty=false" | grep -o '"status":"[^"]*"' | cut -d: -f2 | tr -d '"')" != "" ]; do
  sleep 1
done

echo "Elasticsearch is reachable."

# 1) Create index if not exists
if curl -sS -o /dev/null -w "%{http_code}" -I "$ES_URL/$INDEX" | grep -q "^200$"; then
  echo "Index $INDEX already exists. Skip create."
else
  echo "Creating index $INDEX ..."
  curl -sS -X PUT "$ES_URL/$INDEX" \
    -H "Content-Type: application/json" \
    --data-binary "@/init/index.dictionary_v1.json" >/dev/null
  echo "Index created."
fi

# 2) Create alias if not exists
if curl -sS -o /dev/null -w "%{http_code}" "$ES_URL/_alias/$ALIAS" | grep -q "^200$"; then
  echo "Alias $ALIAS already exists. Skip alias."
else
  echo "Creating alias $ALIAS -> $INDEX ..."
  curl -sS -X POST "$ES_URL/_aliases" \
    -H "Content-Type: application/json" \
    -d "{\"actions\":[{\"add\":{\"index\":\"$INDEX\",\"alias\":\"$ALIAS\"}}]}" >/dev/null
  echo "Alias created."
fi

echo "ES init done."
