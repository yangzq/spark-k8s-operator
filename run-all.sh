#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

/usr/sbin/init

DIR="$(cd "$(dirname "$0")" && pwd)"

chown -R hive:hive /opt/mr3-run
chown -R ranger:ranger /opt/mr3-run/ranger
chown -R ats:ats /opt/mr3-run/ats

#yum localinstall -y http://repo.mysql.com/mysql-community-release-el6-7.noarch.rpm
#yum install -y mysql-community-server
#yum install -y wget

#echo "HOSTNAME=\"$(hostname -f)\"" > /etc/sysconfig/network
systemctl start mysqld

mysqladmin -uroot password passwd
mysql -uroot -ppasswd -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'passwd';"
mysql -uroot -ppasswd -e "FLUSH PRIVILEGES;"

#wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.17.tar.gz
#tar -zxf mysql-connector-java-8.0.17.tar.gz mysql-connector-java-8.0.17/mysql-connector-java-8.0.17.jar
#cp mysql-connector-java-8.0.17/mysql-connector-java-8.0.17.jar $DIR/lib/mysql-connector.jar


echo "starting Ranger and Solr"

$DIR/ranger/start-solr.sh > $DIR/solr.out 2>&1 &

while [[ "$(ss -lntp | grep -v grep | grep -c ":6083")" = "0" ]] ; do
  sleep 10
done
sleep 10

curl -u solr:SolrRocks http://localhost:6083/solr/admin/authentication -H 'Content-type:application/json' \
  -d '{"set-user": {"hive": "hive", "rangeradmin": "rangeradmin"}}'

$DIR/ranger/start-ranger.sh > $DIR/ranger.out 2>&1 &

while [[ "$(ss -lntp | grep -v grep | grep -c ":6080")" = "0" ]] ; do
  sleep 10
done
sleep 10

curl -iv -u admin:rangeradmin1 -H "Content-Type: application/json" -X POST -d \
  '{ "configs": { "password": "hive", "username": "hive",
  "jdbc.driverClassName": "org.apache.hive.jdbc.HiveDriver", "jdbc.url": "jdbc:hive2://localhost:9852",
  "policy.download.auth.users": "hive" }, "isEnabled": true, "name": "DOCKER_hive", "type": "hive",
  "version": 1 }' http://localhost:6080/service/public/v2/api/service
echo ""

echo "starting ATS"
export ATS_SECRET_KEY=$(cat /proc/sys/kernel/random/uuid)
echo $ATS_SECRET_KEY
echo $ATS_SECRET_KEY > $DIR/ats-secret-key
sudo -E -u ats bash -c '/opt/mr3-run/ats/timeline-service.sh' > $DIR/ats.out 2>&1 &

while [[ "$(ss -lntp | grep -v grep | grep -c ":8188")" = "0" ]] ; do
  sleep 10
done

echo "starting Metastore and HiveServer2"
sudo -E -u hive bash -c '/opt/mr3-run/hive/metastore-service.sh start --init-schema --localprocess' > $DIR/metastore.out 2>&1 &
sudo -E -u hive bash -c '/opt/mr3-run/hive/hiveserver2-service.sh start --localprocess' > $DIR/hiveserver2.out 2>&1 &


