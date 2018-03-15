#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <authmessage>" 1>&2
    echo "Description: Front-end to aws sts decode-authorization-message that removes the undifferentiated heavy typing" >&2
    exit 1
fi
MESSAGE=$1

aws sts decode-authorization-message \
   --output text \
   --encoded-message $MESSAGE | python -mjson.tool
