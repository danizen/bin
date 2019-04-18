@ECHO OFF
rem # gpgeval uses gpg decrypt to decrypt a file, convert its exports into set statements which are then run.
rem # This is useful for keeping secrets such as AWS_SECRET_ACCESS_KEY and AWS_ACCESS_KEY_ID in repositories and the like.

SET arg_count=0
FOR %%x in (%*) DO SET /a arg_count += 1

IF %arg_count% == 1 GOTO HAVEARGS
ECHO Usage: gpgeval {filename}
EXIT /B 1

:HAVEARGS
SET FILENAME=%1
IF EXIST %FILENAME% GOTO FILEEXISTS
ECHO File %FILENAME% does not exist
EXIT /B 1

:FILEEXISTS
SET TEMPFILE=%TEMP%\gpgeval-temp.cmd
CALL gpg -d %FILENAME% > %TEMPFILE%

sed -i -r -e "s/^export /set /" -e "s/\"//g" %TEMPFILE%
CALL %TEMPFILE%

:END
DEL /F %TEMPFILE%
set TEMPFILE=
