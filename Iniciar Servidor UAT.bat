@echo off
title Servidor de Desarrollo UAT
echo Iniciando servidor UAT...

:: Da unos segundos para que el servidor se levante
:: Abre Google Chrome en el puerto 3000
start chrome http://localhost:3000

:: Inicia el servidor. Este es el ultimo comando.
cd /d "C:\Users\isain\Documents\UAT"
npm start
