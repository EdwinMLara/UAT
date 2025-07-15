echo @echo off
set "CLONE_DIR=%USERPROFILE%\Documents\UAT"
echo title Servidor de Desarrollo UAT
echo echo Iniciando servidor UAT... Por favor, no cierres esta ventana.
echo =================================
echo        Dinamometro UAT
echo    Creado por INSOEL and UNAM
echo =================================
echo cd /d "%CLONE_DIR%"
npm start
start chrome http://localhost:3000/
