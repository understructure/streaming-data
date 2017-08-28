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
