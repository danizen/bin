#!/bin/bash

ACTION=create-stack
WAIT_ACTION=stack-create-complete
VARS_FILE=""

while getopts "r:uv:" opt; do
  case $opt in
    u) ACTION=update-stack ; WAIT_ACTION=stack-update-complete ;;
    v) VARS_FILE="--parameters $OPTARG" ;;
    h) echo "Usage: $0 [-u] [-v <varsfile>] <TemplateFile> <StackName>" >&2; exit 1;
    \?) echo "error: -$OPTARG: invalid option" >&2; exit 1 ;;
    :) echo "error: -$OPTARG: missing argument" >&2; exit 1 ;;
  esac
done

shift $(($OPTIND - 1))

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 [Options] template-path stack-name" >&2
  echo "Options:" >&2
  echo "  -u" >&2
  echo "  -r role_name" >&2
  exit 1
fi

TEMPLATE=$1
STACK_NAME=$2

if [[ ! -f "$TEMPLATE" ]]; then
  echo: "error: $TEMPLATE: not found" >&2
  exit 1
fi

aws cloudformation validate-template --template-body=file://"$TEMPLATE"

if [[ $? -ne 0 ]]; then
  echo "error: validation failed" >&2
  exit 1
fi

aws cloudformation $ACTION --stack-name "$STACK_NAME" \
    $VARS_FILE \
    --template-body=file://"$TEMPLATE"

aws cloudformation wait $WAIT_ACTION --stack-name "$STACK_NAME"

