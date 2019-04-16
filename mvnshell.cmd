@echo off
if exist "target\lib" goto runshell
call mvn dependency:copy-dependencies
:runshell
jshell --class-path target\classes;target\test-classes;target\lib\* %*
