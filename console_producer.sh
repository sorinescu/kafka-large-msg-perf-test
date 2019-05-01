#!/bin/bash -e

TOPIC=bench
PARTITIONS=1
MSG_COUNT=1000
MSG_SIZE=1000000

OPTIND=1

while getopts "p:c:s:" opt; do
    case "$opt" in
    p)  PARTITIONS=${OPTARG}
        ;;
    c)  MSG_COUNT=${OPTARG}
        ;;
    s)  MSG_SIZE=${OPTARG}
        ;;
    *)  exit 1
        ;;
    esac
done

# Delete topic if it already exists
kafka-topics.sh --delete --zookeeper zookeeper:2181 --topic ${TOPIC} || true

# Create a topic
kafka-topics.sh --create --zookeeper zookeeper:2181 \
    --replication-factor 1 \
    --partitions ${PARTITIONS} \
    --topic ${TOPIC} \
    --config max.message.bytes=16000000 \
    --config retention.ms=$((24*60*60000))

# Create a 1MB input file, newline terminated
od -w${MSG_SIZE} < /dev/urandom | head -c ${MSG_SIZE} >msg.txt
echo >>msg.txt

echo "Producing ${MSG_COUNT} messages of ${MSG_SIZE} bytes each on ${PARTITIONS} partition(s)"
time {
    ( for i in `seq ${MSG_COUNT}`; do cat msg.txt; done ) | \
    kafka-console-producer.sh --broker-list kafka:9092 \
        --compression-codec none \
        --topic ${TOPIC}
}
