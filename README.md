# vBigDataLab
Docker containers hosting Apache Hadoop, Apache Spark and Apache Zeppelin for learning big data

Prerequisites:
1. Docker for windows
2. Extracted vBigDataLab directory.

To install lab:
Execute following command. Replace <workers> with number of worker nodes.
installAndStartLab.sh <wokers>

To stop lab:
Execute following command. Replace <workers> with number of worker nodes.
stopLab.sh <wokers>

Browse following links when lab is running:
For Zeppelin: http://localhost:50571
For Spark Master: http://localhost:8080
For Hadoop DFS: http://localhost:50570

To copy sample data to containers:
In windows server execute following command to copy sample data hadoop:
docker exec -ti master bash  -c "mkdir /usr/local/data"
docker cp SampleData master:/usr/local/data
docker exec -ti master bash  -c "hadoop fs -copyFromLocal /usr/local/data/SampleData hdfs://master:9000/SampleData"
