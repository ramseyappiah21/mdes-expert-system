@echo off
setlocal
cd /d "%~dp0"

set "SWIPL=swipl"
where swipl >nul 2>&1
if errorlevel 1 (
    if exist "%ProgramFiles%\swipl\bin\swipl.exe" (
        set "SWIPL=%ProgramFiles%\swipl\bin\swipl.exe"
    ) else if exist "%LOCALAPPDATA%\swipl\bin\swipl.exe" (
        set "SWIPL=%LOCALAPPDATA%\swipl\bin\swipl.exe"
    ) else (
        echo SWI-Prolog was not found on PATH.
        echo Install it from https://www.swi-prolog.org/Download.html
        exit /b 1
    )
)

"%SWIPL%" -q -s tests/test_suite.pl
