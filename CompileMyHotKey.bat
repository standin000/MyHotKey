REM tasklist
taskkill /F /IM MyHotKey.exe
taskkill /F /IM AutoHotkeyU64.exe
REM D:\Tools\AutoHotKey\Compiler\Ahk2Exe.exe /in myhotkey.ahk /out D:\Tools\MyHotkey\MyHotKey.exe
D:\Tools\AutoHotKey\Compiler\Ahk2Exe.exe /bin "D:\Tools\AutoHotKey\Compiler\Unicode 64-bit.bin" /in myhotkey.ahk /out D:\Tools\MyHotkey\MyHotKey.exe 

start /min D:\Tools\MyHotkey\MyHotKey.exe
