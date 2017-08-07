#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 stack-name" >&2
  exit 1
fi
STACK_NAME=$1

aws cloudformation delete-stack --stack-name "$STACK_NAME"
