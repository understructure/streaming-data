#!/bin/bash

# COMMON

cd

# sudo yum -y update

# # install Java JDK
# wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.rpm
# sudo rpm -Uvh jdk-8u144-linux-x64.rpm

# # add lines to /etc/profile for $JAVA_HOME

# sudo sh -c "echo '' >> /etc/profile"

# sudo sh -c "echo '# JAVA_HOME' >> /etc/profile"
# sudo sh -c "echo 'export JAVA_HOME=/usr/java/default' >> /etc/profile"
# sudo sh -c "echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile"

# sudo sh -c "echo 'export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar' >> /etc/profile"

# source /etc/profile

###################################################################################
# install Zookeeper
###################################################################################

wget http://mirrors.sonic.net/apache/zookeeper/stable/zookeeper-3.4.10.tar.gz
# wget http://apache.mirrors.lucidnetworks.net/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz

tar -xvzf zookeeper-3.4.10.tar.gz
# tar -xvzf zookeeper-3.4.9.tar.gz

sudo mkdir -p /opt/apache

sudo sh -c "echo 'export ZK_HOME=/opt/apache/zookeeper' >> /etc/profile"

source /etc/profile

sudo mv -T zookeeper-3.4.10/ $ZK_HOME
# sudo mv -T zookeeper-3.4.9/ $ZK_HOME

mkdir -p /opt/apache/zookeeper/conf

sudo mkdir -p /var/zookeeper


# edit /etc/hosts file to add reference(s) to ZooKeeper server(s)
export THIS_IP=$(hostname -I) # this adds a newline character to the end of the $THIS_IP variable, but that's OK here
sudo sh -c "echo '$THIS_IP  zoo1' >> /etc/hosts"

# NOTE:  Need to get other IPs from CloudFormation or something
# also need to pass this information down to the Kafka instances?

# touch $ZK_HOME/conf/zoo.cfg

# echo 'tickTime=2000' >> $ZK_HOME/conf/zoo.cfg

# this should be a sed statement:

# echo 'dataDir=/var/zookeeper' >> $ZK_HOME/conf/zoo.cfg
cat $ZK_HOME/conf/zoo_sample.cfg | sed s@dataDir=/tmp/zookeeper@dataDir=/var/zookeeper@ > $ZK_HOME/conf/zoo.cfg

# echo 'clientPort=2181' >> $ZK_HOME/conf/zoo.cfg
echo 'server.1=zoo1:2888:3888' >> $ZK_HOME/conf/zoo.cfg

# moved from line ~34
sudo chown ec2-user /opt/apache -R
sudo chgrp ec2-user /opt/apache -R

sudo chown ec2-user /var/zookeeper -R
sudo chgrp ec2-user /var/zookeeper -R

# once we get the other servers in there
# echo 'server.2=zoo2' >> $ZK_HOME/conf/zoo.cfg
# echo 'server.3=zoo3' >> $ZK_HOME/conf/zoo.cfg
# # start Zookeeper

nohup $ZK_HOME/bin/zkServer.sh start > zookeeper.out 2>&1 &

# run this to see what's up with zookeeper:
# $ZK_HOME/bin/zkCli.sh -server 127.0.0.1:2181

# NOTE:  Don't forget to open up port 2181 on Zookeeper server(s) or Kafka won't be able to start!

# for reference, need to do sudo sh -c to write to files with certain permissions

# sudo sh -c "echo 'tickTime=2000' >> $ZK_HOME/conf/zoo.cfg"
# sudo sh -c "echo 'dataDir=/var/zookeeper' >> $ZK_HOME/conf/zoo.cfg"
# sudo sh -c "echo 'clientPort=2181' >> $ZK_HOME/conf/zoo.cfg"
