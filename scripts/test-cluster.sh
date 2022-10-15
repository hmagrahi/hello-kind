#! /usr/bin/env sh
set -e

kubectl rollout status deployment/hello-kind --timeout=3m
helm test hello-kind