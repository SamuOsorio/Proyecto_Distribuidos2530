@echo off
REM Script para pruebas de benchmark: Serial vs Multihilo
REM Prueba con 4, 6 y 10 Procesos Solicitantes

setlocal enabledelayedexpansion

set JAR=target\proyecto_distribuidos2530-1.0-SNAPSHOT-jar-with-dependencies.jar
set DURACION=120000

REM 120000 ms = 2 minutos

if not exist "%JAR%" (
    echo ERROR: Compilar primero con: mvn clean package -DskipTests
    pause
    exit /b 1
)

if not exist benchmarks mkdir benchmarks

echo ======================================================
echo   BENCHMARK: Serial vs Multihilo
echo   Pruebas con 4, 6 y 10 Procesos Solicitantes
echo ======================================================
echo.

REM =====================================================
REM PRUEBA 1: SERIAL CON 4 PS
REM =====================================================
echo.
echo [1/6] Iniciando prueba SERIAL con 4 PS (2 minutos)...
echo ======================================================

taskkill /F /IM java.exe >nul 2>&1
timeout /t 2 >nul

start "GA-Serial" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.almacenamiento.GestorAlmcto SEDE1 true false"
timeout /t 3 >nul

start "GC" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.carga.GestorCarga SEDE1"
timeout /t 2 >nul

start "AD" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorDevolucion SEDE1 localhost localhost"
start "AR" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorRenovacion SEDE1 localhost localhost"
start "AP" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorPrestamo SEDE1 localhost localhost"
timeout /t 3 >nul

REM Iniciar 4 Procesos Solicitantes
for /L %%i in (1,1,4) do (
    start "PS%%i" cmd /c "java -cp %JAR% com.example.proyecto_distribuidos2530.solicitante.ProcesoSolicitante PS%%i SEDE1 localhost src\main\resources\peticiones.txt %DURACION%"
)

echo Esperando 2 minutos + 10 segundos de margen...
timeout /t 130 >nul

REM Copiar métricas
copy metricas_PS*.csv benchmarks\serial_4ps_metricas.csv >nul 2>&1

echo [1/6] Completado - SERIAL 4 PS
taskkill /F /IM java.exe >nul 2>&1
timeout /t 5 >nul

REM =====================================================
REM PRUEBA 2: MULTIHILO CON 4 PS
REM =====================================================
echo.
echo [2/6] Iniciando prueba MULTIHILO con 4 PS (2 minutos)...
echo ======================================================

start "GA-Multi" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.almacenamiento.GestorAlmcto SEDE1 true true"
timeout /t 3 >nul

start "GC" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.carga.GestorCarga SEDE1"
timeout /t 2 >nul

start "AD" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorDevolucion SEDE1 localhost localhost"
start "AR" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorRenovacion SEDE1 localhost localhost"
start "AP" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorPrestamo SEDE1 localhost localhost"
timeout /t 3 >nul

for /L %%i in (1,1,4) do (
    start "PS%%i" cmd /c "java -cp %JAR% com.example.proyecto_distribuidos2530.solicitante.ProcesoSolicitante PS%%i SEDE1 localhost src\main\resources\peticiones.txt %DURACION%"
)

timeout /t 130 >nul
copy metricas_PS*.csv benchmarks\multihilo_4ps_metricas.csv >nul 2>&1

echo [2/6] Completado - MULTIHILO 4 PS
taskkill /F /IM java.exe >nul 2>&1
timeout /t 5 >nul

REM =====================================================
REM PRUEBA 3: SERIAL CON 6 PS
REM =====================================================
echo.
echo [3/6] Iniciando prueba SERIAL con 6 PS (2 minutos)...
echo ======================================================

start "GA-Serial" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.almacenamiento.GestorAlmcto SEDE1 true false"
timeout /t 3 >nul

start "GC" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.carga.GestorCarga SEDE1"
timeout /t 2 >nul

start "AD" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorDevolucion SEDE1 localhost localhost"
start "AR" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorRenovacion SEDE1 localhost localhost"
start "AP" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorPrestamo SEDE1 localhost localhost"
timeout /t 3 >nul

for /L %%i in (1,1,6) do (
    start "PS%%i" cmd /c "java -cp %JAR% com.example.proyecto_distribuidos2530.solicitante.ProcesoSolicitante PS%%i SEDE1 localhost src\main\resources\peticiones.txt %DURACION%"
)

timeout /t 130 >nul
copy metricas_PS*.csv benchmarks\serial_6ps_metricas.csv >nul 2>&1

echo [3/6] Completado - SERIAL 6 PS
taskkill /F /IM java.exe >nul 2>&1
timeout /t 5 >nul

REM =====================================================
REM PRUEBA 4: MULTIHILO CON 6 PS
REM =====================================================
echo.
echo [4/6] Iniciando prueba MULTIHILO con 6 PS (2 minutos)...
echo ======================================================

start "GA-Multi" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.almacenamiento.GestorAlmcto SEDE1 true true"
timeout /t 3 >nul

start "GC" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.carga.GestorCarga SEDE1"
timeout /t 2 >nul

start "AD" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorDevolucion SEDE1 localhost localhost"
start "AR" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorRenovacion SEDE1 localhost localhost"
start "AP" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorPrestamo SEDE1 localhost localhost"
timeout /t 3 >nul

for /L %%i in (1,1,6) do (
    start "PS%%i" cmd /c "java -cp %JAR% com.example.proyecto_distribuidos2530.solicitante.ProcesoSolicitante PS%%i SEDE1 localhost src\main\resources\peticiones.txt %DURACION%"
)

timeout /t 130 >nul
copy metricas_PS*.csv benchmarks\multihilo_6ps_metricas.csv >nul 2>&1

echo [4/6] Completado - MULTIHILO 6 PS
taskkill /F /IM java.exe >nul 2>&1
timeout /t 5 >nul

REM =====================================================
REM PRUEBA 5: SERIAL CON 10 PS
REM =====================================================
echo.
echo [5/6] Iniciando prueba SERIAL con 10 PS (2 minutos)...
echo ======================================================

start "GA-Serial" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.almacenamiento.GestorAlmcto SEDE1 true false"
timeout /t 3 >nul

start "GC" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.carga.GestorCarga SEDE1"
timeout /t 2 >nul

start "AD" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorDevolucion SEDE1 localhost localhost"
start "AR" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorRenovacion SEDE1 localhost localhost"
start "AP" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorPrestamo SEDE1 localhost localhost"
timeout /t 3 >nul

for /L %%i in (1,1,10) do (
    start "PS%%i" cmd /c "java -cp %JAR% com.example.proyecto_distribuidos2530.solicitante.ProcesoSolicitante PS%%i SEDE1 localhost src\main\resources\peticiones.txt %DURACION%"
)

timeout /t 130 >nul
copy metricas_PS*.csv benchmarks\serial_10ps_metricas.csv >nul 2>&1

echo [5/6] Completado - SERIAL 10 PS
taskkill /F /IM java.exe >nul 2>&1
timeout /t 5 >nul

REM =====================================================
REM PRUEBA 6: MULTIHILO CON 10 PS
REM =====================================================
echo.
echo [6/6] Iniciando prueba MULTIHILO con 10 PS (2 minutos)...
echo ======================================================

start "GA-Multi" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.almacenamiento.GestorAlmcto SEDE1 true true"
timeout /t 3 >nul

start "GC" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.carga.GestorCarga SEDE1"
timeout /t 2 >nul

start "AD" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorDevolucion SEDE1 localhost localhost"
start "AR" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorRenovacion SEDE1 localhost localhost"
start "AP" cmd /k "java -cp %JAR% com.example.proyecto_distribuidos2530.actores.ActorPrestamo SEDE1 localhost localhost"
timeout /t 3 >nul

for /L %%i in (1,1,10) do (
    start "PS%%i" cmd /c "java -cp %JAR% com.example.proyecto_distribuidos2530.solicitante.ProcesoSolicitante PS%%i SEDE1 localhost src\main\resources\peticiones.txt %DURACION%"
)

timeout /t 130 >nul
copy metricas_PS*.csv benchmarks\multihilo_10ps_metricas.csv >nul 2>&1

echo [6/6] Completado - MULTIHILO 10 PS
taskkill /F /IM java.exe >nul 2>&1

echo.
echo ======================================================
echo   TODAS LAS PRUEBAS COMPLETADAS
echo ======================================================
echo.
echo Resultados guardados en carpeta: benchmarks\
echo.
echo Archivos generados:
dir /b benchmarks\*.csv
echo.
echo Ejecuta: python analizar_benchmark.py
echo Para generar el resumen de las tablas.
echo.

pause
