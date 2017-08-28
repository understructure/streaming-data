# streaming-data

## Kafka Stuff

```curl http://169.254.169.254/latest/meta-data/

# view all connections for kafka.Kafka (NOTE: have to be sudo to view them all):

ps ax | grep -i 'kafka.Kafka' | grep -v grep | awk '{print $1}' | xargs -I % sh -c 'netstat -nap | grep %'

# setup Zookeeper server name with its private IP in /etc/hosts file as zoo1
# launch produer like this:`
$KAFKA_HOME/bin/kafka-console-producer.sh --topic <TOPIC_NAME> --bootstrap-server zoo1:9092

# launch consumer like this:`
# kafka-console-consumer.sh --topic <TOPIC_NAME> --bootstrap-server zoo1:9092 --consumer.config $KAFKA_HOME/config/consumer.properties [--from-beginning]
```

## Zookeeper Stuff

* You can telnet to zookeeper and issue the command of `ruok` to check if it's setup and running

 `telnet 127.0.0.1 2181`

* You can also run this to administer Zookeeper (assuming $ZK_HOME points to your zk install dir):

`$ZK_HOME/bin/zkCli.sh -server 127.0.0.1:2181`

* From there, you can use the ["four letter words"](https://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html#sc_zkCommands) to see what's up.  Most helpful for Kafka connectivity is `ls /brokers/ids` - particularly helpful when you're adding new nodes to a cluster
