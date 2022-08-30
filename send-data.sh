#!/bin/bash

docker-compose exec srcSchemaregistry kafka-avro-console-producer --broker-list srcKafka:19092 --topic topic-test --property schema.registry.url=http://srcSchemaregistry:8085 --property value.schema="$(cat data/schema.json)" < $(echo "{\"field1\" : \"a0\", \"field2\": \"b0\"}")