setlocal enabledelayedexpansion
cd %~dp0

tar -a -c -v -f pnew.zip --exclude msys64\home msys64
