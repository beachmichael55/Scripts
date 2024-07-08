@echo off
setlocal enabledelayedexpansion

:: Set the path to your ROMs folder
set "RomDir=%~dp0"
:: Set the path to your emulator executables
echo.
echo Currently supported emulators:
echo [Ares, BizHawk, Blastem, Cemu, Citra, DeSmuME, Dolphin, Duckstation, Flycast, MelonDS, Mesen, PPSSPP, Pcsx2
echo Rpcs3, Ryujinx, Simple64, Vita3K, Xemu, Xenia, Yuzu, mGBA]
echo.
echo If any others, it my work. It sets a default launch shortcut.
echo Note some of these emulators need to set a option in the emulator itself for fullscreen, or need to use a keyboard shortcut, ect.
echo Examples from above are [mednafen, Snes9x].
echo.
set /P "EmuDir=Please enter the emulator folder location and then press ENTER (or type 'exit' to stop): "
if /I "%EmuDir%"=="exit" goto :done
:: List all .exe files in the entered Emulator Directory
echo Available Emulators in %EmuDir%:
dir /B /A:-D "%EmuDir%\*.exe"
set /P "SelectedEmulator=Enter the name of the emulator (with extension) you want to use: "
set "EmulatorExe=%EmuDir%\!SelectedEmulator!"
::Sets some Rpcs3 emulator blacklisted files, being .self, to not make a shortcut from. Can remove or add whatever one wants.
set "BlackListSelf=eclipse.self hksputhreadconstraint.self GAMESEL.self coo.ppu.self gos.ppu.self"
cls

Call :Rpcs3
Call :AllOthers
goto :DONE

:Rpcs3
if /I "%SelectedEmulator%"=="rpcs3.exe" (
	rem Loop through ROMs and create batch files
	for /D %%G in ("%RomDir%*") do (
		if not "%%~nxi"=="%~nx0" (
			echo Working on Directory:%%G
			set "has_self_file=false"
			for %%H in ("%%G\PS3_GAME\USRDIR\*.self") do (
				set "rom_name=%%~nxG"
				set "rom_extension=%%~nxH"
				set "batch_file=!RomDir!\!rom_name!_%%~nH.bat"
				echo Checking %%~nxH
				echo Making shortcut for [!rom_name!] with [%SelectedEmulator%].
				echo !BlackListSelf! | find /I "%%~nxH" >nul && (
					echo Skipping blacklisted file: %%~nxH
				) || (
					echo @echo off> "!batch_file!"
					echo start "" "!EmulatorExe!" --no-gui --fullscreen "%%H" >> "!batch_file!"
					echo exit>> "!batch_file!"
				)
			)
			
		for %%H in ("%%G\PS3_GAME\USRDIR\EBOOT.BIN*") do (
			set "rom_name=%%~nxG"
			set "rom_extension=%%~nxH"
			set "batch_file=!RomDir!\!rom_name!.bat"
			echo Making shortcut for [!rom_name!] with [%SelectedEmulator%].
			echo !BlackListSelf! | find /I "EBOOT.BIN" >nul && (
				echo Skipping blacklisted file: EBOOT.BIN
			) || (
				echo @echo off> "!batch_file!"
						echo start "" "!EmulatorExe!" --no-gui --fullscreen "%%H" >> "!batch_file!"
						echo exit>> "!batch_file!"
				)
			)
		)
	)
)
goto :eof

:AllOthers
set "EmulatorMatched="
IF /I NOT "%SelectedEmulator%"=="rpcs3.exe" (
	rem Loop through ROMs and create batch files
	for %%i in ("%RomDir%*.*") do (
		if not "%%~nxi"=="%~nx0" (
			:: Define emulator-specific settings and launch commands
			if /I "%SelectedEmulator%"=="Ryujinx.exe" (
				set "LaunchOptions=--fullscreen "%%~fi""
				set "EmulatorMatched=true"
			) 
			if /I "%SelectedEmulator%"=="Vita3K.exe" (
				set "LaunchOptions=--fullscreen "%%~fi""
				set "EmulatorMatched=true"
			) 
			if /I "%SelectedEmulator%"=="xenia.exe" (
				set "LaunchOptions=--fullscreen "%%~fi""
				set "EmulatorMatched=true"
			) 
			if /I "%SelectedEmulator%"=="yuzu.exe" (
				set "LaunchOptions=--fullscreen "%%~fi""
				set "EmulatorMatched=true"
			) 
			if /I "%SelectedEmulator%"=="citra-qt.exe" (
				set "LaunchOptions=--fullscreen "%%~fi""
				set "EmulatorMatched=true"
			) 
			if /I "%SelectedEmulator%"=="EmuHawk.exe" (
				set "LaunchOptions=--fullscreen "%%~fi""
				set "EmulatorMatched=true"
			)
			rem Add more emulators with the same launch options here

			rem Define emulator-specific settings and launch commands for emulators with different launch options
			if /I "%SelectedEmulator%"=="xemu.exe" (
				set "LaunchOptions=-dvd_path "%%~fi" -full-screen"
				set "EmulatorMatched=true"
			)
			if /I "%SelectedEmulator%"=="Dolphin.exe" (
				set "LaunchOptions=--exec="%%~fi" --batch"
				set "EmulatorMatched=true"
			) 
			if /I "%SelectedEmulator%"=="duckstation-qt-x64-ReleaseLTCG.exe" (
			set "LaunchOptions=-fullscreen -fastboot "%%~fi""
				set "EmulatorMatched=true"
			) 
			if /I "%SelectedEmulator%"=="Cemu.exe" (
				set "LaunchOptions=-g "%%~fi" -f"
				set "EmulatorMatched=true"
			) 
			if /I "%SelectedEmulator%"=="pcsx2-qtx64-avx2.exe" (
				set "LaunchOptions=-nogui -bigpicture -fullscreen -fastboot "%%~fi""
				set "EmulatorMatched=true"
			) 
			if /I "%SelectedEmulator%"=="ares.exe" (
				set "LaunchOptions=--system "Saturn" "%%~fi" --fullscreen"
				set "EmulatorMatched=true"
			)
			if /I "%SelectedEmulator%"=="EmuHawk.exe" (
				set "LaunchOptions="%%~fi" --fullscreen"
				set "EmulatorMatched=true"
			)
			if /I "%SelectedEmulator%"=="blastem.exe" (
				set "LaunchOptions=-fullscreen "%%~fi""
				set "EmulatorMatched=true"
			)
			if /I "%SelectedEmulator%"=="DeSmuME_0.9.13_x64.exe" (
				set "LaunchOptions=--windowed-fullscreen "%%~fi""
				set "EmulatorMatched=true"
			)
			if /I "%SelectedEmulator%"=="flycast.exe" (
				set "LaunchOptions=-config window:fullscreen=yes "%%~fi""
				set "EmulatorMatched=true"
			)
			if /I "%SelectedEmulator%"=="melonDS.exe" (
				set "LaunchOptions="%%~fi" -f"
				set "EmulatorMatched=true"
			)
			if /I "%SelectedEmulator%"=="Mesen.exe" (
				set "LaunchOptions=/fullscreen "%%~fi""
				set "EmulatorMatched=true"
			)
			if /I "%SelectedEmulator%"=="PPSSPPWindows64.exe" (
				set "LaunchOptions="%%~fi" --pause-menu-exit --fullscreen"
				set "EmulatorMatched=true"
			)
			if /I "%SelectedEmulator%"=="simple64-gui.exe" (
				set "LaunchOptions=--nogui "%%~fi""
				set "EmulatorMatched=true"
			)
			if /I "%SelectedEmulator%"=="mGBA.exe" (
				set "LaunchOptions=-f "%%~fi" --pause-menu-exit --fullscreen"
				set "EmulatorMatched=true"
			)
			rem If none are found, sets default launch option
			if not defined EmulatorMatched (
				set "LaunchOptions="%%~fi""
			)
			rem batch file creation
			set "rom_name=%%~ni"
			set "rom_extension=%%~xi"
			echo Making shortcut for [!rom_name!] with [%SelectedEmulator%].
			echo @echo off> "!RomDir!\!rom_name!.bat"
			echo start "" "!EmulatorExe!" !LaunchOptions! >> "!RomDir!\!rom_name!.bat"
			echo exit>> "!RomDir!\!rom_name!.bat"
		)
	)
)
goto :eof

:DONE
echo All batch files created.
choice /c:12 /n /m "Do you want to delete this script? [1 - Yes, 2 - No]: "
if errorlevel 2 goto :NoDel
if errorlevel 1 goto :Del

:Del
del "%~f0"
goto :NoDel

:NoDel
endlocal
exit