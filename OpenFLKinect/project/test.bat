@echo off
g++ ./common/ExternalInterface.cpp -shared -o ../ndll/Windows/openflkinect.ndll -I./include
REM haxe -cp src -main Main -cpp bin
REM cd bin
REM Main.exe
pause

