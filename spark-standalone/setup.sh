#!/bin/bash

USER=root
BIN_FOLDER="/root/spark/sbin"
EPHEMERAL_HDFS=/root/ephemeral-hdfs

if [[ "0.7.3 0.8.0 0.8.1" =~ $SPARK_VERSION ]]; then
  BIN_FOLDER="/root/spark/bin"
fi

# Copy the slaves to spark conf
cp /root/spark-ec2/slaves /root/spark/conf/
/root/spark-ec2/copy-dir /root/spark/conf

# Set cluster-url to standalone master
echo "spark://""`cat /root/spark-ec2/masters`"":7077" > /root/spark-ec2/cluster-url
/root/spark-ec2/copy-dir /root/spark-ec2

# The Spark master seems to take time to start and workers crash if
# they start before the master. So start the master first, sleep and then start
# workers.

# Stop anything that is running
$BIN_FOLDER/stop-all.sh

sleep 2

# Start Master
$BIN_FOLDER/start-master.sh

# Pause
sleep 20

# Start Workers
$BIN_FOLDER/start-slaves.sh

# Start historyserver
$EPHEMERAL_HDFS/bin/hadoop fs -mkdir -p /tmp/spark-events
$BIN_FOLDER/start-history-server.sh
