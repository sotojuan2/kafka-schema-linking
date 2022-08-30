#!/bin/bash

# Start cluster
docker-compose down -v
docker-compose up -d

# Wait srcZookeeper is UP
ZOOKEEPER_STATUS=""
while [[ $ZOOKEEPER_STATUS != "imok" ]]; do
  echo "Waiting zookeeper UP..."
  sleep 1
  ZOOKEEPER_STATUS=$(echo ruok | docker-compose exec srcZookeeper nc localhost 2181)
done
echo "Zookeeper ready!!"

# Wait brokers is UP
FOUND=''
while [[ $FOUND != "yes" ]]; do
  echo "Waiting Broker UP..."
  sleep 1
  FOUND=$(docker-compose exec srcZookeeper zookeeper-shell srcZookeeper get /brokers/ids/1 &>/dev/null && echo 'yes')
done
echo "Broker ready!!"

# Create the test-topic
docker-compose exec srcKafka kafka-topics --bootstrap-server srcKafka:19092 --topic topic-test --create --partitions 1 --replication-factor 1


HEADER="Content-Type: application/json"
DATA=$( cat << EOF
{
  "name": "testReplicator",
  "config": {
    "name": "testReplicator",
    "connector.class": "io.confluent.connect.replicator.ReplicatorSourceConnector",
    "tasks.max": "1",
    "confluent.topic.replication.factor": "1",
    "producer.override.enable.idempotence": "true",
    "producer.override.acks": "all",
    "producer.override.max.in.flight.requests.per.connection": "1",

    "topic.whitelist": "topic-test",

    "src.kafka.bootstrap.servers": "http://srcKafka:19092",
    "src.key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "src.key.converter.schemas.enable": "false",
    "src.value.converter": "io.confluent.connect.avro.AvroConverter",
    "src.value.converter.schema.registry.url": "http://srcSchemaregistry:8085",

    "dest.kafka.bootstrap.servers": "http://destKafka:29092",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "key.converter.schemas.enable": "false",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter.schema.registry.url": "http://destSchemaregistry:8086"
  }
}
EOF
)


RETCODE=1
while [ $RETCODE -ne 0 ]
do
  curl -f -X POST -H "${HEADER}" --data "${DATA}" http://connect:8083/connectors
  RETCODE=$?
  if [ $RETCODE -ne 0 ]
  then
    echo "Failed to submit replicator to Connect. This could be because the Connect worker is not yet started. Will retry in 10 seconds"
  fi
  #backoff
  sleep 10
done
echo "replicator configured"

# show result
docker-compose ps -a