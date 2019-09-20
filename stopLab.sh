#Remove existing master
echo "Stopping master node..."
docker stop master|| true

#setting count of workers
if [ -z "$1" ]
  then
    workerCount=1
  else
  	workerCount=$1
fi

echo "Stopping $workerCount worker nodes..."

for (( a=1; a<=$workerCount; a++ ))
do
    echo "Stopping worker$a ..."
    docker stop "worker$a" || true
done

echo "Virtual big data lab stopped..."
#Wait before exit
read -p "Do you want exit now : " yesNo
