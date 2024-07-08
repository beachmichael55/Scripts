@echo off & SETLOCAL ENABLEDELAYEDEXPANSION
:: Check if the current session is already elevated.
	net session >NUL 2>&1 && goto :ELEVATED

:: Add -Wait before -Verb RunAs to wait for the reinvocation to exit.
	set ELEVATE_CMDLINE=cd /d "%~dp0" ^& "%~f0" %*
	powershell.exe -noprofile -c Start-Process -Verb RunAs cmd.exe \"/k $env:ELEVATE_CMDLINE\"
exit /b %ERRORLEVEL%

:ELEVATED
:: Sets console color and title.
	color 1f
	set ConsoleBackColor=Blue
	set ConsoleForeColor=White
	title Admin

:MENU
	cls
	echo Script file : %~f0
	echo ...............................................
	echo PRESS 1, 2, 3, etc to select your task, or 4 to EXIT.
	echo ...............................................
	echo.
	echo 1 - Run First in Normal Mode
	echo 2 - Boot into SAFE MODE
	echo 3 - Run In SAFE MODE Next and Reboots into Normal Mode
	echo 4 - Exit
	echo.
:: Sets variables to "go" to, when option is selected in the menu.
	SET /P M=Type1, 2, 3, ... then press ENTER:
	IF %M%==1 GOTO :STAGE1
	IF %M%==2 GOTO :BOOTSAFE
	IF %M%==3 GOTO :STAGE2
	IF %M%==4 GOTO :End

:STAGE1
for /f "tokens=*" %%a in ('DISM /Online /Cleanup-Image /AnalyzeComponentStore 2^>^&1') do (
    echo %%a | findstr /C:"Component Store Cleanup Recommended : Yes" >nul
    if not errorlevel 1 (
        DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase
		pause
        GOTO MENU
    )
)
pause
GOTO MENU

:BOOTSAFE
bcdedit /set {default} safeboot minimal
shutdown -r -f -t 4
exit

:STAGE2
fsutil resource setautoreset true c:\&fsutil usn deletejournal /d /n c:
Dism.exe /online /Cleanup-Image /StartComponentCleanup
Dism.exe /Online /Cleanup-Image /RestoreHealth
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
bcdedit /deletevalue {default} safeboot
pause
shutdown -r -f -t 4

:End
endlocal
exit