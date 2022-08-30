https://www.confluent.io/blog/data-sharing-patterns-with-confluent-schema-registry/

https://docs.confluent.io/platform/current/multi-dc-deployments/cluster-linking/index.html

curl -v -X POST -H "Content-Type: application/json" --data @/path/to/test.avro <source sr url>/subjects/donuts/versions


docker-compose exec srcKafka kafka-topics --bootstrap-server srcKafka:19092 --topic topic-test --create --partitions 1 --replication-factor 1

docker-compose exec srcSchemaregistry kafka-avro-console-producer --broker-list srcKafka:19092 --topic topic-test --property schema.registry.url=http://srcSchemaregistry:8085 --property value.schema="$(cat data/schema.json)"




curl -v -X POST -H "Content-Type: application/json" --data @data/test.avro http://localhost:8085/subjects/donuts/versions

curl -v -X POST -H "Content-Type: application/json" --data @data/test.avro http://localhost:8085/subjects/:.snowcones:sales/versions

curl --silent -X GET 'http://localhost:8085/subjects?subjectPrefix=:*:'



curl --silent -X GET http://localhost:8085/subjects/

curl --silent -X GET http://localhost:8085/contexts


docker-compose exec srcKafka kafka-topics --bootstrap-server srcKafka:19092 --topic donuts --create --partitions 1 --replication-factor 1


kafka-avro-console-producer \
 --broker-list <broker-list> \
 --topic <topic>  \
 --property schema.registry.url=http://localhost:8081 \
 --property value.schema.id=419


vi ~/config.txt
docker-compose exec srcSchemaregistry /bin/bash
tee -a ~/config.txt <<EOF

schema.registry.url=http://destSchemaregistry:8086

schema-exporter --create --name test-source31 --subjects ":.snowcones:*" \
 --config-file ~/config.txt \
 --schema.registry.url http://srcSchemaregistry:8085 --context-type NONE


 schema-exporter --update --name test-source --context-name "snowcones" \
 --config-file ~/config.txt \
 --schema.registry.url http://srcSchemaregistry:8085 \
 --context-type NONE


 Verify the exporter is running and view information about it

 List available exporters.

 schema-exporter --list \
 --schema.registry.url http://srcSchemaregistry:8085


Describe the exporter.


schema-exporter --describe --schema.registry.url http://srcSchemaregistry:8085 --name test-source2


Get configurations for the exporter.

# NO PROBADO
schema-exporter --get-config --name test-source --schema.registry.url http://srcSchemaregistry:8085

Get the status of exporter.

schema-exporter --get-status --name test-source2 --schema.registry.url http://srcSchemaregistry:8085



curl --silent -X GET http://localhost:8086/contexts



schema-exporter --pause --name test-source2 --schema.registry.url http://srcSchemaregistry:8085
schema-exporter --delete --name test-source2 --schema.registry.url http://srcSchemaregistry:8085