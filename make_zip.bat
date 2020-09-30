setlocal enabledelayedexpansion
cd %~dp0

set date_str=%date:~0,4%%date:~5,2%%date:~8,2%

tar -a -c -v -f pnew_%date_str%.zip --exclude msys64/home msys64
