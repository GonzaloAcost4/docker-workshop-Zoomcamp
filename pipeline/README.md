# NYC Taxi Data Pipeline

Pipeline de ingesta de datos del dataset NYC Yellow Taxi hacia PostgreSQL, construido con Python, pandas y SQLAlchemy. Desarrollado como parte del [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp).

Este README cubre todo lo que está en tu carpeta pipeline/:

Estructura — descripción de cada archivo del proyecto
Setup — uv sync --dev y docker-compose up con tabla de credenciales
3 formas de ingestar — script directo, Docker contenedorizado, y Jupyter
Tabla de parámetros — todos los --options del CLI con sus defaults
Dataset — de dónde vienen los datos y cómo se forma la URL
Dependencias — qué hace cada paquete
pgcli — cómo conectarse desde terminal
Limpieza — comandos Docker con advertencia sobre prune

---

## Estructura del proyecto

```
pipeline/
├── ingest_data.py        # Script principal de ingesta (CLI con Click)
├── Notebook.ipynb        # Notebook de exploración y prototipado
├── pipeline.py           # Pipeline de ejemplo con salida Parquet
├── main.py               # Punto de entrada básico del proyecto
├── Dockerfile            # Imagen Docker para contenedorizar la ingesta
├── docker-compose.yaml   # Orquestación de PostgreSQL + pgAdmin
├── pyproject.toml        # Dependencias del proyecto (uv)
├── uv.lock               # Lock file reproducible
└── .python-version       # Versión de Python requerida (3.13)
```

---

## Requisitos

- [Python 3.13](https://www.python.org/)
- [uv](https://docs.astral.sh/uv/) — gestor de paquetes y entornos virtuales
- [Docker](https://www.docker.com/) — para levantar PostgreSQL y pgAdmin

---

## Setup inicial

### 1. Instalar dependencias

```bash
uv sync --dev
```

Esto crea el entorno virtual en `.venv/` e instala todas las dependencias declaradas en `pyproject.toml`, incluyendo las de desarrollo (Jupyter, pgcli).

### 2. Levantar la base de datos

```bash
docker-compose up
```

Levanta dos servicios:

| Servicio | URL | Credenciales |
|---|---|---|
| PostgreSQL | `localhost:5432` | user: `root` / pass: `root` / db: `ny_taxi` |
| pgAdmin | `http://localhost:8085` | email: `admin@admin.com` / pass: `root` |

---

## Ingesta de datos

### Opción A — Ejecutar el script directamente

```bash
uv run python ingest_data.py \
  --pg-user=root \
  --pg-pass=root \
  --pg-host=localhost \
  --pg-port=5432 \
  --pg-db=ny_taxi \
  --target-table=yellow_taxi_trips \
  --year=2021 \
  --month=1 \
  --chunksize=100000
```

Todos los parámetros tienen valores por defecto, por lo que también podés correrlo sin argumentos:

```bash
uv run python ingest_data.py
```

### Opción B — Usar Docker

Primero construís la imagen:

```bash
docker build -t taxi_ingest:v001 .
```

Luego la ejecutás en la misma red que PostgreSQL:

```bash
docker run -it --rm \
  --network=pipeline_default \
  taxi_ingest:v001 \
  --pg-host=pgdatabase \
  --pg-db=ny_taxi \
  --target-table=yellow_taxi_trips \
  --year=2021 \
  --month=1
```

> **Nota:** Cuando usás `docker-compose`, la red se llama `pipeline_default` (nombre de la carpeta + `_default`). Confirmalo con `docker network ls`.

### Opción C — Jupyter Notebook

```bash
uv run jupyter notebook
```

Abre `Notebook.ipynb` para explorar los datos paso a paso antes de correr el script completo.

---

## Parámetros del script

| Parámetro | Tipo | Default | Descripción |
|---|---|---|---|
| `--pg-user` | str | `root` | Usuario de PostgreSQL |
| `--pg-pass` | str | `root` | Contraseña de PostgreSQL |
| `--pg-host` | str | `localhost` | Host de PostgreSQL |
| `--pg-port` | str | `5432` | Puerto de PostgreSQL |
| `--pg-db` | str | `ny_taxi` | Nombre de la base de datos |
| `--year` | int | `2021` | Año del dataset a descargar |
| `--month` | int | `1` | Mes del dataset (1–12) |
| `--target-table` | str | `yellow_taxi_data` | Tabla destino en PostgreSQL |
| `--chunksize` | int | `100000` | Filas por chunk al leer el CSV |

---

## Dataset

Los datos provienen de [NYC TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page), almacenados en el repositorio de DataTalksClub:

```
https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/
yellow_tripdata_{year}-{month:02d}.csv.gz
```

El script descarga el archivo comprimido directamente desde la URL y lo procesa en chunks de `chunksize` filas para evitar problemas de memoria con archivos grandes (~1.5 millones de filas por mes).

---

## Dependencias principales

| Paquete | Uso |
|---|---|
| `pandas` | Lectura del CSV y transformación de datos |
| `sqlalchemy` | Conexión y escritura en PostgreSQL |
| `psycopg2-binary` | Driver de PostgreSQL para SQLAlchemy |
| `click` | Interfaz de línea de comandos (CLI) |
| `tqdm` | Barra de progreso durante la ingesta |
| `pyarrow` | Soporte para archivos Parquet |

Dependencias de desarrollo: `jupyter`, `pgcli`

---

## Conectarse a la base de datos (terminal)

```bash
uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
```

Cuando pida contraseña, ingresá `root`.

---

## Limpieza de recursos Docker

```bash
# Detener servicios
docker-compose down

# Detener y eliminar volúmenes (borra los datos)
docker-compose down -v

# Eliminar todo (imágenes, volúmenes, redes)
docker system prune -a --volumes
```

> ⚠️ `docker system prune -a --volumes` elimina **todos** los recursos de Docker en tu sistema, no solo los de este proyecto.
