#!/bin/bash

if [ -f /vault/.vault-token ]; then 
    export VAULT_TOKEN=$(cat /vault/.vault-token)

fi

if [ -f /vault/secrets/config ]; then
   . /vault/secrets/config
fi

function start_envconsul() {
    set -u 
    envconsul \
        -vault-addr=${VAULT_ADDR} \
        -secret=${VAULT_PATH} \
        -no-prefix=true \
        -vault-renew-token=true \
        -once \
        -exec='bash start.sh'
}


if [ -n "${VAULT_TOKEN}" ]; then
    echo "have token. starting envconsul"
    start_envconsul
else
    echo "starting the app"
    bash start.sh
fi
