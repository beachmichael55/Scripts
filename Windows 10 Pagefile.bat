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

::Sets variable to disaplay if PageFile exists or no
	if exist "%SystemDrive%\pagefile.sys" (
		set PAGE=YES
	) else (
		set PAGE=NO
	)
::Sets variable to disaplay if PageFile is set to Auto Mode
	for /f "tokens=2 delims==" %%I in ('wmic computersystem get AutomaticManagedPagefile /value /format:list') do (
		set "autovalue=%%I"
	)

::Get initial size and maximum size of the page file using wmic computersystem get
	for /f "tokens=1,2 delims== " %%a in ('wmic pagefile list /format:list ^| findstr /i "AllocatedBaseSize"') do (
		set "TotalVirtualMemorySize=%%b"
	)

:MENU
	cls
	echo Script file : %~f0
	echo ...............................................
	echo PRESS 1,2  or 3 to select your task, or 5 to EXIT.
	echo .......Restart PC after changes................
	echo ...............................................
	echo --- Pagefile Exists:%PAGE%
	echo --- PageFile Managed Auntomatic:%autovalue%
	echo --- Current Memory Size:%TotalVirtualMemorySize%MB
	echo 1 - Disables and Removes Pagefile
	echo 2 - Enables Pagefile and sets to Automatic
	echo 3 - Set Pagefile Size
	echo 4 - Restart PC
	echo 5 - EXIT
	echo.
	
	SET /P M=Type 1, 2, 3, or 4 then press ENTER:
	IF %M%==1 GOTO DISABLE
	IF %M%==2 GOTO AUTOMATIC
	IF %M%==3 GOTO SETSIZE
	IF %M%==4 GOTO RESTPC
	IF %M%==5 GOTO EXI

:DISABLE
	echo "Disabling and Removing Pagefile"
	wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False >nul 2>&1
	wmic pagefileset where name="%SystemDrive%\\pagefile.sys" set InitialSize=0,MaximumSize=0 >nul 2>&1
	wmic pagefileset where name="%SystemDrive%\\pagefile.sys" delete >nul 2>&1
GOTO MENU

:AUTOMATIC
	echo "Enabling Pagefile to Automatic"
	wmic computersystem where name="%computername%" set AutomaticManagedPagefile=true >nul 2>&1
GOTO MENU


:SETSIZE
	SET /P SIZE="Enter the pagefile size in MB (e.g., 4096): "
	echo "Setting Pagefile Size to %SIZE% MB"
	wmic pagefileset where name="%SystemDrive%\\pagefile.sys" set InitialSize=%SIZE%,MaximumSize=%SIZE% >nul 2>&1
GOTO MENU

:RESTPC
	shutdown /r /t 4 >nul 2>&1
exit /b

:EXI
endlocal
exit /b