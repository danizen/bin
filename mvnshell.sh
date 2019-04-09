#!/bin/bash

if [[ -d target && ! -d target/lib ]]; then
    mvn dependency:copy-dependencies
fi

if [[ $# -eq 0 && -f "setup.jsh" ]]; then
    jshell --class-path target/classes:target/test-classes:target/lib/* -start setup.jsh
else
    jshell --class-path target/classes:target/test-classes:target/lib/* $*
fi
