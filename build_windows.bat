@echo off

if not exist .build mkdir .build

where /q cl.exe || call vcvars64.bat || goto :error

cl.exe -Fe.build\OutbreakProtocol.exe^
 -nologo -W4 -WX -Z7 -Oi -EHa- -GR- -GS- -Gs0x10000000 -DOP_DEBUG=1^
 main.cpp kernel32.lib user32.lib ws2_32.lib dwmapi.lib winmm.lib d3d11.lib^
 -link -incremental:no -nodefaultlib -subsystem:windows^
 -stack:0x10000000,0x10000000 -heap:0,0 || goto :error

if "%1"=="run" ( start .build\OutbreakProtocol.exe
) else if "%1"=="debug" ( remedybg .build\OutbreakProtocol.exe
) else if not "%1"=="" ( echo command '%1' not found & goto :error )

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
