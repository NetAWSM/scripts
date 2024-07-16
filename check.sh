server="172.21.2.24" # адрес удаленного сервера
user="net"
count=1
BDATE=$(date +\%d-\%m-\%y:%H:%M)

while [ $count -lt 10 ]
  do
    if nc -z $server 22 2>/dev/null
      then
        echo "Соединение установлено" >> log
        break
    fi
    sleep 3
    echo "Сервер не доступен. Попытка соединения $count..." >> log
    ((count++))
  done
echo "Сервер не доступен" >> log

$(ssh $user@$server 'bash -s' < copy.sh )
