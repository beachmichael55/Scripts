@echo off
::Enables the delayed environment variable expansion.
setlocal enabledelayedexpansion

::Checks if is Admin, and goes to the function corresponding to the result
net session >nul 2>&1
if %ERRORLEVEL% equ 0 (
    :::YES Admin
	goto :Elevated
) else (
   ::Not Admin
   goto :Start
)

::sets color and title, if Admin
:Elevated
color 1f
set ConsoleBackColor=Blue
set ConsoleForeColor=White
title Admin

:Start
:: Tries to find 7z.exe location and if found, sets 7zip variable.
set SevenZip=
if "%SevenZip%"=="" (
	::For 32-bit version check
    if exist "%ProgramFiles(x86)%\7-zip\7z.exe" (
        set SevenZip="%ProgramFiles(x86)%\7-zip\7z.exe"
	)
	::For 64-bit version check
	if exist "%ProgramFiles%\7-zip\7z.exe" (
        set SevenZip="%ProgramFiles%\7-zip\7z.exe"
	) else (
	:: If 7z is not found in the default locations, will ask for it. Then run check for location EXE, then set it's location.
		set /p SevenZipDir="Enter path to 7zip (e.g., C:\Program Files\7-zip\): "
		if exist "!SevenZipDir!\7z.exe" (
			set SevenZip="!SevenZipDir!\7z.exe"
		)
    )
)
:: Tries to find Winrar location and if found, sets winrar variable.
set WinRAR=
:: Asks if you want to use WinRAR in scripts
echo.
echo Note: WinRar support is only for archive "Conversion" only.
echo.
    choice /C YN /N /M "Do you want to add WinRAR support? [Y/N]: "
    if errorlevel 2 (
        goto :DefaultVar
    ) else (
        if "%WinRAR%"=="" (
			::For 32-bit version check
			if exist "%ProgramFiles(x86)%\WinRAR\WinRAR.exe" (
				set WinRAR="%ProgramFiles(x86)%\WinRAR\WinRAR.exe"
			)
			::For 64-bit version check
			if exist "%ProgramFiles%\WinRAR\WinRAR.exe" (
				set WinRAR="%ProgramFiles%\WinRAR\WinRAR.exe"
			) else (
			:: If WinRar is not found in the default locations, will ask for it. Then run check for location EXE, then set it's location.
				set /p WinRARDir="Enter path to WinRAR (e.g., C:\Program Files\WinRAR\): "
				if exist "!WinRARDir!\WinRAR.exe" (
				set WinRAR="!WinRARDir!\WinRAR.exe"
				)
			)
		)
    )
	
:DefaultVar
:: sets default working directory.
pushd %~dp0
:: sets default variables.
set COMPRESSION=9
set "CompressionName="
set Del_Toggle=NO
set Formats=7zip
::Sets default password variable
set "PassW="
set "PassWCommand="
set PassCheck=NO
set ArchHeadersCheck=NO


:MENU
:: Check current Compression variable, and converts it to easier naming to display on menu.
if %COMPRESSION%==0 (
	set CompressionName=Store
)
if %COMPRESSION%==1 (
	set CompressionName=Fastest
)
if %COMPRESSION%==3 (
	set CompressionName=Fast
)
if %COMPRESSION%==5 (
	set CompressionName=Normal
)
if %COMPRESSION%==7 (
	set CompressionName=Maximum
)
if %COMPRESSION%==9 (
	set CompressionName=Ultra
)
::Check for which format, zip or 7zip, and sets the variables corresponding to them. Like the extension used
if "%Formats%"=="7zip" (
	set InterFormats=T7z
	set Ext=7z
	set FILETYPES1=*.rar *.zip
) else if "%Formats%"=="Zip" (
	set InterFormats=Tzip
	set Ext=zip
	set FILETYPES1=*.rar *.7z
) else if "%Formats%"=="Rar" (
	set InterFormats=afrar
	set Ext=rar
	set FILETYPES1=*.zip *.7z
)
::Sets if password is enabled or not variable
if %PassCheck%==NO (
	set PassCheck=NO
) else (
	set PassCheck=YES
)
:: Code for menu display.
	cls
echo.
echo ...............................................
echo PRESS 1, 2, 3, etc to select your task.
echo ...............................................
if defined WinRAR (
	echo. Note: WinRar support is only for archive "Conversion" only.
)
echo.
echo. Working Directory:[%cd%]
echo.
echo. Archive Format:[%Formats%]
echo.
echo. Current Compression Level:[%CompressionName%]
echo.
echo  Password Enabled:[%PassCheck%] Header Encrypted:[%ArchHeadersCheck%]: Only for 7zip.
echo.
echo. Delete Originals After:[%Del_Toggle%] 
echo.
echo. 1 - All Folders in Working Directory, Separately W/O Home Folder
echo. 2 - All Folders in Working Directory, Separately With Home Folder
echo. 3 - Everything in Working Directory to 1 Archive
echo. 4 - All Folders in Working Directory to 1 Archive
echo. 5 - Recursively Convert Archives To Selected Format
echo.     Note for above: Archives must NOT have a password set in them!
echo. 6 - Change Directory
echo. 7 - Change Archive Format
echo. 8 - Change Compression Level
echo. 9 - Change "Delete Originals After" Toggle
echo. A - Add/Remove Password
echo. B - View Current Password
echo. C - Request Admin Privileges
echo. D - EXIT
echo.
:: sets variables to "go" to, when option is selected in the menu.
choice /C 123456789ABCD /N /M "Type 1, 2, 3, ...to choose action: "
set "M=%ERRORLEVEL%"
	IF %M%==1 goto :AllFoldWOHome
	IF %M%==2 goto :AllFoldWithHome
	IF %M%==3 goto :AllEverOneArch
	IF %M%==4 goto :AllFoldOneArch
	IF %M%==5 goto :Converter
	IF %M%==6 goto :ChangeDir
	IF %M%==7 goto :ChangeFormat
	IF %M%==8 goto :ConpressionLvl
	IF %M%==9 goto :ToggleDelete
	IF %M%==10 goto :AddPass
	IF %M%==11 goto :ViewPass
	IF %M%==12 goto :GETAdmin
	IF %M%==13 goto :End

:: goto for option 1.
:AllFoldWOHome
for /d %%X in (*) do (
    cls
    cd /D %%X
    %SevenZip% -mx=%COMPRESSION% A -%InterFormats% %PassWCommand% -r "..\%%X.%Ext%" "*.*" 
    cd ..
)
:: Checks if "Delete Originals After" is yes and "GO TO"s that function.
IF %Del_Toggle%==YES (
	:: If YES for the deletion proccess.
	for /d %%a in (*) do (if exist "%%a\" rmdir /S /Q "%%a")
	)
goto :MENU

::Code that compresses all folders in the working directory separately With OUT the "Home Folder"
:AllFoldWithHome
::Code to compress each subdirectory in the current directory
for /D %%i in (*) do (
	%SevenZip% -mx=%COMPRESSION% A -%InterFormats% %PassWCommand% "%%i.%Ext%" ".\%%i\"
)
:: Checks if "Delete Originals After" is YES, then does that function.
IF %Del_Toggle%==YES (
	:: If YES for the deletion proccess.
	for /d %%a in (*) do (if exist "%%a\" rmdir /S /Q "%%a")
)
goto :MENU

::Code that compresses EVERYTHING in the working directory to one archive
:AllEverOneArch
::Code to compress all in the current directory
for %%Z in (.) do set "DirName=%%~nxZ"
	%SevenZip% -mx=%COMPRESSION% A -%InterFormats% %PassWCommand% "%DirName%.%Ext%" -xr^^!7zipAIO.bat
	:: Checks if "Delete Originals After" is YES, then does that function.
	IF %Del_Toggle%==YES (
	:: If YES for the deletion proccess.
		for /f "delims=" %%F in ('dir "%CD%" /s /b /a-d ^|findstr /vile ".bat .%Ext%"') do del "%%F"
		for /f "delims=" %%a in ('dir /b /AD ^| find /v "lnk"') do rmdir /S /Q "%%a"
	) 
goto :MENU

::Code that compresses only FOLDERS in the working directory to one archive
:AllFoldOneArch
::Code to compress the folders in the current directory
for %%F in (.) do set "DirName=%%~nxF"
	for /d %%i in (*) do (
	%SevenZip% -mx=%COMPRESSION% A -%InterFormats% %PassWCommand% "%DirName%.%Ext%" -r "%%i\*.*"
)
:: Checks if "Delete Originals After" is YES, then does that function.
IF %Del_Toggle%==YES (
	:: If YES for the deletion proccess.
	for /f "delims=" %%a in ('dir /b /AD ^| find /v "lnk"') do rmdir /S /Q "%%a"
)
goto :MENU

:: Code for recursively convert archives.
:Converter
cls
for /r %%f in (%FILETYPES1%) do (
	:: Build some easier to read variables
	set FILE=%%f
	set FILE_NO_EXT=%%~nf
	set FILE_PATH=%%~dpf
	set NEW_FILE=!FILE_NO_EXT!.%Ext%
	set UNPACK_DIR=!FILE_PATH!!FILE_NO_EXT!_tmp
	::Extracts archives
	if exist !NEW_FILE! (
		echo '!NEW_FILE!' already is converted. && pause
	) else (
		%SevenZip% x -y -o"!UNPACK_DIR!" "!FILE!" *
		pushd "!UNPACK_DIR!"
		:: Do the conversion
		if "%Formats%"=="Rar" (
			%WinRAR% a -y -r -m%COMPRESSION% -ep1 ..\"!NEW_FILE!" *
		) else (
			%SevenZip% a -y -r -mmt4 -mx%COMPRESSION% -%InterFormats% ..\"!NEW_FILE!" *
		)
		IF %Del_Toggle%==YES (
			:: If YES for the deletion proccess.
			del /f /q "!FILE!"
		)
		popd
		:: Cleanup unpack directory
		rmdir /s /q "!UNPACK_DIR!"
	)
)
goto :MENU

::Changes Working Directory
:ChangeDir
cls
set "WorkDir="
:: Request input from the user to change working directory.
choice /C YN /N /M "Do you want to change the working directory? [Y/N]: "
	if errorlevel 2 goto :MENU
	set /P "WorkDir=Please enter your work directory and then press ENTER: "
	:: Add quotes around the input path to handle spaces.
	set "WorkDir=%WorkDir:"=%"
	:: Check if the input is a valid directory.
	if not exist "%WorkDir%" (
		echo Invalid directory.
		pause
		goto :ChangeDir
	)
    :: Change the working directory.
    CD /D "%WorkDir%"
goto :MENU

::Code to toggle archive formats
:ChangeFormat
cls
	echo.
	echo ...............................................
	echo PRESS 1, 2, 3, etc to select your task, or 4 to Back.
	echo ...............................................
	echo. 1 - 7zip
	echo. 2 - Zip
	if defined WinRAR (
	echo. 3 - Rar
	)
	echo. 4 - Back
	echo.
	choice /C 1234 /N /M "Type 1, 2, 3, ...to choose action: "
	set "M=%ERRORLEVEL%"
	IF %M%==1 goto :severzipped
	IF %M%==2 goto :zipped
	IF %M%==3 goto :rarzipped
	IF %M%==4 goto :MENU

goto :MENU
:severzipped
set Formats=7zip
goto :MENU
:zipped
set Formats=Zip
goto :MENU
:rarzipped
set Formats=Rar
goto :MENU

::Menu for Compression level selection
:ConpressionLvl
cls
echo.
echo ...............................................
echo. PRESS 1, 2, 3, etc to select your task, or 7 to Back.
echo ...............................................
echo.
echo. 1 - Store
echo. 2 - Fastest
echo. 3 - Fast
echo. 4 - Normal
echo. 5 - Maximum
echo. 6 - Ultra
echo. 7 - Back
echo.
choice /C 1234567 /N /M "Type 1, 2, 3, ...to choose action: "
set "M=%ERRORLEVEL%"
	IF %M%==1 goto :STORE
	IF %M%==2 goto :FASTEST
	IF %M%==3 goto :FAST
	IF %M%==4 goto :NORMAL
	IF %M%==5 goto :MAXIMUM
	IF %M%==6 goto :UNLTRA
	IF %M%==7 goto :MENU

:AddPass
:: Request input from the user to change working directory.
cls
echo.
echo If a password is set and user selects "NO", it will clear any passwords currently set.
echo.
choice /C YN /N /M "Do you want to add a password? [Y/N]: "
if errorlevel 2 (
	set "PassW="
	set "PassWCommand="
	set PassCheck=NO
	set ArchHeadersCheck=NO
	goto :MENU
	)
set /P "PassW=Please enter the Password, and then press ENTER: "
set "PassWCommand=-p%PassW%"
set PassCheck=YES

:ArchHeaders
choice /C YN /N /M "Do you want to also encrypt archive headers, so filenames will be encrypted? [Y/N]: "
if errorlevel 2 (
	set "PassWCommand=-p%PassW%"
	set ArchHeadersCheck=NO
	goto :ViewPass
) else (
	set "PassWCommand=-p%PassW% -mhe"
	set ArchHeadersCheck=YES
	goto :ViewPass
)

:ViewPass
cls
choice /C YN /N /M "Do you want to view set password? [Y/N]: "
if errorlevel 2 (
	goto :MENU
) else (
	echo. -Password is:%PassW%
	pause
	goto :MENU
)

:: "goto" options for setting Compression levels.
:: goto for option in Compression menu 1.
:STORE
set COMPRESSION=0
goto :MENU
:: goto for option in Compression menu 2.
:FASTEST
set COMPRESSION=1
goto :MENU
:: goto for option in Compression menu 3.
:FAST
if %Formats%==Rar (
set COMPRESSION=2
) else (
set COMPRESSION=3
)
goto :MENU
:: goto for option in Compression menu 4.
:NORMAL
if %Formats%==Rar (
set COMPRESSION=3
) else (
set COMPRESSION=5
)
goto :MENU
:: goto for option in Compression menu 5.
:MAXIMUM
if %Formats%==Rar (
set COMPRESSION=4
) else (
set COMPRESSION=7
)
goto :MENU
:: goto for option in Compression menu 6.
:UNLTRA
if %Formats%==Rar (
set COMPRESSION=5
) else (
set COMPRESSION=9
)
goto :MENU
 
:: sets that after Compression, if the original files/folders are deleted.
:: sets toggle variable yes/no of files/folders deletion.
:ToggleDelete
if %Del_Toggle%==NO (set Del_Toggle=YES) else (set Del_Toggle=NO)
goto :MENU

::Changes the script to run As Admin mode
:GETAdmin
::Check if running as admin, and if it is, goes back to the START function
net session >NUL 2>&1 && goto :Start
::Elevates the script to admin
set ELEVATE_CMDLINE=cd /d "%~dp0" ^& "%~f0" %*
powershell.exe -noprofile -c Start-Process -Verb RunAs cmd.exe \"/k $env:ELEVATE_CMDLINE\"
exit /b %ERRORLEVEL%

:: "goto" option to Exit the script.
:End
endlocal
exit