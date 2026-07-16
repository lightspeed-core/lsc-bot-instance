#!/bin/bash
set -e

cd "$(dirname "$0")"

git submodule update --init --recursive

echo "Building lsc-bot-instance..."
docker build -f dev-bot/Dockerfile.runner -t lsc-bot-instance:local .

echo "Done. Image: lsc-bot-instance:local"
