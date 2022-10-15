#! /usr/bin/env sh
set -e

SERVICE_VERSION=$(git rev-parse HEAD)
kind load docker-image hello-kind:v$SERVICE_VERSION