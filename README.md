# 📚 Sistema Distribuido de Préstamo de Libros — Primera Entrega

---

## 🚀 Descripción General

El sistema implementa una versión distribuida del **préstamo de libros en la Biblioteca de la Universidad Ada Lovelace**.  
Cada operación (devolución, renovación o préstamo) se maneja por procesos independientes que se comunican mediante **ZeroMQ** bajo los patrones de **Request/Reply** y **Publish/Subscribe**.

### 🧩 Procesos Principales
| Proceso | Descripción |
|----------|--------------|
| **Proceso Solicitante (PS)** | Lee peticiones desde un archivo (`peticiones.txt`) y las envía al Gestor de Carga. |
| **Gestor de Carga (GC)** | Recibe solicitudes de los PS, responde a cada una y publica mensajes a los actores. |
| **Actores** | Escuchan los tópicos correspondientes (`devolucion`, `renovacion`) y procesan las operaciones. |
| **Libro (modelo)** | Representa los libros en la biblioteca (ya implementado por el grupo). |

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


