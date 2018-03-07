#!/bin/bash

ACTION=create-stack
WAIT_ACTION=stack-create-complete
VARS_FILE=""
CAPABILITIES=""

while getopts "cup:" opt; do
  case $opt in
    u) ACTION=update-stack ; WAIT_ACTION=stack-update-complete ;;
    p) VARS_FILE="--parameters file://$OPTARG" ;;
    c) CAPABILITIES="--capabilities CAPABILITY_NAMED_IAM" ;;
    \?) echo "error: -$OPTARG: invalid option" >&2; exit 1 ;;
    :) echo "error: -$OPTARG: missing argument" >&2; exit 1 ;;
  esac
done

shift $(($OPTIND - 1))

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 [Options] template-path stack-name" >&2
  echo "Description: Front-end to aws cloudformation create-stack that removes the undifferentiated heavy typing" >&2
  echo "Options:" >&2
  echo "  -u ........................ make this an update stack" >&2
  echo "  -p <params-json-path> ..... include these json parameters" >&2
  echo "  -c ........................ add CAPABILITY_NAMED_IAM" >&2
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
    $CAPABILITIES \
    --template-body=file://"$TEMPLATE"

aws cloudformation wait $WAIT_ACTION --stack-name "$STACK_NAME"

