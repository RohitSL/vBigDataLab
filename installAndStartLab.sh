#Remove existing master
echo "Stopping and removing master ..."
docker stop master|| true && docker rm master || true

#setting count of workers
if [ -z "$1" ]
  then
    workerCount=1
  else
  	workerCount=$1
fi

echo "Creating $workerCount worker nodes and 1 master node..."

for (( a=1; a<=$workerCount; a++ ))
do
    echo "Stopping and removing worker$a ..."
    docker stop "worker$a" || true && docker rm "worker$a" || true
done

#add all worker containers name  to slaves file
true > ./inputfiles/slaves
for (( i=1; i<=$workerCount; i++ ))
do
    echo "Exporting worker$i to slaves configuration..."
    echo "worker$i" >> ./inputfiles/slaves
done

#Create a docker network
echo "Creating a virtual docker network..."
docker network rm vLabNetwork || true
docker network create -d bridge   --subnet 172.25.0.0/16  vLabNetwork
echo "Building base image..."
#Use below and comment docker build after that if you want to recreate base again.
#docker build --rm -t vlab-base:1.0 .
docker build -t vlab-base:1.0 .
echo "Adding master container based on base image..."
docker run -itd  --privileged --network="vLabNetwork"  --ip 172.25.0.100  -p 50570:50070  -p 8088:8088  -p 7077:7077 -p 8080:8080 -p 50571:3000 --name master --hostname master  vlab-base:1.0 /usr/sbin/init
echo "Adding worker containers based on base image..."
for (( c=1; c<=$workerCount; c++ ))
do
    tmpName="worker$c"
    #run vlab-base:1.0 image  as slave container
    docker run -itd  --privileged --network="vLabNetwork"  --ip "172.25.0.10$c" -p "6000$c":8081 --name $tmpName --hostname $tmpName  vlab-base:1.0 /usr/sbin/init
done

#Start hadoop spark and zeppelin
echo "Starting hadoop, spark and zeppelin..."
docker exec -ti master bash  -c "hadoop namenode -format && /usr/local/hadoop/sbin/start-dfs.sh && /usr/local/hadoop/sbin/start-yarn.sh && /usr/local/spark/sbin/start-all.sh && /usr/local/zeppelin/bin/zeppelin-daemon.sh --config /usr/local/zeppelin/conf start"
echo "Hadoop, spark and zeppelin started..."
echo "Check if following links are working for you..."
echo "For Zeppelin: http://localhost:50571"
echo "For Spark Master: http://localhost:8080"
echo "For Hadoop DFS: http://localhost:50570"
docker exec -ti master bash
#Wait before exit
read -p "Do you want exit now : " yesNo
