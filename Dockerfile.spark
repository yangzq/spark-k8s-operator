FROM gcr.io/spark-operator/spark:v3.0.0-gcs-prometheus

ARG spark_uid=185

USER root

RUN chmod go+r /prometheus/jmx_prometheus_javaagent-0.11.0.jar

ENV SPARK_HOME /opt/spark
WORKDIR /opt/spark/work-dir
ENTRYPOINT [ "/opt/entrypoint.sh" ]

USER ${spark_uid}
