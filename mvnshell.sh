#!/bin/bash

if [[ -d target && ! -d target/dependency ]];then
    mvn dependency:copy-dependencies
fi

if [[ $# -eq 0 && -f "setup.jsh" ]]; then
    jshell --class-path target/dependency/*:target/test-classes:target/classes -start setup.jsh
else
    jshell --class-path target/dependency/*:target/test-classes:target/classes $*
fi
