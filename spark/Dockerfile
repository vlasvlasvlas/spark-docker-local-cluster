FROM bitnami/spark:latest

##############################################################################
# 1) Crear repositorio Ivy dentro del HOME real del usuario 1001             #
##############################################################################
USER root
RUN mkdir -p /opt/bitnami/.ivy2/local
USER 1001

##############################################################################
# 2) Copiar entrypoint y configuración                                       #
##############################################################################
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY spark-defaults.conf /opt/bitnami/spark/conf/

ENTRYPOINT ["/entrypoint.sh"]