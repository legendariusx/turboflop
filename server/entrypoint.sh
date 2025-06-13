#!/usr/bin/env bash
spacetime start &
SERVER_PID=$!

# FIXME: should probably not use sleep
sleep 1
./publish.sh

wait $SERVER_PID