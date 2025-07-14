@echo off

:: =============================================================================
::  VERIFICACION DE PERMISOS DE ADMINISTRADOR
:: =============================================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Se requieren privilegios de Administrador para continuar.
    echo.
    echo Por favor, cierra esta ventana, haz clic derecho sobre el archivo
    echo y selecciona "Ejecutar como administrador".
    echo.
    pause
    exit /b
)

setlocal EnableDelayedExpansion
:: =============================================================================
::  Entorno de Desarrollo UAT
::  Autor: INSOEL
::  Version: 6.2 (corregido y con apertura de navegador)
::
::  Descripcion:
::  Este script automatiza la preparacion de un entorno de desarrollo:
::  1. Verifica e instala Chocolatey.
::  2. Verifica e instala Node.js v18.x.
::  3. Verifica e instala Git.
::  4. Instala las dependencias para node-gyp.
::  5. Clona/actualiza el repositorio e instala dependencias.
::  6. Inicia el servidor de desarrollo y abre el navegador.
::
:: =============================================================================

:: --- Configuracion ---
title Asistente de Entorno de Desarrollo

:: URLs y nombres de archivo
set NODE_INSTALLER_URL="https://nodejs.org/dist/v18.20.2/node-v18.20.2-x64.msi"
set NODE_INSTALLER_NAME="node-installer.msi"
set GIT_INSTALLER_URL="https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe"
set GIT_INSTALLER_NAME="Git-Installer.exe"
set GIT_REPO_URL="https://github.com/EdwinMLara/UAT.git"
set CLONE_DIR=%USERPROFILE%\Downloads\UAT


:: --- Inicio del Script ---
echo =================================================================
echo.
echo      Asistente de Preparacion de Entorno de Desarrollo
echo.
echo =================================================================
echo.
echo Este script verificara e instalara las herramientas necesarias.
echo Presiona una tecla para comenzar...
pause >nul
echo.

:: =============================================================================
::  PASO 1: CHOCOLATEY
:: =============================================================================
echo [PASO 1 de 6] Verificando la instalacion de Chocolatey...
echo.
where choco >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo --- Chocolatey no esta instalado. Se procedera con la instalacion.
    echo [TAREA] Instalando Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] La instalacion de Chocolatey ha fallado.
        pause
    )
    echo --- Anadiendo Chocolatey al PATH para esta sesion...
    set "PATH=%ALLUSERSPROFILE%\chocolatey\bin;!PATH!"
) else (
    echo --- ¡Excelente! Chocolatey ya esta instalado.
)
echo.


:: =============================================================================
::  PASO 2: NODE.JS
:: =============================================================================
echo [PASO 2 de 6] Verificando la instalacion de Node.js v18...
echo.

set "install_node=0"
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo --- Node.js no esta instalado. Se procedera con la instalacion.
    set "install_node=1"
) else (
    for /f "tokens=*" %%a in ('node --version') do set "node_version=%%a"
    echo --- Se encontro Node.js version: !node_version!
    echo !node_version! | findstr "v18." >nul
    if %errorlevel% neq 0 (
        echo --- La version no es la v18.x. Se procedera con la instalacion.
        set "install_node=1"
    ) else (
        echo --- ¡Excelente! La version correcta de Node.js ya esta instalada.
    )
)
echo.

if "%install_node%" == "1" (
    echo [TAREA] Descargando el instalador de Node.js v18...
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%NODE_INSTALLER_URL%', '%NODE_INSTALLER_NAME%')"
    if not exist %NODE_INSTALLER_NAME% (
        echo [ERROR] La descarga de Node.js ha fallado. Revisa tu conexion.
        pause
    )
    echo --- Descarga completada.
    echo.
    echo [TAREA] Instalando Node.js v18...
    msiexec /i %NODE_INSTALLER_NAME% /qn
    echo --- Instalacion finalizada.
    echo.
    echo [TAREA] Limpiando el instalador...
    del %NODE_INSTALLER_NAME%
    echo --- Limpieza completada.
    echo.
)


:: =============================================================================
::  PASO 3: GIT
:: =============================================================================
echo [PASO 3 de 6] Verificando la instalacion de Git...
echo.

where git >nul 2>nul
if %ERRORLEVEL% == 0 (
    echo --- ¡Buenas noticias! Git ya se encuentra instalado.
    for /f "tokens=*" %%a in ('git --version') do set "git_version=%%a"
    echo --- Version instalada: !git_version!
    echo.
) else (
    echo --- No se encontro una instalacion de Git.
    echo --- Se procedera con la descarga e instalacion.
    echo.
    echo [TAREA] Descargando el instalador de Git...
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%GIT_INSTALLER_URL%', '%GIT_INSTALLER_NAME%')"
    if not exist %GIT_INSTALLER_NAME% (
        echo [ERROR] La descarga de Git ha fallado. Revisa tu conexion.
        pause
    )
    echo --- Descarga completada.
    echo.
    echo [TAREA] Iniciando la instalacion de Git...
    start "" /wait "%GIT_INSTALLER_NAME%" /VERYSILENT /NORESTART
    echo --- Instalacion finalizada.
    echo.
    echo [TAREA] Limpiando el instalador...
    del %GIT_INSTALLER_NAME%
    echo --- Limpieza completada.
    echo.
)

:: =============================================================================
::  PASO 4: NODE-GYP Y DEPENDENCIAS
:: =============================================================================
echo [PASO 4 de 6] Instalando prerequisitos para node-gyp...
echo.
echo --- Este paso puede tardar bastante, ya que instala Python y las Herramientas de Compilacion de VS.
echo.

echo [TAREA] Instalando Python con Chocolatey...
choco install python -y --force
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Fallo la instalacion de Python con Chocolatey.
    pause
)
echo.

echo [TAREA] Instalando VS Build Tools 2022 con Chocolatey...
choco install visualstudio2022buildtools -y --force
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Fallo la instalacion de VS Build Tools.
    pause
)
echo.

echo [TAREA] Instalando node-gyp globalmente...
call npm install -g node-gyp
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Fallo la instalacion de node-gyp.
    pause
)
echo --- node-gyp y sus dependencias se han instalado correctamente.
echo.

:: =============================================================================
::  PASO 5: REPOSITORIO E INSTALACION DE DEPENDENCIAS
:: =============================================================================
echo [PASO 5 de 6] Gestionando el repositorio e instalando dependencias...
echo.
set "repo_ok=0"

:: Refrescar el PATH para asegurar que 'git' este disponible en esta sesion
echo --- Actualizando la ruta (PATH) para la sesion actual...
for /f "tokens=*" %%a in ('where git') do set "GIT_PATH_DIR=%%~dpa"
if defined GIT_PATH_DIR (
    set "PATH=!GIT_PATH_DIR!;!PATH!"
) else (
    echo [ADVERTENCIA] No se pudo encontrar Git.exe para agregarlo al PATH.
)
echo.

if exist "%CLONE_DIR%" (
    echo --- La carpeta del repositorio ya existe en: "%CLONE_DIR%"
    choice /c YNP /m "Deseas (Y) Borrar y clonar, (N) Actualizar (pull), o (P) Omitir"
    if errorlevel 3 (
        echo --- Omitiendo operacion del repositorio.
        set "repo_ok=0"
    ) else if errorlevel 2 (
        echo --- Actualizando el repositorio con 'git pull'...
        cd /d "%CLONE_DIR%"
        git pull
        cd ..
        call :install_dependencies
    ) else if errorlevel 1 (
        echo --- Eliminando el repositorio existente...
        rmdir /s /q "%CLONE_DIR%"
        echo --- Clonando el repositorio de nuevo...
        git clone "%GIT_REPO_URL%" "%CLONE_DIR%"
        call :install_dependencies
    )
) else (
    echo --- La carpeta del repositorio no existe.
    echo --- Clonando el repositorio en: "%CLONE_DIR%"
    git clone "%GIT_REPO_URL%" "%CLONE_DIR%"
    call :install_dependencies
)

if %errorlevel% neq 0 (
    echo [ERROR] Fallo la operacion con el repositorio.
    pause
)
echo.
echo --- Operacion con el repositorio completada con exito.
echo.
goto :summary

:: =============================================================================
::  FUNCIONES Y MANEJO DE ERRORES
:: =============================================================================

:install_dependencies
    echo.
    echo [TAREA] Instalando dependencias del proyecto (npm install)...
    cd /d "%CLONE_DIR%"
    if exist package.json (
        npm install
        if %ERRORLEVEL% neq 0 (
            echo [ERROR] Fallo la instalacion de dependencias del proyecto.
            pause
            exit /b 1
        )
        echo --- Dependencias instaladas correctamente.
        set "repo_ok=1"
        goto :start_server
    ) else (
        echo [ADVERTENCIA] No se encontro package.json en el repositorio. No se instalaron dependencias.
        set "repo_ok=0"
        pause
    )
    goto :eof

:: =============================================================================
::  PASO 6: INICIAR SERVIDOR DE DESARROLLO
:: =============================================================================
:start_server
if "%repo_ok%" == "1" (
    echo [PASO 6 de 6] Iniciando el servidor de desarrollo...
    echo.
    echo --- Se abrira una NUEVA VENTANA de consola con el servidor del proyecto.
    echo --- Puedes cerrar esta ventana principal una vez que la nueva aparezca.
    echo.
    cd /d "%CLONE_DIR%"
    start "Servidor de Desarrollo UAT" cmd /k npm start

    echo --- Abriendo localhost en tu navegador...
    timeout /t 5 /nobreak >nul
    start http://localhost:3000
) else (
    echo [INFO] Se omitio el inicio del servidor porque no se realizo una operacion de clonado o actualizacion.
)

:: =============================================================================
::  RESUMEN FINAL
:: =============================================================================
:summary
echo.
echo =================================================================
echo.
echo      Proceso finalizado. Resumen del entorno:
echo.
echo =================================================================
echo.
echo [Chocolatey]
where choco >nul 2>nul && choco --version || echo   No instalado.
echo.
echo [Node.js]
where node >nul 2>nul && node --version || echo   No instalado.
echo.
echo [Git]
where git >nul 2>nul && git --version || echo   No instalado.
echo.
echo [node-gyp]
where node-gyp >nul 2>nul && call npm list -g node-gyp | findstr "node-gyp@" || echo   No instalado.
echo.
echo [Repositorio]
if exist "%CLONE_DIR%" (
    echo   Ubicacion: %CLONE_DIR%
) else (
    echo   No se realizo ninguna operacion con el repositorio.
)
echo.
echo =================================================================
echo.
echo ¡Entorno listo!
goto :end

:end
endlocal
pause
exit /b