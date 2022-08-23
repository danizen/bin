@echo off

SET NARGS=0
FOR %%x in (%*) DO SET /a NARGS += 1

IF EXIST "target\dependency" GOTO RUNSHELL
CALL mvn dependency:copy-dependencies

:RUNSHELL
IF %NARGS% NEQ 0 (
	jshell --class-path target\classes;target\test-classes;target\dependency\* %*
	GOTO END
)

IF EXIST "setup.jsh" (
	jshell --class-path target\classes;target\test-classes;target\dependency\* -start setup.jsh
	GOTO END
)

jshell --class-path target\classes;target\test-classes;target\dependency\*
:END
