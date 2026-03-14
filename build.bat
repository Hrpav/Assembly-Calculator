@echo off
setlocal


:: logic.asm  main.asm  ui.asm  utils.asm  window.asm

if exist build rmdir /s /q build
mkdir build
mkdir build\bin

if not exist build\bin\sounds mkdir build\bin\sounds
if exist sounds\err.wav copy /Y sounds\err.wav build\bin\sounds\ >nul
if exist sounds\ding.wav copy /Y sounds\ding.wav build\bin\sounds\ >nul

echo =================================
echo  Building x64 Assembly Calculator
echo =================================

echo [1/2] Assembling...
ml64 /nologo /c /Fo build\ src\main.asm src\logic.asm src\ui.asm src\utils.asm
if %errorlevel% neq 0 goto error

echo [2/2] Linking...
link /nologo /SUBSYSTEM:WINDOWS /ENTRY:main /OUT:build\bin\calculator.exe build\*.obj user32.lib kernel32.lib gdi32.lib winmm.lib
if %errorlevel% neq 0 goto error

echo [3/3] Finalizing artifacts...
if not exist build\bin\fonts mkdir build\bin\fonts
if exist fonts\VGAOEM.FON copy /Y fonts\VGAOEM.FON build\bin\fonts\ >nul
if exist calculator.exe.manifest copy /Y calculator.exe.manifest build\bin\ >nul

echo.
echo =================================
echo  BUILD SUCCESSFUL
echo =================================
echo Run: build\bin\calculator.exe
goto :eof

:error
echo.
echo !!!!!!! BUILD FAILED !!!!!!!
exit /b 1
