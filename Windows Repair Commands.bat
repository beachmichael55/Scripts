@echo off & SETLOCAL ENABLEDELAYEDEXPANSION
:: Check if the current session is already elevated.
	net session >NUL 2>&1 && goto :ELEVATED

:: Add -Wait before -Verb RunAs to wait for the reinvocation to exit.
	set ELEVATE_CMDLINE=cd /d "%~dp0" ^& "%~f0" %*
	powershell.exe -noprofile -c Start-Process -Verb RunAs cmd.exe \"/k $env:ELEVATE_CMDLINE\"
exit /b %ERRORLEVEL%

:: ---------------------Everything after this line is elevated.------------------
:ELEVATED
:: Sets console color and title.
	color 1f
	set ConsoleBackColor=Blue
	set ConsoleForeColor=White
	title Admin
	
:: Code for menu display.
:MENU
	cls
	echo.
	echo ...............................................
	echo PRESS 1, 2, 3, etc to select your task, or 9 to EXIT.
	echo ...............................................
	echo.
	echo Script file : %~f0
	echo 1 - Repair Windows System Files With SFC
	echo 2 - Check Health of The System Image With DISM...RestoreHealth
	echo 3 - Check Health of The System Image With install.wim From Drive
	echo 4 - Remove Old Packages From Updates and WinSxS
	echo 5 - Check A Disk
	echo 6 - Check All Disks
	echo 7 - Check All Disks With User Exceptions
	echo 8 - Check All Disks With User Includes
	echo 9 - EXIT
	echo.
:: Sets variables to "go" to, when option is selected in the menu.
	SET /P M=Type1, 2, 3, ... then press ENTER:
	IF %M%==1 GOTO :SFC
	IF %M%==2 GOTO :DiskCheckHealth
	IF %M%==3 GOTO :DiskCheckHealthWim
	IF %M%==4 GOTO :DISMComponentClean
	IF %M%==5 GOTO :CheckDisk
	IF %M%==6 GOTO :CheckDiskAll
	IF %M%==7 GOTO :CheckDiskAllExcept
	IF %M%==8 GOTO :CheckDiskAllIncl
	IF %M%==9 GOTO :End

:SFC
sfc /scannow
pause
GOTO MENU

:DiskCheckHealth
DISM /Online /Cleanup-Image /RestoreHealth
pause
GOTO MENU

:DiskCheckHealthWim
for %%i in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%i:\sources\install.wim" (
        set DRIVE=%%i
        goto :ContinueDISM1
    )
)
	:ContinueDISM1
	DISM /Online /Cleanup-Image /RestoreHealth /Source:%DRIVE%:\sources\install.wim /LimitAccess
	pause
GOTO MENU

:DISMComponentClean
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

:CheckDisk
Set "disks="
Set /P "disks=Enter the Disk letter: "
chkdsk %disks%: /x /f /r
pause
GOTO MENU

:CheckDiskAll
for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    fsutil fsinfo drivetype %%d: | find "DriveType: 3" > nul
    if !errorlevel! equ 0 (
        echo Running chkdsk on drive %%d: ...
        chkdsk %%d: /x /f /r
    )
)
pause
GOTO MENU

:CheckDiskAllExcept
set /p exclude=Enter drive letters to exclude (e.g., CDEF): 

for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    echo !exclude! | find "!d!" > nul
    if errorlevel 1 (
        fsutil fsinfo drivetype %%d: | find "DriveType: 3" > nul
        if !errorlevel! equ 0 (
            echo Running chkdsk on drive %%d: ...
            chkdsk %%d: /x /f /r
        )
    )
)
pause
GOTO MENU

:CheckDiskAllIncl
set /p include=Enter drive letters to include (e.g., CDEF): 

for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    echo !include! | find "!d!" > nul
    if errorlevel 1 (
        fsutil fsinfo drivetype %%d: | find "DriveType: 3" > nul
        if !errorlevel! equ 0 (
            echo Skipping chkdsk on drive %%d...
        )
    ) else (
        echo Running chkdsk on drive %%d: ...
        chkdsk %%d: /x /f /r
    )
)
pause
GOTO MENU

:End
endlocal
exit