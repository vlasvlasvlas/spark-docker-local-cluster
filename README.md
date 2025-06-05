# ⚡ Spark Local Cluster (tipo Databricks) con Docker + Jupyter + `.env`

**¿Para qué sirve?**  

Levanta en tu máquina un _mini-Databricks_ totalmente **offline** para:  Probar notebooks y ETLs PySpark localmente • Reproducir cargas distribuidas sin coste • Enseñar Spark sin depender de la nube

---

## 🚀 ¿Qué incluye?
| Componente | Función |
|------------|---------|
| `spark-master` | Nodo coordinador Spark |
| `spark-worker` | Réplicas configurables |
| `jupyter` | Notebook conectado al cluster |
| `run.sh` | Build + up + ejecución de jobs |
| `.env` | “Cluster spec” al estilo Databricks |

---

## 📂 Árbol del proyecto

```plaintext
.
├── docker-compose.yml
├── .env
├── run.sh
└── spark/
    ├── Dockerfile
    ├── entrypoint.sh
    ├── spark-defaults.conf
    └── jobs/
        └── ejemplo.py
```

---

## 🛠️ Requisitos
* Docker + Docker Compose  
* Linux/macOS/WSL2  
* Python ≥3.8 (solo si quieres añadir scripts nuevos)

---

## ⚙️ Configuración rápida (`.env`)
```env
# Workers
SPARK_WORKER_INSTANCES=2
SPARK_WORKER_MEMORY=8g
SPARK_WORKER_CORES=4

# Driver
SPARK_DRIVER_MEMORY=4g

# Ejecutores
SPARK_EXECUTOR_INSTANCES=4
SPARK_EXECUTOR_MEMORY=4g
SPARK_EXECUTOR_CORES=2

# Finos
SPARK_NETWORK_TIMEOUT=120s
SPARK_TASK_MAX_FAILURES=4
SPARK_DEFAULT_PARALLELISM=8

# Event-log desactivado (evita Kerberos)
SPARK_EVENT_LOG_ENABLED=false

# Deploy mode
SPARK_DEPLOY_MODE=client
```

⸻

▶️ Uso básico

chmod +x run.sh        # 1) dar permisos la primera vez
./run.sh               # 2) levantar cluster + ejemplo.py
./run.sh mi_job.py     # 3) lanzar otro script en spark/jobs/


⸻

🔄 Reiniciar o limpiar el cluster
```
# Apagar y eliminar volúmenes
docker compose down -v

# (Opcional) limpiar cache de imágenes buildkit
docker builder prune -af

# Volver a levantar todo
./run.sh
```

⸻

🌐 Interfaces útiles
- Spark UI → http://localhost:8080
- Jupyter  → http://localhost:8888

⸻

🧪 Script de ejemplo (spark/jobs/ejemplo.py)

```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("EjemploDocker").getOrCreate()
df = spark.range(1_000_000).withColumnRenamed("id", "numero")
df.selectExpr("numero", "numero * 2 AS doble").show(10)
spark.stop()
```

⸻

📋 Ver logs de los contenedores

# Spark Master
docker logs spark-master

# Primer Worker
docker logs sparks-cluster-spark-worker-1

# Jupyter
docker logs spark-jupyter

# Seguir logs en tiempo real
docker logs -f spark-master


⸻

🏗️ Detalles internos

- Ivy fix → /opt/bitnami/.ivy2 es el repo Maven local; sin acceso a /root.

- Event-log off (spark.eventLog.enabled=false) → no requiere Kerberos.

- Usuario seguro → Contenedor corre como uid 1001 (HOME=/opt/bitnami).

- Parámetros dinámicos → Memorias/núcleos vienen de .env vía run.sh --conf.

⸻

✅ Ventajas
- Cero cloud · Reproducible · Extensible · Perfecto para docencia y POC.

⸻

📜 Licencia

MIT – Úsalo, modifícalo y compártelo.
