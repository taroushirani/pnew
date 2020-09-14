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
copy bootstrap_2nd.sh msys64\tmp
call msys64\msys2_shell.cmd -mingw64 -defterm -no-start -c /tmp/bootstrap_2nd.sh
if %errorlevel% neq 0 (
  echo 2nd stage failed.
  exit /b 1
)
del msys64\tmp\bootstrap_2nd.sh

echo Bootstrap finished.
echo You can close this window and launch msys64/msys2.exe to use NNSVS from Un*x userland,
echo or you can continue to use cmd.exe if have expertise in NNSVS and Windows.

@echo on
