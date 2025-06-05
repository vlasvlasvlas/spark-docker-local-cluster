#!/bin/bash
set -e

export HOME="/opt/bitnami"                     # HOME real del usuario 1001
mkdir -p "$HOME/.ivy2/local"                  # por si el volumen se recrea

if [[ "$SPARK_MODE" == "master" ]]; then
  /opt/bitnami/spark/bin/spark-class org.apache.spark.deploy.master.Master \
    --host "$SPARK_MASTER_HOST"
else
  /opt/bitnami/spark/bin/spark-class org.apache.spark.deploy.worker.Worker \
    --cores "$SPARK_WORKER_CORES" \
    --memory "$SPARK_WORKER_MEMORY" \
    "$SPARK_MASTER"
fi