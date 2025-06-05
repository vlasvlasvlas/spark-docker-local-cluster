#!/usr/bin/env bash
set -e  # abortar ante el primer error

# ─────────────────────────────────────────────────────────────
# 0. Construir imagenes (opcional)
# ─────────────────────────────────────────────────────────────
# Si quieres forzar la reconstrucción de las imágenes, descomenta la siguiente línea:
docker compose build --no-cache  

# ─────────────────────────────────────────────────────────────
# 0. COLORES (ANSI) para mensajes
# ─────────────────────────────────────────────────────────────
GREEN="\033[1;32m"; CYAN="\033[1;36m"; RED="\033[1;31m"; NC="\033[0m"

# ─────────────────────────────────────────────────────────────
# 1. Job a ejecutar  (por defecto: ejemplo.py)
# ─────────────────────────────────────────────────────────────
DEFAULT_JOB="ejemplo.py"
JOB_SCRIPT=${1:-$DEFAULT_JOB}
JOB_PATH="./spark/jobs/$JOB_SCRIPT"

# ─────────────────────────────────────────────────────────────
# 2. Validaciones previas
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}🔍 Verificando requisitos previos...${NC}"

# .env presente
if [[ ! -f .env ]]; then
  echo -e "${RED}❌ Falta el archivo .env${NC}"; exit 1
fi
# shellcheck disable=SC1091
source .env

# Docker Compose instalado
if ! command -v docker compose &>/dev/null; then
  echo -e "${RED}❌ Docker Compose no está instalado${NC}"; exit 1
fi

# job existe
if [[ ! -f "$JOB_PATH" ]]; then
  echo -e "${RED}❌ No se encontró '$JOB_PATH'${NC}"; exit 1
fi

# ─────────────────────────────────────────────────────────────
# 3. (Re)Construir y levantar cluster
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}🔄 Paso 1: build del cluster...${NC}"
docker compose build --no-cache

echo -e "${CYAN}🚀 Paso 2: subiendo servicios...${NC}"
docker compose down -v &>/dev/null || true
docker compose up -d

# Espera breve
echo -e "${CYAN}⏳ Esperando 10 s a que el cluster se estabilice...${NC}"
sleep 10

echo -e "${GREEN}✅ Contenedores activos:${NC}"
docker ps --filter name=spark

# ─────────────────────────────────────────────────────────────
# 4. Ejecutar job
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}🧪 Ejecutando '$JOB_SCRIPT' en el cluster...${NC}"

docker exec spark-master spark-submit \
  --master spark://spark-master:7077               \
  --deploy-mode "$SPARK_DEPLOY_MODE"              \
  --conf spark.driver.memory="$SPARK_DRIVER_MEMORY" \
  --conf spark.executor.memory="$SPARK_EXECUTOR_MEMORY" \
  --conf spark.executor.instances="$SPARK_EXECUTOR_INSTANCES" \
  --conf spark.executor.cores="$SPARK_EXECUTOR_CORES" \
  --conf spark.network.timeout="$SPARK_NETWORK_TIMEOUT" \
  --conf spark.task.maxFailures="$SPARK_TASK_MAX_FAILURES" \
  --conf spark.default.parallelism="$SPARK_DEFAULT_PARALLELISM" \
  --conf spark.eventLog.enabled="$SPARK_EVENT_LOG_ENABLED" \
  --conf spark.eventLog.dir="$SPARK_EVENT_LOG_DIR" \
  --conf spark.eventLog.enabled=false \
  /opt/spark/jobs/"$JOB_SCRIPT"

# ─────────────────────────────────────────────────────────────
# 5. Fin
# ─────────────────────────────────────────────────────────────
echo -e "\n${GREEN}🎉 Job completado.${NC}"
echo -e "🔗 Spark UI  → http://localhost:8080"
echo -e "🔗 Jupyter   → http://localhost:8888\n"