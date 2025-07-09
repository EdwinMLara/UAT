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
::  Version: 3.1 (con chequeo de admin)
::
::  Descripcion:
::  Este script automatiza la preparacion de un entorno de desarrollo:
::  1. Verifica e instala el gestor de paquetes Chocolatey.
::  2. Verifica e instala Node.js v18.x.
::  3. Verifica e instala Git para Windows.
::  4. Instala las dependencias para node-gyp (Python, Build Tools) y node-gyp mismo.
::  5. Clona o actualiza el repositorio Git especificado.
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
echo [PASO 1 de 5] Verificando la instalacion de Chocolatey...
echo.
where choco >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo --- Chocolatey no esta instalado. Se procedera con la instalacion.
    echo [TAREA] Instalando Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] La instalacion de Chocolatey ha fallado.
        goto :end_error
    )
    echo --- La ventana puede requerir refrescar el entorno. Se recomienda reiniciar la terminal si los siguientes pasos fallan.
    echo --- Anadiendo Chocolatey al PATH para esta sesion...
    set "PATH=%ALLUSERSPROFILE%\chocolatey\bin;!PATH!"
) else (
    echo --- ¡Excelente! Chocolatey ya esta instalado.
)
echo.


:: =============================================================================
::  PASO 2: NODE.JS
:: =============================================================================
echo [PASO 2 de 5] Verificando la instalacion de Node.js v18...
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
        goto :end_error
    )
    echo --- Descarga completada.
    echo.
    echo [TAREA] Instalando Node.js v18... (esto puede tardar unos minutos)
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
echo [PASO 3 de 5] Verificando la instalacion de Git...
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
        goto :end_error
    )
    echo --- Descarga completada.
    echo.
    echo [TAREA] Iniciando la instalacion de Git... (esto puede tardar varios minutos)
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
echo [PASO 4 de 5] Instalando prerequisitos para node-gyp...
echo.
echo --- Este paso puede tardar bastante, ya que instala Python y las Herramientas de Compilacion de VS.
echo.

echo [TAREA] Instalando Python con Chocolatey...
choco install python -y --force
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Fallo la instalacion de Python con Chocolatey.
    goto :end_error
)
echo.

echo [TAREA] Instalando VS Build Tools 2022 con Chocolatey...
choco install visualstudio2022buildtools -y --force
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Fallo la instalacion de VS Build Tools.
    goto :end_error
)
echo.

echo [TAREA] Instalando node-gyp globalmente...
call npm install -g node-gyp
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Fallo la instalacion de node-gyp.
    goto :end_error
)
echo --- node-gyp y sus dependencias se han instalado correctamente.
echo.

:: =============================================================================
::  PASO 5: REPOSITORIO
:: =============================================================================
echo [PASO 5 de 5] Gestionando el repositorio Git...
echo.

:: Refrescar el PATH para asegurar que 'git' este disponible en esta sesion
echo --- Actualizando la ruta (PATH) para la sesion actual...
for /f "tokens=*" %%a in ('where git') do set "GIT_PATH_DIR=%%~dpa"
if defined GIT_PATH_DIR (
    set "PATH=!GIT_PATH_DIR!;!PATH!"
    echo --- Git anadido al PATH de la sesion.
) else (
    echo [ADVERTENCIA] No se pudo encontrar Git.exe para agregarlo al PATH.
    echo La clonacion del repositorio podria fallar.
)
echo.

if exist "%CLONE_DIR%" (
    echo --- La carpeta del repositorio ya existe en: "%CLONE_DIR%"
    choice /c YNP /m "Deseas (Y) Borrar y clonar de nuevo, (N) Actualizar (pull), o (P) Omitir"
    if errorlevel 3 (
        echo --- Omitiendo operacion del repositorio.
        goto :summary
    ) else if errorlevel 2 (
        echo --- Actualizando el repositorio con 'git pull'...
        cd /d "%CLONE_DIR%"
        git pull
        cd ..
    ) else if errorlevel 1 (
        echo --- Eliminando el repositorio existente...
        rmdir /s /q "%CLONE_DIR%"
        echo --- Clonando el repositorio de nuevo...
        git clone "%GIT_REPO_URL%" "%CLONE_DIR%"
    )
) else (
    echo --- La carpeta del repositorio no existe.
    echo --- Clonando el repositorio en: "%CLONE_DIR%"
    git clone "%GIT_REPO_URL%" "%CLONE_DIR%"
)

if %errorlevel% neq 0 (
    echo [ERROR] Fallo la operacion con el repositorio Git.
    goto :end_error
)
echo.
echo --- Operacion con el repositorio completada con exito.
echo.


:: =============================================================================
::  RESUMEN FINAL
:: =============================================================================
:summary
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

:end_error
echo.
echo [FALLO] El script se detuvo debido a un error.
echo.

:end
endlocal
pause
exit /b