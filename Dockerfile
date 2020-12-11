FROM mr3project/hivemr3-all:1.2

USER root

RUN yum localinstall -y http://repo.mysql.com/mysql-community-release-el6-7.noarch.rpm \
    && yum install -y mysql-community-server \
    && echo "HOSTNAME=\"$(hostname -f)\"" > /etc/sysconfig/network \
    && yum clean all \
    && rm -f /opt/mr3-run/run-all.sh \
    && rm -f /opt/mr3-run/init.sh \
    && rm -rf /opt/mr3-run/conf \
    && rm -rf /opt/mr3-run/key \
    && rm -f /opt/mr3-run/env.sh

ENV JAVA_HOME /etc/alternatives/jre
ENV PATH="/etc/alternatives/jre/bin:${PATH}"

COPY run-all.sh /opt/mr3-run/run-all.sh
COPY init.sh /opt/mr3-run/init.sh
COPY mysql-connector-java-8.0.17.jar /opt/mr3-run/lib/mysql-connector.jar

RUN chown hive:hive /opt/mr3-run/run-all.sh \
    && chown hive:hive /opt/mr3-run/init.sh \
    && chown hive:hive /opt/mr3-run/lib/mysql-connector.jar \
    && chmod +x /opt/mr3-run/run-all.sh \
    && chmod +x /opt/mr3-run/init.sh

WORKDIR /opt/mr3-run

ENTRYPOINT ["/opt/mr3-run/init.sh"]

