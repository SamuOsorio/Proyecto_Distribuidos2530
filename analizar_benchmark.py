#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Analizador de Benchmark: Serial vs Multihilo
Genera las tablas de comparación de rendimiento
"""

import csv
import os
from statistics import mean, stdev
from pathlib import Path

def analizar_csv(archivo):
    """Lee un CSV y calcula estadísticas"""
    if not os.path.exists(archivo):
        return None
    
    tiempos = []
    total_solicitudes = 0
    total_fallidas = 0
    
    with open(archivo, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
        # Buscar la sección de resumen
        for i, line in enumerate(lines):
            if line.startswith('Proceso,Sede'):
                # La siguiente línea tiene los datos del resumen
                if i + 1 < len(lines):
                    data_line = lines[i + 1].strip()
                    parts = data_line.split(',')
                    if len(parts) >= 4:
                        try:
                            total_solicitudes += int(parts[2])
                            total_fallidas += int(parts[3])
                        except ValueError:
                            pass
            
            # Buscar la sección de detalles
            elif line.startswith('Indice,Tiempo_Respuesta_ms'):
                # Leer todos los tiempos de respuesta
                for j in range(i + 1, len(lines)):
                    detail_line = lines[j].strip()
                    if not detail_line or detail_line.startswith('Proceso,Sede'):
                        break
                    try:
                        parts = detail_line.split(',')
                        if len(parts) >= 2:
                            tiempo = float(parts[1])
                            tiempos.append(tiempo)
                    except ValueError:
                        continue
    
    if not tiempos:
        return None
    
    return {
        'promedio': mean(tiempos),
        'desviacion': stdev(tiempos) if len(tiempos) > 1 else 0,
        'total': total_solicitudes if total_solicitudes > 0 else len(tiempos),
        'exitosos': total_solicitudes - total_fallidas if total_solicitudes > 0 else len(tiempos),
        'fallidos': total_fallidas,
        'min': min(tiempos),
        'max': max(tiempos)
    }

def main():
    print("=" * 70)
    print("📊 ANÁLISIS DE BENCHMARK: SERIAL VS MULTIHILO")
    print("=" * 70)
    print()
    
    # Directorio de benchmarks
    benchmarks_dir = Path("benchmarks")
    
    if not benchmarks_dir.exists():
        print("❌ Error: No existe la carpeta 'benchmarks/'")
        print("   Primero ejecuta: .\\test_benchmark.bat")
        return
    
    # Analizar cada configuración
    configuraciones = [
        ('4', 'serial_4ps_metricas.csv', 'multihilo_4ps_metricas.csv'),
        ('6', 'serial_6ps_metricas.csv', 'multihilo_6ps_metricas.csv'),
        ('10', 'serial_10ps_metricas.csv', 'multihilo_10ps_metricas.csv')
    ]
    
    resultados = []
    
    print("📁 Archivos encontrados:")
    for ps, serial_file, multihilo_file in configuraciones:
        serial_path = benchmarks_dir / serial_file
        multihilo_path = benchmarks_dir / multihilo_file
        
        serial = analizar_csv(serial_path)
        multihilo = analizar_csv(multihilo_path)
        
        print(f"   • {ps} PS: ", end="")
        if serial:
            print(f"Serial ✓ ({serial['total']} ops) ", end="")
        else:
            print("Serial ✗ ", end="")
        
        if multihilo:
            print(f"Multihilo ✓ ({multihilo['total']} ops)")
        else:
            print("Multihilo ✗")
        
        resultados.append((ps, serial, multihilo))
    
    print()
    print("=" * 70)
    print("TABLA 1: TIEMPO DE RESPUESTA PROMEDIO (ms)")
    print("=" * 70)
    print()
    print(f"{'# PS':<8} {'Serial':<12} {'Desv.':<10} {'Multihilo':<12} {'Desv.':<10} {'Mejora':<10}")
    print("-" * 70)
    
    for ps, serial, multihilo in resultados:
        if serial and multihilo:
            mejora = ((serial['promedio'] - multihilo['promedio']) / serial['promedio']) * 100
            print(f"{ps:<8} {serial['promedio']:>10.2f}  {serial['desviacion']:>8.2f}  "
                  f"{multihilo['promedio']:>10.2f}  {multihilo['desviacion']:>8.2f}  {mejora:>8.1f}%")
        else:
            print(f"{ps:<8} {'N/A':<12} {'N/A':<10} {'N/A':<12} {'N/A':<10} {'N/A':<10}")
    
    print()
    print("=" * 70)
    print("TABLA 2: SOLICITUDES PROCESADAS EN 2 MINUTOS")
    print("=" * 70)
    print()
    print(f"{'# PS':<8} {'Serial':<15} {'Multihilo':<15} {'Incremento':<12}")
    print("-" * 70)
    
    for ps, serial, multihilo in resultados:
        if serial and multihilo:
            incremento = ((multihilo['total'] - serial['total']) / serial['total']) * 100
            print(f"{ps:<8} {serial['total']:>13,}  {multihilo['total']:>13,}  {incremento:>10.1f}%")
        else:
            print(f"{ps:<8} {'N/A':<15} {'N/A':<15} {'N/A':<12}")
    
    print()
    print("=" * 70)
    print("📈 DETALLES ADICIONALES")
    print("=" * 70)
    print()
    
    for ps, serial, multihilo in resultados:
        print(f"🔹 {ps} Procesos Solicitantes por sede:")
        
        if serial:
            print(f"   Serial:")
            print(f"      • Tiempo promedio: {serial['promedio']:.2f} ms")
            print(f"      • Rango: {serial['min']:.2f} - {serial['max']:.2f} ms")
            print(f"      • Operaciones: {serial['total']:,} ({serial['exitosos']} exitosas, {serial['fallidos']} fallidas)")
            print(f"      • Throughput: {serial['total'] / 120:.2f} ops/seg")
        
        if multihilo:
            print(f"   Multihilo:")
            print(f"      • Tiempo promedio: {multihilo['promedio']:.2f} ms")
            print(f"      • Rango: {multihilo['min']:.2f} - {multihilo['max']:.2f} ms")
            print(f"      • Operaciones: {multihilo['total']:,} ({multihilo['exitosos']} exitosas, {multihilo['fallidos']} fallidas)")
            print(f"      • Throughput: {multihilo['total'] / 120:.2f} ops/seg")
        
        if serial and multihilo:
            mejora_throughput = ((multihilo['total'] / 120) / (serial['total'] / 120) - 1) * 100
            print(f"   📊 Mejora en throughput: +{mejora_throughput:.1f}%")
        
        print()
    
    # Guardar resumen
    resumen_path = benchmarks_dir / "resumen_analisis.txt"
    with open(resumen_path, 'w', encoding='utf-8') as f:
        f.write("=" * 70 + "\n")
        f.write("RESUMEN DE ANÁLISIS: SERIAL VS MULTIHILO\n")
        f.write("=" * 70 + "\n\n")
        
        f.write("TABLA 1: TIEMPO DE RESPUESTA PROMEDIO (ms)\n")
        f.write("-" * 70 + "\n")
        f.write(f"{'# PS':<8} {'Serial':<12} {'Desv.':<10} {'Multihilo':<12} {'Desv.':<10} {'Mejora':<10}\n")
        f.write("-" * 70 + "\n")
        
        for ps, serial, multihilo in resultados:
            if serial and multihilo:
                mejora = ((serial['promedio'] - multihilo['promedio']) / serial['promedio']) * 100
                f.write(f"{ps:<8} {serial['promedio']:>10.2f}  {serial['desviacion']:>8.2f}  "
                       f"{multihilo['promedio']:>10.2f}  {multihilo['desviacion']:>8.2f}  {mejora:>8.1f}%\n")
        
        f.write("\n\nTABLA 2: SOLICITUDES PROCESADAS EN 2 MINUTOS\n")
        f.write("-" * 70 + "\n")
        f.write(f"{'# PS':<8} {'Serial':<15} {'Multihilo':<15} {'Incremento':<12}\n")
        f.write("-" * 70 + "\n")
        
        for ps, serial, multihilo in resultados:
            if serial and multihilo:
                incremento = ((multihilo['total'] - serial['total']) / serial['total']) * 100
                f.write(f"{ps:<8} {serial['total']:>13,}  {multihilo['total']:>13,}  {incremento:>10.1f}%\n")
    
    print("=" * 70)
    print(f"✅ Resumen guardado en: {resumen_path}")
    print("=" * 70)
    print()
    print("📋 PARA TU INFORME:")
    print("   1. Copia las tablas de arriba a tu documento")
    print("   2. Explica por qué multihilo es más rápido (procesamiento paralelo)")
    print("   3. Analiza cómo escala con más PS (4 → 6 → 10)")
    print("   4. Menciona las limitaciones (overhead de threads, sincronización)")
    print()

if __name__ == "__main__":
    main()
