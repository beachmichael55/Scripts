@echo off & SETLOCAL ENABLEDELAYEDEXPANSION

:: Check if the current session is already elevated.
	net session >NUL 2>&1 && goto :ELEVATED

:: Add -Wait before -Verb RunAs to wait for the reinvocation to exit.
	set ELEVATE_CMDLINE=cd /d "%~dp0" ^& "%~f0" %*
	powershell.exe -noprofile -c Start-Process -Verb RunAs cmd.exe \"/k $env:ELEVATE_CMDLINE\"
exit /b %ERRORLEVEL%

:ELEVATED
	color 1f
	set ConsoleBackColor=Blue
	set ConsoleForeColor=White
	title Admin

::Check if Windows Reserved Storage is enabled, and set a variable to it
DISM.exe /Online /Get-ReservedStorageState | findstr /c:"Reserved storage is enabled." > nul
if %errorlevel% equ 0 (
    set StorageState=ENABLED
) else (
    set StorageState=DISABLED
)

:MENU
	cls
	echo Script file : %~f0
	echo ...............................................
	echo PRESS 1 or 2 to select your task, or 3 to EXIT.
	echo ...............................................
	echo .......Restart PC AFTER Changes................
	echo ...............................................
	echo ----Reserved Storage is:%StorageState%
	echo 1 - Disables Reserved Storage
	echo 2 - Enables Reserved Storage (Use only if disabled)
	echo 3 - EXIT
	echo.
	
	SET /P M=Type 1, 2, or 3  then press ENTER:
	IF %M%==1 GOTO :Disable1
	IF %M%==2 GOTO :Enable1
	IF %M%==3 GOTO :End

:Disable1
echo "Disabling Reserved Storage"
Dism /Online /Set-ReservedStorageState /State:Disabled /Quiet /NoRestart >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\ReserveManager" /v "MiscPolicyInfo" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\ReserveManager" /v "PassedPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f >nul 2>&1
GOTO MENU

:Enable1
echo "Enabling Reserved Storage"
Dism /Online /Set-ReservedStorageState /State:Enable /Quiet /NoRestart >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\ReserveManager" /v "MiscPolicyInfo" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\ReserveManager" /v "PassedPolicy" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "1" /f >nul 2>&1
GOTO MENU

:End
endlocal
exit