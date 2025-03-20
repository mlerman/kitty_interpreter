rem limitations no filename with spaces
rem             no concurent execution of the interpreter, only one instance

rem @echo off
rem n'affiche rien dans la console web
call C:\UniServer\www\doc\files\ThisPC\nircmd\move_me_top_right.bat

rem set PYTHON_CMD=C:\Python27\python.exe
set PYTHON_CMD=python.exe


call C:\UniServer\www\doc\files\common\global_settings\PSEXEC_EXE.sh.bat
rem set PSEXEC_EXE=PsExec.exe
rem set PSEXEC_EXE=paexec.exe

:LOOP
tasklist | C:\Windows\System32\find.exe /i "kitty_portable.exe" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO CONTINUE
) ELSE (
  ECHO kitty is still running
  rem Timeout /T 5
  set CHOICE=W
  CHOICE /M "Press [K] to kill the SSH session or [W] to wait..." /T 5 /C KW /D W
  rem echo ERRORLEVEL is %ERRORLEVEL%
  IF ERRORLEVEL 1 SET CHOICE=K
  IF ERRORLEVEL 2 SET CHOICE=W
  if "%CHOICE%" == "W" GOTO LOOP
  if "%CHOICE%" == "K" GOTO KILL_SSH
  rem no choice
  goto LOOP
  echo CHOICE is %CHOICE%
)
:KILL_SSH
echo killing kitty_portable.exe
tasklist /FI "IMAGENAME eq kitty_portable.exe" 2>NUL | C:\Windows\System32\find.exe /I /N "kitty_portable.exe">NUL
if "%ERRORLEVEL%"=="0" taskkill /IM kitty_portable.exe /F
:CONTINUE

if not exist %1.escaped goto escaped_is_outdated
C:\UniServer\www\doc\files\ThisPC\install_wasfile\WasFile.exe %1.escaped before %1
if %errorlevel% EQU 1 goto escaped_is_uptodate
:escaped_is_outdated
rem the escaped is before the kitty = true
set YES_UPTODATE=no
goto end_wasfile
:escaped_is_uptodate
rem the escaped is after kitty = false
set YES_UPTODATE=yes
:end_wasfile

if "%YES_UPTODATE%" == "no" %PYTHON_CMD% C:\UniServer\www\doc\files\Engineering\ENVIRONMENT\PYTHON\curly_brace_to_goto\run.py --file "%1"
rem this generates .curlyout

%PYTHON_CMD% C:\UniServer\www\doc\files\Engineering\ENVIRONMENT\PYTHON\kitty_preprocessor\run.py --file "%1.curlyout" --old "%YES_UPTODATE%"
call YES_CONTAINS_LINUX_CMD.sh.bat
call YES_CONTAINS_PSEXEC_CMD.sh.bat

if "%YES_CONTAINS_PSEXEC_CMD%" == "no" goto no_psexec_cmd

rem testing psexec console
call C:\UniServer\www\doc\files\common\global_settings\PEXIP.sh.bat
call C:\UniServer\www\doc\files\common\global_settings\PEXPW.sh.bat
call C:\UniServer\www\doc\files\common\global_settings\PEXUS.sh.bat

call C:\UniServer\www\doc\files\common\global_settings\YES_PSEXEC_LONG_WAIT.sh.bat

if "%2" == "" goto use_global_pexip
rem force the ip from param %2
set PEXIP=%2
:use_global_pexip

if "%3" == "" goto use_global_pexpw
set PEXPW=%3
:use_global_pexpw

if "%4" == "" goto use_global_pexuser
set PEXUS=%4
:use_global_pexuser
rem echo 4: ==%4== SSDUS is %SSDUS%


rem TODO lancer en child process de autoit et attendre le message "Started with psexec" et sortir
start C:\UniServer\www\doc\files\ThisPC\install_pstools\%PSEXEC_EXE% \\%PEXIP% -u %PEXUS% -p %PEXPW% -s  cmd.exe /k "@echo Started with psexec"

rem sometimes if the firewall is enabled on the target we need to wait 30 sec

if "%PSEXEC_EXE%" == "PsExec.exe" goto psexec
if "%PSEXEC_EXE%" == "paexec.exe" goto paexec
goto end_ps
:psexec
if "%YES_PSEXEC_LONG_WAIT%" == "no" goto paexec
echo wait 30 sec until it starts then
C:\cygwin64\bin\sleep.exe 30
goto end_ps
:paexec
echo wait 2 sec until it starts then
C:\cygwin64\bin\sleep.exe 2
:end_ps

rem OK mais inutil
for /F "tokens=2" %%K in ('
   tasklist /FI "IMAGENAME eq %PSEXEC_EXE%" /FI "Status eq Running" /FO LIST ^| findstr /B "PID:"
') do (
   set PSEXEC_PID=%%K
)
echo %PSEXEC_EXE% is %PSEXEC_PID%


:no_psexec_cmd
if "%YES_CONTAINS_LINUX_CMD%" == "no" goto no_linux_cmd

rem to be removed
call C:\UniServer\www\doc\files\common\global_settings\SSDIP.sh.bat
call C:\UniServer\www\doc\files\common\global_settings\SSDPW.sh.bat
call C:\UniServer\www\doc\files\common\global_settings\SSDUS.sh.bat

call C:\UniServer\www\doc\files\common\global_settings\CONN.sh.bat

if "%2" == "" goto use_global_ssdip
rem force the ip from param %2
set CONN[1]=%2
:use_global_ssdip

if "%3" == "" goto use_global_ssdpw
set CONN[3]=%3
:use_global_ssdpw
rem echo 3: ==%3== CONN[3] is %CONN[3]%

if "%4" == "" goto use_global_ssduser
set CONN[2]=%4
:use_global_ssduser
rem echo 4: ==%4== SSDUS is %SSDUS%

rem check if the remote is living
ping -n 1 %CONN[1]% > out.txt
C:\Windows\System32\find.exe /c "Lost = 1" out.txt >nul
if %errorlevel% equ 1 goto found_remote
echo IP %CONN[1]% is OFF, exiting
exit /b
goto done_remote_is_live
:found_remote
:done_remote_is_live

if exist putty.log del putty.log /Q
call C:\UniServer\www\doc\files\common\global_settings\SYNC.sh.bat
if "%SYNC%" == "no" goto no_sync_1
call C:\UniServer\www\doc\files\Engineering\ENVIRONMENT\WINDOWS_BATCH\kitty_interpreter\create_sync_file.bat
call UUID.sh.bat
C:\UniServer\www\doc\files\ThisPC\putty\PSCP.EXE -scp -pw %CONN[3]% SYNC_%UUID%.sh.bat %CONN[2]%@%CONN[1]%: >nul
:no_sync_1

rem stty -echo\n
rem clear\n
call C:\UniServer\www\doc\files\common\global_settings\KITTY_STTY_ECHO.sh.bat

set STTY_ECHO_PARAM=
if "%KITTY_STTY_ECHO%" NEQ "no" goto normal_stty
set STTY_ECHO_PARAM=stty -echo\nPS1=\\\\\x6e${PS1}\n
:normal_stty


if "%YES_CONTAINS_LINUX_CMD%" == "no" goto no_linux_cmd

rem ne lance kitty_portable.exe que si on peut se connecter
if exist curlout_ssh_abl.txt del curlout_ssh_abl.txt /Q
echo ^] | curl telnet://%CONN[1]%:%CONN[4]% --max-time 2 -s >curlout_ssh_abl.txt  2>&1
rem echo curlout_ssh_abl.txt and size:
rem type curlout_ssh_abl.txt

echo set FSIZE=^^>FSIZE.sh.bat
FOR %%I in (curlout_ssh_abl.txt) do @ECHO %%~zI >>FSIZE.sh.bat
call FSIZE.sh.bat
rem echo FSIZE [%FSIZE%]
if "%FSIZE%" NEQ "0 " goto ok_to_ssh_or_telnet

rem previous code encore ok pour ssh
set FIND_THIS="SSH"
C:\WINDOWS\system32\find.exe /c %FIND_THIS% curlout_ssh_abl.txt >nul
if %errorlevel% equ 0 goto ok_to_ssh_or_telnet
goto not_ok_to_ssh
goto end_run_ssh
:ok_to_ssh_or_telnet
if "%CONN[0]%" == "telnet" goto ok_to_telnet
call C:\UniServer\www\doc\files\common\global_settings\CLEAR_CMD.sh.bat
rem                                                                  was -ssh
start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -%CONN[0]% %CONN[2]%@%CONN[1]% -pw %CONN[3]% -cmd "%STTY_ECHO_PARAM%%CLEAR_CMD%\n" -xpos 50 -ypos 0
goto end_ssh_or_telnet
:ok_to_telnet
rem work in progress
rem start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -%CONN[0]% %CONN[2]%@%CONN[1]% -pass %CONN[3]% -cmd "%STTY_ECHO_PARAM%%CLEAR_CMD%\n" -xpos 50 -ypos 0
rem start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -%CONN[0]% %CONN[2]%:%CONN[3]%@%CONN[1]% -cmd "%STTY_ECHO_PARAM%%CLEAR_CMD%\n" -xpos 50 -ypos 0
start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -%CONN[0]% %CONN[1]% -P %CONN[4]% -xpos 50 -ypos 0
sleep 4
start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "\n\n"
sleep 4
start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "%CONN[2]%\n"
sleep 1
start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "%CONN[3]%\n"
sleep 1
start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "%STTY_ECHO_PARAM%%CLEAR_CMD%\n"


:end_ssh_or_telnet

sleep 3
goto end_run_ssh
:not_ok_to_ssh
echo Error not_ok_to_ssh: Cannot connect to target 
echo protocol [%CONN[0]%]
echo IP       [%CONN[1]%]
echo User     [%CONN[2]%]
echo Pw       [%CONN[3]%]
echo Port     [%CONN[4]%]
echo prefix   [%CONN[5]%]
pause

goto end_run_ssh
:end_run_ssh

:no_linux_cmd
rem les ':' dans :kitty_execute_line.bat font la difference entre la subroutine et le fichier extern
%PYTHON_CMD% C:\UniServer\www\doc\files\Engineering\ENVIRONMENT\PYTHON\explode_bat_lib\run.py --file "%1"

echo. >flow.txt

echo echo set GOTO_LINE=%%1 ^>GOTO_LINE.sh.bat>kittygotoline.bat

rem we calculate the total number of lines in the file to execute
for /f  %%a in (%1.escaped) do (set /a total_lines+=1)

echo set THE_END=no>THE_END.sh.bat
set /a COUNT=0
:line_loop
set /a lineNr=%COUNT% -1
set /a COUNT+=1
rem echo set COUNT=%COUNT% >COUNT.sh.bat

rem make sure lineNR line number is pointing to a real line in the file
if %lineNr% LSS 1 goto line_loop

rem for every count index, we point to a line in the file
rem LineNr c'est la position dans le fichier ou on commence a envoyer a for_bat
for /f "usebackq delims=" %%a in (`more +%lineNr% %1.escaped`) DO call C:\UniServer\www\doc\files\Engineering\ENVIRONMENT\WINDOWS_BATCH\kitty_interpreter\for_bat.bat %%a


:leave_for
if not exist GOTO_LINE.sh.bat goto done_file
goto line_loop
:done_file

if "%YES_CONTAINS_LINUX_CMD%" == "no" goto no_linux_cmd_2

call C:\UniServer\www\doc\files\common\global_settings\LAST_EXIT_CMD.sh.bat

if "%SYNC%" == "no" goto no_sync
c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "rm SYNC_%UUID%.sh.bat\n%LAST_EXIT_CMD%\n"
if exist SYNC_%UUID%.sh.bat del SYNC_%UUID%.sh.bat /Q
:no_sync

:no_linux_cmd_2

exit /b