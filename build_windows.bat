@echo off

if not exist .build mkdir .build

where /q cl || call vcvars64.bat || goto :error

cl -wd4324 -Fe.build\OutbreakProtocol.exe -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x10000000^
 main_windows.cpp kernel32.lib user32.lib gdi32.lib opengl32.lib ws2_32.lib dwmapi.lib winmm.lib d3d11.lib dxgi.lib d3dcompiler.lib^
 -link -incremental:no -nodefaultlib -subsystem:windows -stack:0x10000000,0x10000000 -heap:0,0 || goto :error

if "%1"=="run" ( start .build\OutbreakProtocol.exe
) else if "%1"=="debug" ( start remedybg .build\OutbreakProtocol.exe
) else if "%1"=="doc" ( start qrenderdoc .build\OutbreakProtocol.exe
) else if not "%1"=="" ( echo command '%1' not found & goto :error )

:end
del *.obj 2>nul
exit /b
:error
call :end
exit /b 1
