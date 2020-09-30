@echo off
setlocal enabledelayedexpansion
cd %~dp0

set max_retry_num=1

echo Start 1st stage
call bootstrap_1st.bat
if %errorlevel% neq 0 (
  echo 1st stage failed.
  exit /b 1
)

echo Start 2nd stage
copy bootstrap_2nd.sh msys64\tmp

set retry_num=0
:retry
call msys64\msys2_shell.cmd -mingw64 -defterm -no-start -c /tmp/bootstrap_2nd.sh
if %errorlevel% neq 0 (
rem msys2 is automatically killed when msys2-runtime is upgraded, so retry is needed.
  echo 2nd stage failed.
  if %retry_num% leq %max_retry_num% (
     echo Retry 2nd stage.
     set /a retry_num=retry_num+1
     goto :retry
  ) else (
     exit /b 1
  )
)
del msys64\tmp\bootstrap_2nd.sh

echo Bootstrap finished.
echo You can close this window and launch msys64/msys2.exe to use NNSVS from MSYS2 userland,
echo or you can continue to use cmd.exe if you have expertise in NNSVS and Windows.

@echo on
