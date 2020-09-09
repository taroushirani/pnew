@echo off
setlocal enabledelayedexpansion
cd %~dp0

echo Start 1st stage
call bootstrap_1st.bat
if %errorlevel% neq 0 (
  echo 1st stage failed.
  exit /b 1
)

echo Start 2nd stage
msys64\usr\bin\bash.exe bootstrap_2nd.sh
if %errorlevel% neq 0 (
  echo 2nd stage failed.
  exit /b 1
)

echo Bootstrap finished.

@echo on
