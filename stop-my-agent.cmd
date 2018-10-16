@set SSHENV_CMD=%USERPROFILE%\.ssh\sshenv.cmd
@if defined SSH_AUTH_SOCK ssh-agent -k >/nul
@DEL /q /f %SSHENV_CMD% 2>/nul
