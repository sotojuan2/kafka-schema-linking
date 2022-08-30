# Schema linking demo

## Hub to spoke: Data sharing

The “hub to spoke” pattern involves utilizing a single Schema Registry globally in an organization. The data sharing component involves only replicating schemas that are needed (or all) by the “spokes,” or individual business units


## Start the cluster
```shell
docker-compose up -d
```

Two CP clusters are running:

1. Source/Hub Control Center available at http://localhost:19021
2. Destination Control Center available at http://localhost:29021
3. Source Schema Register availabel at http://localhost:8085
4. Destination Contro Center availabel at http://localhost:8086


## DEMO

### Create Schema at the Hub level

Three different schemas will be created:

1. No context `curl -v -X POST -H "Content-Type: application/json" --data @data/test.avro http://localhost:8085/subjects/donuts/versions`
2. With `Hub` context (CPD) `curl -v -X POST -H "Content-Type: application/json" --data @data/test.avro http://localhost:8085/subjects/:.CPD:orders/versions`
3. With `Spoke` context (LC) `curl -v -X POST -H "Content-Type: application/json" --data @data/test.avro http://localhost:8085/subjects/:.LC:assets/versions`

Check the context on the destination/hub Schema Registry
```shell
curl --silent -X GET http://localhost:8085/contexts
```

```console
foo@bar:~$ [".",".CPD",".LC"]%         
```

### Create the exporter from hub to spoke

1. Create a config file on Source Schem Registry host.
```shell
Docker-compose exec srcSchemaregistry /bin/bash
tee -a ~/config.txt <<EOF
schema.registry.url=http://destSchemaregistry:8086
EOF
```
2. Create the exporter for CPD
```shell
schema-exporter --create --name CPD --subjects ":.CPD:*" \
 --config-file ~/config.txt \
 --schema.registry.url http://srcSchemaregistry:8085 --context-type NONE
```
3. Create the exporter for LC
```shell
schema-exporter --create --name LC --subjects ":.LC:*" \
 --config-file ~/config.txt \
 --schema.registry.url http://srcSchemaregistry:8085 --context-type NONE
```

### Validate exporter are working
1. On the container check the list
```shell
schema-exporter --list \
 --schema.registry.url http://srcSchemaregistry:8085
```
2. check the status

```shell
schema-exporter --get-status --name LC --schema.registry.url http://srcSchemaregistry:8085
schema-exporter --get-status --name CPD --schema.registry.url http://srcSchemaregistry:8085
```
### Validate Schemas are on spoke/destination
```shell
curl --silent -X GET http://localhost:8086/contexts
curl --silent -X GET 'http://localhost:8086/subjects?subjectPrefix=:*:'
```


## Clean-up

1. Clean the docker cluster `docker-compose down -v`


## Fix


