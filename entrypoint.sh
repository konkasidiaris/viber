#! /usr/bin/env bash

_term() {
    echo "Caught SIGTERM/SIGINT – shutting down Viber..."
    kill -TERM "$child" 2>/devdev/null
    wait "$child"
}

trap _term SIGTERM SIGINT

/opt/viber/Viber "$@" &
child=$!
wait "$child"

