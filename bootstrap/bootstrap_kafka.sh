#!/bin/bash

# NOTE:  After starting a new Kafka node, make sure that the private IP
# has access to port 2181 on Zookeeper, and that the private IP has port
# 9092 open (or whatever Kafka port(s) you're using)

cd

sudo yum -y update

###################################################################################
# install Kafka
###################################################################################

# wget http://apache.mirrors.lucidnetworks.net/kafka/0.10.1.0/kafka_2.11-0.10.1.0.tgz
wget http://mirrors.advancedhosters.com/apache/kafka/0.11.0.0/kafka_2.11-0.11.0.0.tgz

# tar -xvzf kafka_2.11-0.10.1.0.tgz
tar -xvzf kafka_2.11-0.11.0.0.tgz

sudo mkdir -p /opt/apache
# sudo mv -T kafka_2.11-0.10.1.0/ /opt/apache/kafka/
sudo mv -T kafka_2.11-0.11.0.0/ /opt/apache/kafka/

# add lines to /etc/profile for $KAFKA_HOME

sudo sh -c "echo '' >> /etc/profile"

sudo sh -c "echo '# KAFKA_HOME' >> /etc/profile"

sudo sh -c "echo 'export KAFKA_HOME=/opt/apache/kafka' >> /etc/profile"

source /etc/profile

sudo sh -c "echo 'export PATH=$PATH:$KAFKA_HOME/bin' >> /etc/profile"

source /etc/profile

chown ec2-user /opt/apache/kafka -R
chgrp ec2-user /opt/apache/kafka -R

####################################################
# NOTE: CHANGE THIS NEXT TIME IT RUNS!!!
####################################################
sudo sh -c "echo '172.31.81.70  zoo1' >> /etc/hosts"

export BROKERID=3
export ZKNAME=zoo1
export PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
export PUBLIC_HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/public-hostname)

# this is kinda hinky, consider using -i[SUFFIX] to do in-place and using [SUFFIX] as the backup
cp $KAFKA_HOME/config/server.properties $KAFKA_HOME/config/server.properties.original

cat $KAFKA_HOME/config/server.properties | sed s/broker.id=0/broker.id=$BROKERID/ > $KAFKA_HOME/config/server.properties.new

cat $KAFKA_HOME/config/server.properties.new | sed s/zookeeper.connect=localhost:2181/zookeeper.connect=$ZKNAME:2181/ > $KAFKA_HOME/config/server.properties.new2

# Don't uncomment this line?  If so, need to put something different for listeners than for advertised.listeners I guess...

# cat  $KAFKA_HOME/config/server.properties.new2 | sed s@#listeners=PLAINTEXT://:9092@listeners=PLAINTEXT://:9092@ > $KAFKA_HOME/config/server.properties.new3

# needs to be like this: advertised.listeners=PLAINTEXT://ec2-34-205-23-39.compute-1.amazonaws.com:9092
cat  $KAFKA_HOME/config/server.properties.new2 | sed s@#advertised.listeners=PLAINTEXT://your.host.name:9092@advertised.listeners=PLAINTEXT://$PUBLIC_HOSTNAME:9092@ > $KAFKA_HOME/config/server.properties.new4

# overwrite original server.properties file
mv $KAFKA_HOME/config/server.properties.new4 $KAFKA_HOME/config/server.properties -f

# echo "hostname=${PUBLIC_IP}" >> $KAFKA_HOME/config/server.properties

chown ec2-user /opt/apache/kafka -R
chgrp ec2-user /opt/apache/kafka -R

rm /opt/apache/kafka/config/server.properties.new
rm /opt/apache/kafka/config/server.properties.new2
# rm /opt/apache/kafka/config/server.properties.new3
# rm /opt/apache/kafka/config/server.properties.new4


# change this line to include IP, use latest/meta-data #advertised.listeners=PLAINTEXT://your.host.name:9092

# nohup kafka-server-start.sh $KAFKA_HOME/config/server.properties 2>&1 &
sudo -u ec2-user $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &


# view all connections for kafka.Kafka: 
# ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}' | xargs -I % sh -c 'netstat -nap | grep %'

# NOTE:  Don't forget to open up port 2181 on Zookeeper server(s) or this won't work!

# kill Kafka:
# sudo kill $(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

# for Kafka server.properties file, need to add
# listeners=PLAINTEXT://:9092
# zookeeper.connect=zoo1:2181
# ^ make sure zoo1 points to ZK host in /etc/hosts file
# also, in /etc/hosts file, need to add entry to 127.0.0.1 line for ip-10-x-y-z or whatever local IP is

# launch produer like this:
# kafka-console-producer.sh --topic <TOPIC_NAME> --bootstrap-server 10.x.y.z:9092

# launch consumer like this:
# kafka-console-consumer.sh --topic <TOPIC_NAME> --bootstrap-server 10.x.y.z:9092 --consumer.config $KAFKA_HOME/config/consumer.properties [--from-beginning]

# make sure zookeeper.connect is set in consumer.properites

# update /etc/hosts with zookeeper server IP



# substitute the ubiquitous broker.id=0 for another number (variable passed in through CloudFormation?)

# backup original file
# cp $KAFKA_HOME/config/server.properties $KAFKA_HOME/config/server.properties.old

# BROKERID and Zookeeper stuff should be passed in through CF

export BROKERID=1

cat $KAFKA_HOME/config/server.properties | sed s/broker.id=0/broker.id=$BROKERID/ > $KAFKA_HOME/config/server.properties.new

cat $KAFKA_HOME/config/server.properties.new | sed s/zookeeper.connect=localhost:2181/zookeeper.connect=$ZKNAME:2181/ > $KAFKA_HOME/config/server.properties.new2

cat  $KAFKA_HOME/config/server.properties.new2 | sed s@#listeners=PLAINTEXT://:9092@listeners=PLAINTEXT://:9092@ > $KAFKA_HOME/config/server.properties.new3

# # NOTE: We’ll probably want to change log.dirs as well, possibly to EBS volume? /ebs/kafka-logs ?

# # overwrite original server.properties file
mv $KAFKA_HOME/config/server.properties.new3 $KAFKA_HOME/config/server.properties -f

nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > kafka.out 2>&1 &
# # not sure if this is a fantastic idea or not
# alias kafka='kafka-server-start.sh'
# kafka $KAFKA_HOME/config/server.properties
