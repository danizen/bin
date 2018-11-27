@set SSHENV_CMD=%USERPROFILE%\.ssh\sshenv.cmd
@tasklist /fi "imagename eq ssh-agent.exe" | find "INFO:" >/nul
@if errorlevel 1 goto sourcescript
@ssh-agent | sed -r -e 's/; export .*$//' -e 's/^([A-Z_]+)=/@set \1=/' -e 's/^echo(.*);/@echo\1/'> %SSHENV_CMD%
:sourcescript
@%SSHENV_CMD%


