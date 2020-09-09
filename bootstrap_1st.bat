setlocal enabledelayedexpansion
cd %~dp0

rem WinPython and MSYS2 uri and checksum settings.
set winpython_exe_uri=https://github.com/winpython/winpython/releases/download/3.0.20200808/Winpython64-3.8.5.0dot.exe
set winpython_exe_md5=5f0c7164cd1dcd2128b626cea1871c71

set msys2_archive_uri=https://sourceforge.net/projects/msys2/files/Base/x86_64/msys2-base-x86_64-20200903.tar.xz
set msys2_archive_md5=b55e3a3419f2a16abaa21a422eb7fd03

rem Miscellaneous files and directories settings.
set tmp_dir=%~dp0tmp

set winpython_exe_path=%tmp_dir%\winpython.exe
set winpython_python_relative_path=WPy64-3850\python-3.8.5.amd64

set msys2_archive_path=%tmp_dir%\msys2.tar.xz

set dest_root=%~dp0
set msys2_dest_dir=%dest_root%

set timeout_sec=60

rem main routine
rem Remove old directories
call :check_directory %tmp_dir%
rem call :check_directory %dest_root%

rem Download, check and extract WinPython.
echo Download WinPython official archive.
call :download %winpython_exe_uri% %winpython_exe_path%

echo Check WinPython MD5.
call :validate_checksum %winpython_exe_path% MD5 %winpython_exe_md5%
if %errorlevel% equ 0 (
  echo WinPython MD5 checksum validated.
  echo Extract WinPython.
  %winpython_exe_path% -C%tmp_dir% -y
) else (
  echo ERROR: WinPython MD5 checksum mismatch.
  exit /b 1
)

rem Download and extract MSYS2
echo Download MSYS2 official archive.
call :download %msys2_archive_uri% %msys2_archive_path% 

echo Check MSYS2 MD5.
call :validate_checksum %msys2_archive_path% MD5 %msys2_archive_md5%
if %errorlevel% equ 0 (
  echo MSYS2 MD5 checksum validated.
  echo Extract MSYS2.
  %tmp_dir%\%winpython_python_relative_path%\python.exe util\extract_tar_xz.py %msys2_archive_path% %msys2_dest_dir%
) else (
  echo ERROR: MSYS2 MD5 checksum mismatch.
  exit /b 1
)

echo Move python to /opt of MSYS2.
move %tmp_dir%\%winpython_python_relative_path% %msys2_dest_dir%\msys64\opt\python

echo Initialize MSYS2.
start /wait %msys2_dest_dir%\msys64\msys2.exe nul

echo Wait %timeout_sec% seconds to finish initialization of MSYS2.
timeout /t %timeout_sec% /nobreak >nul

echo Add /opt/python to PATH.
echo export PATH=/opt/python:/opt/python/Scripts:$PATH >> msys64\etc\bash.bashrc

exit /b 0

rem sub-routines
:check_directory
rem :check_directory dir
setlocal
if exist %1 (
  echo Old %1 found. Do you want to delete it?
  rmdir /s %1
)
if not exist %1 (
  mkdir %1
)
exit /b 0

:download
rem :download uri dest_path
setlocal
if exist %2 (
  echo %2 already exists. Skipping.
  exit /b 1
) else ( 
  curl -L -o %2 %1
  exit /b 0
)

:validate_checksum
rem :validate_checksum file algorithm hash
setlocal
set command=certutil -hashfile %1 %2
set num=0
for /f "usebackq" %%a in (`%command%`) do (
  set result[!num!]=%%a
  set /a num=num+1
)
set downloaded_python_hash=%result[1]%

if %downloaded_python_hash%==%3 (
  exit /b 0
) else (
  exit /b 1
)
