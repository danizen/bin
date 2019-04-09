@set SSHENV_SH=%USERPROFILE%\.ssh\sshenv.sh
@set SSHENV_CMD=%USERPROFILE%\.ssh\sshenv.cmd
@tasklist /fi "imagename eq ssh-agent.exe" /fi "sessionname eq console" | find "INFO:" >/nul
@if errorlevel 1 goto sourcescript
@ssh-agent > %SSHENV_SH%
@sed -r -e 's/; export .*$//' -e 's/^([A-Z_]+)=/@set \1=/' -e 's/^echo(.*);/@echo\1/' %SSHENV_SH% > %SSHENV_CMD%
:sourcescript
@%SSHENV_CMD%
