@echo off

SET application=my.local.website
SET uniqueId=123
SET appPath=src\my.local.website

::setup application pool
%WINDIR%\system32\inetsrv\AppCmd.exe list apppool "%application%"
IF %ERRORLEVEL% EQU 0 (
	%WINDIR%\system32\inetsrv\AppCmd.exe delete apppool "%application%"
)
%WINDIR%\system32\inetsrv\AppCmd.exe add apppool /name:"%application%" /managedRuntimeVersion:v4.0 /managedPipelineMode:Integrated
IF %ERRORLEVEL% NEQ 0 (
	GOTO End
)

::setup website
%WINDIR%\system32\inetsrv\AppCmd.exe list site "%application%"
IF %ERRORLEVEL% EQU 0 (
	%WINDIR%\system32\inetsrv\AppCmd.exe delete site "%application%"
)

SET root=%cd%
%WINDIR%\system32\inetsrv\AppCmd.exe add site /site.name:"%application%" /id:%uniqueId% /bindings:http://%application%:80 /physicalPath:%root%\%appPath%
IF %ERRORLEVEL% NEQ 0 (
	GOTO End
)

::assign application pool to website
%WINDIR%\system32\inetsrv\AppCmd.exe set app "%application%/" /applicationPool:%application%
IF %ERRORLEVEL% NEQ 0 (
	GOTO End
)

::append entry to hosts file
find /c /i "127.0.0.1 %application% " C:\Windows\System32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 (
	echo # >> %WINDIR%\System32\drivers\etc\hosts
	echo 127.0.0.1 %application% >> %WINDIR%\System32\drivers\etc\hosts
)

:End