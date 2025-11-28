# 📚 Sistema Distribuido de Préstamo de Libros - Segunda Entrega

## 🎯 Biblioteca Distribuida

---

## 📋 Descripción General

Sistema distribuido para gestión de préstamos de libros implementado en **Java** con **ZeroMQ**, operando en dos sedes con tolerancia a fallas y réplicas de base de datos.

### ✨ Características Principales

- ✅ **Dos sedes operativas** (SEDE1 y SEDE2)
- ✅ **Tolerancia a fallas** del Gestor de Almacenamiento y BD
- ✅ **Réplicas primaria y secundaria** con sincronización asíncrona
- ✅ **Patrones de comunicación**:
  - Pub/Sub para devoluciones y renovaciones (asíncrono)
  - Push/Pull para préstamos (síncrono)
  - Request/Reply entre componentes

---

## 🏗️ Arquitectura del Sistema

### Componentes por Sede

```
SEDE 1 (Máquina 1)                    SEDE 2 (Máquina 2)
├── Gestor de Carga                   ├── Gestor de Carga
├── Gestor de Almacenamiento (P)      ├── Gestor de Almacenamiento (S)
├── BD Primaria                       ├── BD Primaria
├── BD Secundaria                     ├── BD Secundaria
├── Actor Préstamo                    ├── Actor Préstamo
├── Actor Devolución                  ├── Actor Devolución
└── Actor Renovación                  └── Actor Renovación

CLIENTES (Máquina 3)
└── Procesos Solicitantes (PS1, PS2, PS3, ...)
```

### Puertos Utilizados

| Componente | Puerto | Protocolo | Descripción |
|------------|--------|-----------|-------------|
| Gestor Carga → PS | 5555 | REP | Recibe solicitudes |
| Gestor Carga → Actores | 5556 | PUB | Publica devoluciones/renovaciones |
| Gestor Carga → Actor Préstamo | 5557 | PUSH | Envía tareas de préstamo |
| Gestor Almacenamiento | 5558 | REP | Operaciones de BD |
| Health Check | 5559 | REP | Verificación de estado |
| Replicación | 5560 | PUB | Sincronización de réplicas |

---

## 🚀 Instalación y Configuración

### Requisitos

- **Java 21** (JDK 21+)
- **Maven 3.8+**
- **ZeroMQ** (jeromq 0.5.3)
- **3 computadores** en red o 3 máquinas virtuales

### Compilación

```bash
# Clonar repositorio
git clone <url-repositorio>
cd proyecto_distribuidos2530

# Compilar proyecto
mvn clean package

# Verificar compilación
test_local.bat
(ESTE EJECUTA LAS 6 TERMINALES NECESARIAS AUTOMATICAMENTE)
```

### Configuración de Red
- 1️⃣ Máquina 1 (10.43.103.47) → ProcesoSolicitante
- 2️⃣ Máquina 2 (10.43.101.241) → GestorCarga  
- 3️⃣ Máquina 3 (10.43.102.104) → ActorDevolucion
- 4️⃣ Máquina 4 (10.43.103.107) → ActorRenovacion
---
### Opción 2: Ejecución Manual

#### Paso 1: Iniciar Gestores de Almacenamiento

**Máquina 1 (SEDE1 - Primario):**
```bash
java -cp target/proyecto_distribuidos2530-1.0-SNAPSHOT.jar \
  com.example.proyecto_distribuidos2530.almacenamiento.GestorAlmcto \
  SEDE1 true SEDE2 192.168.1.101
```

**Máquina 2 (SEDE2 - Secundario):**
```bash
java -cp target/proyecto_distribuidos2530-1.0-SNAPSHOT.jar \
  com.example.proyecto_distribuidos2530.almacenamiento.GestorAlmcto \
  SEDE2 false SEDE1 192.168.1.100
```

#### Paso 2: Iniciar Gestores de Carga

**Máquina 1:**
```bash
java -cp target/proyecto_distribuidos2530-1.0-SNAPSHOT.jar \
  com.example.proyecto_distribuidos2530.carga.GestorCarga SEDE1
```

**Máquina 2:**
```bash
java -cp target/proyecto_distribuidos2530-1.0-SNAPSHOT.jar \
  com.example.proyecto_distribuidos2530.carga.GestorCarga SEDE2
```

#### Paso 3: Iniciar Actores

**En ambas máquinas:**
```bash
# Actor Préstamo
java -cp target/proyecto_distribuidos2530-1.0-SNAPSHOT.jar \
  com.example.proyecto_distribuidos2530.actores.ActorPrestamo \
  SEDE1 localhost 192.168.1.101

# Actor Devolución
java -cp target/proyecto_distribuidos2530-1.0-SNAPSHOT.jar \
  com.example.proyecto_distribuidos2530.actores.ActorDevolucion

# Actor Renovación
java -cp target/proyecto_distribuidos2530-1.0-SNAPSHOT.jar \
  com.example.proyecto_distribuidos2530.actores.ActorRenovacion
```

#### Paso 4: Iniciar Procesos Solicitantes

**Máquina 3:**
```bash
# PS para SEDE1
java -cp target/proyecto_distribuidos2530-1.0-SNAPSHOT.jar \
  com.example.proyecto_distribuidos2530.solicitante.ProcesoSolicitante \
  PS1 SEDE1 192.168.1.100 peticiones_ps1.txt

# PS para SEDE2
java -cp target/proyecto_distribuidos2530-1.0-SNAPSHOT.jar \
  com.example.proyecto_distribuidos2530.solicitante.ProcesoSolicitante \
  PS2 SEDE2 192.168.1.101 peticiones_ps2.txt
```

---

## 📁 Estructura del Proyecto

```
proyecto_distribuidos2530/
├── src/main/java/com/example/proyecto_distribuidos2530/
│   ├── actores/
│   │   ├── ActorDevolucion.java
│   │   ├── ActorPrestamo.java
│   │   └── ActorRenovacion.java
│   ├── almacenamiento/
│   │   └── GestorAlmcto.java
│   ├── basedatos/
│   │   └── Database.java
│   ├── carga/
│   │   └── GestorCarga.java
│   ├── modelo/
│   │   └── Libro.java
│   └── solicitante/
│       └── ProcesoSolicitante.java
├── src/main/resources/
│   ├── peticiones.txt
│   └── libros.csv
├── pom.xml
└── README.md
```

---

## ⚙️ Tecnologías utilizadas

- **Java 17+**
- **ZeroMQ (librería jeromq)**
- **Maven** como herramienta de construcción
- **Arquitectura distribuida** con procesos independientes

---

## 🔌 Patrones de Comunicación ZeroMQ

El sistema utiliza **tres patrones de mensajería** de ZeroMQ para diferentes tipos de comunicación:

### 1. **REQ/REP (Request-Reply)**
- **Propósito**: Comunicación síncrona entre el Proceso Solicitante y el Gestor de Carga
- **Flujo**: 
  - `ProcesoSolicitante` envía solicitudes (REQ) → `GestorCarga` responde (REP)
- **Puerto**: `5555`
- **Uso**: Envío de peticiones de préstamo, devolución y renovación

### 2. **PUB/SUB (Publish-Subscribe)**
- **Propósito**: Difusión de eventos a múltiples actores interesados
- **Flujo**:
  - `GestorCarga` publica (PUB) → `ActorDevolucion` y `ActorRenovacion` se suscriben (SUB)
- **Puerto**: `5556`
- **Tópicos**:
  - `devolucion`: Procesado por `ActorDevolucion`
  - `renovacion`: Procesado por `ActorRenovacion`

### 3. **PUSH/PULL (Pipeline)**
- **Propósito**: Distribución de tareas de préstamo de forma asíncrona
- **Flujo**:
  - `GestorCarga` empuja tareas (PUSH) → `ActorPrestamo` recibe tareas (PULL)
- **Puerto**: `5557`
- **Ventaja**: Permite distribuir la carga de trabajo entre múltiples workers si es necesario

---


## 🔧 Formato de Peticiones

Archivo `peticiones.txt` (formato):
```
PRESTAMO|LIB123|U100
DEVOLUCION|LIB456|U101
RENOVACION|LIB789|U102
```

Campos:
- **OPERACION**: PRESTAMO, DEVOLUCION, RENOVACION
- **CODIGO_LIBRO**: Identificador del libro (ej: LIB1, LIB2, ...)
- **USUARIO**: ID del usuario (ej: U100, U101, ...)

---

## 📈 Interpretación de Resultados

### Métricas Clave

1. **Tiempo de respuesta**: Menor es mejor
2. **Desviación estándar**: Menor indica más consistencia
3. **Solicitudes procesadas**: Mayor es mejor
4. **Tasa de éxito**: Debe ser cercana al 100%

## 👥 Equipo de Desarrollo

- **Integrante 1**: Violeta Fajardo
- **Integrante 2**: Samuel Osorio
- **Integrante 3**: Alejandro Castelblanco
- **Integrante 4**: Andrés Raba
- **Integrante 5**: Angy Bautista

---

## 📚 Referencias

- [ZeroMQ Guide](https://zguide.zeromq.org/)
- [Documentación del proyecto](Biblioteca2025-30.pdf)
- [Maven Central - JeroMQ](https://mvnrepository.com/artifact/org.zeromq/jeromq)

---

## 📄 Licencia

Proyecto académico - Pontificia Universidad Javeriana - 2025-30
