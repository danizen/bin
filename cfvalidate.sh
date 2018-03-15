#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 template-path" >&2
  echo "Description: front-end to aws cloudformation validate-template that removes the undifferentiated heavy typing" >&2
  exit 1
fi

TEMPLATE=$1

if [[ ! -f "$TEMPLATE" ]]; then
  echo: "error: $TEMPLATE: not found" >&2
  exit 1
fi

aws cloudformation validate-template --template-body=file://"$TEMPLATE"

if [[ $? -ne 0 ]]; then
  echo "error: validation failed" >&2
  exit 1
fi

