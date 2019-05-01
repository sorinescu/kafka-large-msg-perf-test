#!/bin/bash -e

TOPIC=bench
GROUP=bench

CONSUMERS=1
MSG_COUNT=1000

OPTIND=1

while getopts "m:c:" opt; do
    case "$opt" in
    c)  CONSUMERS=${OPTARG}
        ;;
    m)  MSG_COUNT=${OPTARG}
        ;;
    *)  exit 1
        ;;
    esac
done

echo "Running ${CONSUMERS} consumer(s), each consuming ${MSG_COUNT} messages from a single partition"
time {
    for i in `seq ${CONSUMERS}`; do
        kafka-console-consumer.sh --bootstrap-server kafka:9092 \
            --offset 0 \
            --topic ${TOPIC} \
            --partition $((i-1)) \
            --max-messages ${MSG_COUNT} \
            --group ${GROUP} >/dev/null &
    done

    wait
}
