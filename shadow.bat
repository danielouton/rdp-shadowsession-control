@echo off
CLS
ECHO.
ECHO ===============================
ECHO Ejecutando Shell Administrador
ECHO ===============================

:init
	setlocal DisableDelayedExpansion
	set cmdInvoke=1
	set winSysFolder=System32
	set "batchPath=%~0"
	for %%k in (%0) do set batchName=%%~nk
	set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
	setlocal EnableDelayedExpansion

:checkPrivileges
	NET FILE 1>NUL 2>NUL
	if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
	if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
	ECHO.
	ECHO **************************************
	ECHO Invocando UAC para escalar privilegios
	ECHO **************************************

	ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
	ECHO args = "ELEV " >> "%vbsGetPrivileges%"
	ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
	ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
	ECHO Next >> "%vbsGetPrivileges%"

	if '%cmdInvoke%'=='1' goto InvokeCmd 

	ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
	goto ExecElevation
	
:InvokeCmd
	ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
	ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
	"%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
	exit /B

:gotPrivileges
	setlocal & cd /d %~dp0
	if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)
	cls
	ECHO *******************************
	ECHO Control Remoto de Sesiones RDP
	ECHO *******************************
	qwinsta.exe
	echo.
	set /p uid=Introduzca ID de sesion:
	echo.
	echo ==============================================================================
	echo Seleccione modo de acceso a la sesion:
	echo  1)  Acceso total con consentimiento del usuario 
	echo  2)  Acceso total sin consentimiento del usuario
	echo  3)  Solo visualizar con consentimiento del usuario 
	echo  4)  Solo visualizar sin consentimiento del usuario 
	echo ------------------------------------------------------------------------------
	echo.

	SET /p modoacceso= ^> Seleccione una opcion [1-4]:
	if "%modoacceso%"=="1" goto modo1
	if "%modoacceso%"=="2" goto modo2
	if "%modoacceso%"=="3" goto modo3
	if "%modoacceso%"=="4" goto modo4
	
	:modo1
	start Mstsc.exe /shadow:%uid% /control
	goto salir
	:modo2
	start Mstsc.exe /shadow:%uid% /control /noConsentPrompt
	goto salir
	:modo3
	start Mstsc.exe /shadow:%uid%
	goto salir
	:modo4
	start Mstsc.exe /shadow:%uid% /noConsentPrompt
	goto salir
	
:salir
@cls&exit