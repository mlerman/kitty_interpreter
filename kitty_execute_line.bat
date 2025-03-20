REM MIT License

REM Copyright (c) 2025 Mikhael Lerman checkthisresume.com

REM Permission is hereby granted, free of charge, to any person obtaining a copy
REM of this software and associated documentation files (the "Software"), to deal
REM in the Software without restriction, including without limitation the rights
REM to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
REM copies of the Software, and to permit persons to whom the Software is
REM furnished to do so, subject to the following conditions:

REM The above copyright notice and this permission notice shall be included in all
REM copies or substantial portions of the Software.

REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
REM IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
REM FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
REM AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
REM LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
REM SOFTWARE.

call call C:\UniServer\www\doc\files\common\global_settings\KITTY_DEBUG.sh.bat
if exist GOTO_LINE.sh.bat del GOTO_LINE.sh.bat/Q

rem %1 contient toute la command sous la form de "%*\n"  
rem %* represente plusieurs mots avec les characters ",&,(,) sont remplace par \x22 \x26, \x28, \x29 
set PARAMETERS_W=%1
set PARAMETERS_L=%1

rem je pense que c'est inutil car deja escape dans c:\UniServer\www\doc\files\Engineering\ENVIRONMENT\PYTHON\kitty_preprocessor\run.py
set PARAMETERS_W=%PARAMETERS_W:>=\x3e%
set "PARAMETERS_W=%PARAMETERS_W:|=\x7c%"

rem this removes all the \n but we need to remove only the last one
rem set "PARAMETERS_W=%PARAMETERS_W:\n=%"
set "PARAMETERS_W=%PARAMETERS_W:~0,-3%"

rem ceci enleve les double quotes des extremites, a l'interieur ils sont escappes
set STR_PARAMETERS_W_NO_DBLQUOTE=%PARAMETERS_W:"=%

rem need to remove leading whitespaces, this will allow free style
rem no "delims=" option given, so defaulting to spaces and tabs:
for /F "tokens=* eol= " %%S in ("%STR_PARAMETERS_W_NO_DBLQUOTE%") do set "PARAMETERS_W_NO_DBLQUOTE=%%S"

rem            a b c d
for /F "tokens=1,2,3,* delims= " %%a in ('echo %PARAMETERS_W_NO_DBLQUOTE%') do (
   set FIRST_WORD=%%a
   set SECOND_WORD=%%b
   set THIRD_WORD=%%c
   set REST_WORDS=%%d
)

set FIRST_WORD_L=%FIRST_WORD%

rem remove double quote
if "%FIRST_WORD%" == "" goto suite_1
set STR_FIRST_WORD=%FIRST_WORD:"=%

rem need to remove leading whitespaces, this will allow free style
rem no "delims=" option given, so defaulting to spaces and tabs:
for /F "tokens=* eol= " %%S in ("%STR_FIRST_WORD%") do set "FIRST_WORD=%%S"

:suite_1
if "%SECOND_WORD%" == "" goto suite_2
set SECOND_WORD=%SECOND_WORD:"=%
:suite_2
if "%THIRD_WORD%" == "" goto suite_3
set THIRD_WORD=%THIRD_WORD:"=%
:suite_3

rem was set OTHER_THAN_FIRST_WORD=%SECOND_WORD% %THIRD_WORD% %REST_WORDS%

set OTHER_THAN_FIRST_WORD=
if "%SECOND_WORD%" == "" goto other_1
set OTHER_THAN_FIRST_WORD=%SECOND_WORD%
:other_1

if "%THIRD_WORD%" == "" goto other_2
set OTHER_THAN_FIRST_WORD=%OTHER_THAN_FIRST_WORD% %THIRD_WORD%
:other_2

if "%REST_WORDS%" == "" goto other_3
set OTHER_THAN_FIRST_WORD=%OTHER_THAN_FIRST_WORD% %REST_WORDS%
:other_3

rem check if first word start with x_ or w_
if "%FIRST_WORD:~0,2%"=="x_" goto first_word_x
if "%FIRST_WORD:~0,2%"=="t_" goto first_word_x
if "%FIRST_WORD:~0,2%"=="w_" goto first_word_w
if "%FIRST_WORD:~0,2%"=="p_" goto first_word_p
if "%FIRST_WORD:~0,1%"==":" goto end
goto selector_first_word

:first_word_x
rem add \n that was removed above in line 14
set PARAMETERS_L="%PARAMETERS_W_NO_DBLQUOTE:~2%\n"
goto linux_cmd

:first_word_w
rem escape the \ with \\
rem cut after w_ so from index 2
set PARAMETERS_W_NO_DBLQUOTE=%PARAMETERS_W_NO_DBLQUOTE:~2%
goto wincall

:first_word_p
rem cut after p_ so from index 2
set PARAMETERS_W_NO_DBLQUOTE=%PARAMETERS_W_NO_DBLQUOTE:~2%
goto psexec_cmd
rem if nothing else 
goto end

:selector_first_word
if "%FIRST_WORD%" == "kittyhelp" goto kittyhelp
if "%FIRST_WORD%" == "kittyget" goto kittyget
if "%FIRST_WORD%" == "kittyput" goto kittyput
if "%FIRST_WORD%" == "kittypause" goto kittypause
if "%FIRST_WORD%" == "kittysync" goto kittysync
if "%FIRST_WORD%" == "kittyshow" goto kittyshow
if "%FIRST_WORD%" == "kittyhide" goto kittyhide
if "%FIRST_WORD%" == "kittyxset" goto kittyxset
if "%FIRST_WORD%" == "kittywset" goto kittywset
if "%FIRST_WORD%" == "kittypset" goto kittypset
if "%FIRST_WORD%" == "kittypreboot" goto kittypreboot
if "%FIRST_WORD%" == "kittyxreboot" goto kittyxreboot
if "%FIRST_WORD%" == "kittyxpowercycle" goto kittyxpowercycle
if "%FIRST_WORD%" == "call" goto wincall
if "%FIRST_WORD%" == "rem" goto wincall
if "%FIRST_WORD%" == "@echo" goto wincall
if "%FIRST_WORD%" == "echo" goto bothcall
if "%FIRST_WORD%" == "sleep" goto bothcall
if "%FIRST_WORD%" == "kittyinclude" goto end
if "%FIRST_WORD%" == "kittygotoline" goto kittygotoline

rem by default it is a linux command, if not specified
goto linux_cmd

:kittyget
echo C:\UniServer\www\doc\files\ThisPC\putty\PSCP.EXE -scp -pw %CONN[3]% %CONN[2]%@%CONN[1]%:%SECOND_WORD% %THIRD_WORD% 
C:\UniServer\www\doc\files\ThisPC\putty\PSCP.EXE -scp -pw %CONN[3]% %CONN[2]%@%CONN[1]%:%SECOND_WORD% %THIRD_WORD% 
goto end

:kittyput
IF EXIST %SECOND_WORD%\NUL goto kittyputdir
C:\UniServer\www\doc\files\ThisPC\putty\PSCP.EXE -scp -pw %CONN[3]% %SECOND_WORD% %CONN[2]%@%CONN[1]%:%THIRD_WORD% >nul
goto end

:kittyputdir
C:\UniServer\www\doc\files\ThisPC\putty\PSCP.EXE -scp -r -pw %CONN[3]% %SECOND_WORD% %CONN[2]%@%CONN[1]%:%THIRD_WORD% >nul
goto end

:kittysync
c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "echo set SYNC_GO=yes>SYNC_%UUID%.sh.bat\n"
:kittysync_loop
echo | set /p dummyName=.
C:\Windows\System32\timeout.exe /t 4 /nobreak>nul
C:\UniServer\www\doc\files\ThisPC\putty\PSCP.EXE -scp -pw %CONN[3]% %CONN[2]%@%CONN[1]%:SYNC_%UUID%.sh.bat . >nul
call SYNC_%UUID%.sh.bat
if "%SYNC_GO%" == "yes" goto kittysync_loop_end
goto kittysync_loop
:kittysync_loop_end
echo set SYNC_GO=no>SYNC_%UUID%.sh.bat
C:\UniServer\www\doc\files\ThisPC\putty\PSCP.EXE -scp -pw %CONN[3]% SYNC_%UUID%.sh.bat %CONN[2]%@%CONN[1]%:  >nul
goto end

:kittypause
if "%SECOND_WORD%" == "WINDOWS" goto not_linux_pause
c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "read -p $(echo $(tput setab 7)$(tput setaf 1)Pause...$(tput sgr 0)) reply"
pause
c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "\n"
goto end

:not_linux_pause
C:\"Program Files (x86)"\AutoIt3\AutoIt3.exe /AutoIt3ExecuteLine "ControlSend ( 'C:\UniServer\www\doc\files\ThisPC\install_pstools\%PSEXEC_EXE%', '', '', 'pause{ENTER}' )"
pause
goto end


:kittyshow
c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "stty echo\n"
goto end

:kittyhide
c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "stty -echo\n"
goto end

:kittyxset
set PARAMETERS_L=%PARAMETERS_L:kittyxset =export %
goto linux_cmd

:kittywset
c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "echo set %SECOND_WORD%=%THIRD_WORD%>%SECOND_WORD%.sh.bat\n"
C:\UniServer\www\doc\files\ThisPC\putty\PSCP.EXE -scp -pw %CONN[3]% %CONN[2]%@%CONN[1]%:%SECOND_WORD%.sh.bat %THIRD_WORD% >nul
call LINHOME.sh.bat
goto end

:kittypset
echo TODO
pause
goto end

:kittyhelp
start C:\UniServer\www\doc\files\ThisPC\install_HelpMaker\_tmphhp\kitty_interpreter.chm
goto end

:kittypreboot
rem not done for psexec
C:\"Program Files (x86)"\AutoIt3\AutoIt3.exe /AutoIt3ExecuteLine "ControlSend ( 'C:\UniServer\www\doc\files\ThisPC\install_pstools\%PSEXEC_EXE%', '', '', 'shutdown /r{ENTER}exit{ENTER}' )"
echo %time% : waiting for IP %CONN[1]% to come back from reboot, 5mn, to pass and ignore the boot sequence
rem first wait 5mn, 300sec, then start probing with ping
sleep 300
echo waiting more as needed
:kittypreboot_loop
echo | set /p dummyName=.
C:\Windows\System32\timeout.exe /t 10 /nobreak>nul
ping -n 1 %CONN[1]% > out.txt
C:\Windows\System32\find.exe /c "Lost = 1" out.txt >nul
if %errorlevel% equ 1 goto notfoundpreboot
goto kittypreboot_loop
goto done_kittypreboot
:notfoundpreboot
echo re-connected with IP %CONN[1]%
rem \nstty -echo\n

if "%SECOND_WORD%" == "LINUX" goto reboot_to_linux
start C:\UniServer\www\doc\files\ThisPC\install_pstools\%PSEXEC_EXE% \\%PEXIP% -u %PEXUS% -p %PEXPW% -s  cmd.exe /k "@echo Returned from kittypreboot"
sleep 3

:reboot_to_linux
rem to be removed
call C:\UniServer\www\doc\files\common\global_settings\SSDIP.sh.bat
call C:\UniServer\www\doc\files\common\global_settings\SSDPW.sh.bat
call C:\UniServer\www\doc\files\common\global_settings\SSDUS.sh.bat

call C:\UniServer\www\doc\files\common\global_settings\CONN.sh.bat


start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -CONN[0] %CONN[2]%@%CONN[1]% -pw %CONN[3]% -cmd "stty -echo\nPS1=\\\\\x6e${PS1}\nclear\n" -xpos 50 -ypos 0
sleep 3

:done_kittypreboot
goto end


:kittyxreboot
c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "sudo shutdown -r now\n"
echo %time% : waiting for IP %CONN[1]% to come back from reboot, 5mn, to pass and ignore the boot sequence
rem first wait 5mn, 300sec, then start probing with ping
sleep 50
C:\UniServer\www\doc\files\ThisPC\nircmd\nircmdc.exe win close title "com59 - PuTTY (inactive)"
echo deleteting putty.log
if exist putty.log del putty.log /Q
sleep 200
echo waiting more as needed
:kittyxreboot_loop
echo | set /p dummyName=.
C:\Windows\System32\timeout.exe /t 10 /nobreak>nul
ping -n 1 %CONN[1]% > out.txt
C:\Windows\System32\find.exe /c "Lost = 1" out.txt >nul
if %errorlevel% equ 1 goto notfoundreboot
goto kittyxreboot_loop
goto done_kittyxreboot
:notfoundreboot
echo re-connected with IP %CONN[1]%
rem \nstty -echo\n

if "%SECOND_WORD%" == "WINDOWS" goto reboot_to_windows
start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -CONN[0] %CONN[2]%@%CONN[1]% -pw %CONN[3]% -cmd "stty -echo\nPS1=\\\\\x6e${PS1}\nclear\n" -xpos 50 -ypos 0
sleep 3

:reboot_to_windows
call C:\UniServer\www\doc\files\common\global_settings\PEXIP.sh.bat
call C:\UniServer\www\doc\files\common\global_settings\PEXPW.sh.bat
call C:\UniServer\www\doc\files\common\global_settings\PEXUS.sh.bat
start C:\UniServer\www\doc\files\ThisPC\install_pstools\%PSEXEC_EXE% \\%PEXIP% -u %PEXUS% -p %PEXPW% -s  cmd.exe /k "@echo Returned from kittypreboot"
sleep 3

:done_kittyxreboot
goto end

:kittyxpowercycle
c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "sudo rtcwake -m off -s 10\n"
echo waiting for IP %CONN[1]% to come back from power-cycle
:kittyxpowercycle_loop
echo | set /p dummyName=.
C:\Windows\System32\timeout.exe /t 10 /nobreak>nul
ping -n 1 %CONN[1]% > out.txt
C:\Windows\System32\find.exe /c "Lost = 1" out.txt >nul
if %errorlevel% equ 1 goto notfoundpowercycle
goto kittyxpowercycle_loop
goto done_kittyxpowercycle
:notfoundpowercycle
echo re-connected with IP %CONN[1]%
rem \nstty -echo\n
start c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -CONN[0] %CONN[2]%@%CONN[1]% -pw %CONN[3]% -cmd "stty -echo\nPS1=\\\\\x6e${PS1}\nclear\n" -xpos 50 -ypos 0
sleep 3
goto done_kittyxpowercycle
:done_kittyxpowercycle
goto end

:kittygotoline
echo set GOTO_LINE=%SECOND_WORD% >GOTO_LINE.sh.bat
goto end


:wincall
rem we reverse the escape operations

set "PARAMETERS_WB=%PARAMETERS_W_NO_DBLQUOTE%"

rem for windows we need to revert this escape that was done for linux
set "PARAMETERS_WB=%PARAMETERS_WB:\x5c\x5c=\%"

set PARAMETERS_WB=%PARAMETERS_WB:\x22="%
set PARAMETERS_WB=%PARAMETERS_WB:\x26=&%
set PARAMETERS_WB=%PARAMETERS_WB:\x28=(%
set PARAMETERS_WB=%PARAMETERS_WB:\x29=)%

set PARAMETERS_WB=%PARAMETERS_WB:\x3c=^^^<%
set PARAMETERS_WB=%PARAMETERS_WB:\x3e=^^^>%
set PARAMETERS_WB=%PARAMETERS_WB:\x7c=^^^|%


rem echo PARAMETERS_WB is "[%PARAMETERS_WB%]"
rem pause 

%PARAMETERS_WB%
goto end

:bothcall

set "PARAMETERS_WB=%PARAMETERS_W_NO_DBLQUOTE%"
rem reverse the escaped in this line

rem for windows we need to revert this escape that was done for linux
set "PARAMETERS_WB=%PARAMETERS_WB:\x5c\x5c=\%"

set PARAMETERS_WB=%PARAMETERS_WB:\x22="%
set PARAMETERS_WB=%PARAMETERS_WB:\x26=&%
set PARAMETERS_WB=%PARAMETERS_WB:\x28=(%
set PARAMETERS_WB=%PARAMETERS_WB:\x29=)%

set PARAMETERS_WB=%PARAMETERS_WB:\x3c=^^^<%
set PARAMETERS_WB=%PARAMETERS_WB:\x3e=^^^>%
set PARAMETERS_WB=%PARAMETERS_WB:\x7c=^^^|%

rem echo "PARAMETERS_WB is [%PARAMETERS_WB%]"
rem pause 

%PARAMETERS_WB%
rem %PARAMETERS_W_NO_DBLQUOTE%
rem %FIRST_WORD% %OTHER_THAN_FIRST_WORD%

goto linux_cmd

:psexec_cmd

set "PARAMETERS_WB=%PARAMETERS_W_NO_DBLQUOTE%"

rem for windows we need to revert this escape that was done for linux
set "PARAMETERS_WB=%PARAMETERS_WB:\x5c\x5c=\%"

set PARAMETERS_WB=%PARAMETERS_WB:\x22="%
set PARAMETERS_WB=%PARAMETERS_WB:\x26=&%
set PARAMETERS_WB=%PARAMETERS_WB:\x28=(%
set PARAMETERS_WB=%PARAMETERS_WB:\x29=)%

set PARAMETERS_WB=%PARAMETERS_WB:\x3c=^^^<%
set PARAMETERS_WB=%PARAMETERS_WB:\x3e=^^^>%
set PARAMETERS_WB=%PARAMETERS_WB:\x7c=^^^|%


if "%KITTY_DEBUG%" NEQ "yes" goto no_debug_pause_pex
echo FIRST_WORD is [%FIRST_WORD%]
echo FIRST_WORD_L is [%FIRST_WORD_L%]
echo SECOND_WORD is [%SECOND_WORD%]
echo THIRD_WORD is [%THIRD_WORD%]
echo REST_WORDS is [%REST_WORDS%]
echo OTHER_THAN_FIRST_WORD is [%OTHER_THAN_FIRST_WORD%]
echo PARAMETERS_W is [%PARAMETERS_W%]
echo STR_PARAMETERS_W_NO_DBLQUOTE is [%STR_PARAMETERS_W_NO_DBLQUOTE%]
echo PARAMETERS_W_NO_DBLQUOTE is [%PARAMETERS_W_NO_DBLQUOTE%]
echo sending : [%PARAMETERS_WB%]
pause
:no_debug_pause_pex

rem normally we need to wait for the prompt to show before sending a command
sleep 1

if "%PSEXEC_EXE%" == "PsExec.exe" goto psexec
if "%PSEXEC_EXE%" == "paexec.exe" goto paexec
goto end_ps
:psexec
rem no source code available
C:\"Program Files (x86)"\AutoIt3\AutoIt3.exe /AutoIt3ExecuteLine "ControlSend ( '\\%PEXIP%: cmd.exe', '', '', '%PARAMETERS_WB%{ENTER}' )"
:paexec
rem for the window titled : 'C:\UniServer\www\doc\files\ThisPC\install_pstools\paexec.exe'
C:\"Program Files (x86)"\AutoIt3\AutoIt3.exe /AutoIt3ExecuteLine "ControlSend ( 'C:\UniServer\www\doc\files\ThisPC\install_pstools\paexec.exe', '', '', '%PARAMETERS_WB%{ENTER}' )"
:end_ps
goto end


:linux_cmd
if "%KITTY_DEBUG%" NEQ "yes" goto no_debug_pause_lin
echo FIRST_WORD is %FIRST_WORD%--
echo FIRST_WORD_L is %FIRST_WORD_L%--
echo SECOND_WORD is %SECOND_WORD%--
echo THIRD_WORD is %THIRD_WORD%--
echo REST_WORDS is %REST_WORDS%--
echo OTHER_THAN_FIRST_WORD is %OTHER_THAN_FIRST_WORD%--
echo sending  : "%FIRST_WORD_L% %OTHER_THAN_FIRST_WORD%\n"
echo original : %PARAMETERS_L%--
pause
:no_debug_pause_lin

c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd %PARAMETERS_L%

rem ne marche pas avec la commande
rem countdev=$(lspci | grep 'Non-Volatile memory controller' | wc -l)
rem a cause du separateur '=' (egal)
rem c:\UniServer\www\doc\files\ThisPC\install_kitty\kitty_portable.exe -sendcmd "%FIRST_WORD_L% %OTHER_THAN_FIRST_WORD%\n"

:end
rem pause
exit /b
