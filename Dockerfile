FROM gcr.io/spark-operator/spark:v3.0.0-gcs-prometheus

RUN chmod 644 /prometheus/jmx_prometheus_javaagent-0.11.0.jar
