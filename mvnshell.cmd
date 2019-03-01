@echo off
call mvn dependency:build-classpath ^
	-DincludeTypes=jar ^
	-Dmdep.outputFile=target\classpath.txt
set /p _CP=<target\classpath.txt
set _CP=%_CP%;target\classes
jshell --class-path %_CP%
