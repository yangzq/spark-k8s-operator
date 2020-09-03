FROM mr3project/hive3:1.1

USER root

CMD ["rm", "/opt/mr3-run/mr3/mr3lib/mr3-tez-1.0-assembly.jar"]

COPY mr3-tez-1.0-assembly.jar /opt/mr3-run/mr3/mr3lib/

WORKDIR /opt/mr3-run

