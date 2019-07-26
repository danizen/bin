@set SSHENV_CMD=%USERPROFILE%\.ssh\sshenv.cmd
@set SSHENV_SH=%USERPROFILE%\.ssh\sshenv.sh
@taskkill /f /fi "imagename eq ssh-agent.exe"
@DEL /q /f %SSHENV_CMD% 2>/nul
@DEL /q /f %SSHENV_SH% 2>/nul
