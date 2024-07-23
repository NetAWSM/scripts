DIR="/opt/copy/"   # Директория на удаленном сервере
server="s001dev-nss01" # адрес удаленного сервера
user="net" # Пользовтель для подключения
BDATE=$(date +\%d-\%m-\%y:%H)
log=$(date +\%d-\%m-\%y:%H:%M:%S)
count=1

get_files() {

ssh $user@$server 'for i in $(find /opt/copy -type f -name *.jpg); do sha256sum $i; done' > temp  #$после find надо вписать путь из DIR, сам DIR почему то не работает
if [ -s temp ]
  then
    mkdir $DIR/$BDATE
else
  echo $log "Новых файлов для передачи не найдено" >> log
  rm -f temp
  exit
fi

for i in $(cat temp | awk '{print$2}');
  do
    scp $user@$server:$i $DIR/$BDATE
done
cat temp | awk '{print$1}' > list
cat temp | awk '{print$2}' > temp_list
rm -f temp


}

comparison() {

for i in $(find $DIR/$BDATE -type f -name *.jpg); do sha256sum $i; done | sort > temp  #sort не работает
cat temp | awk '{print$1}' > dmz_list
cat temp | awk '{print$2}' > temp_dmz_list
rm -f temp

if [[ $(diff -s dmz_list list | awk '{print$6}') == "identical" ]]
  then
    echo $log "Файлы успешно скопированы" >> log
else
    echo $log "Ошибка копирования файлов" >> log
    rm -rf $DIR/$BDATE # Если ошибка копирования, то надо удалить и скрипт перезапустить
    diff -q temp_list temp_dmz_list >> log # отформатировать лог
    #main
fi

rm -f dmz_list list temp_list temp_dmz_list

}


check() {

while :
  do
    if nc -z $server 22 2>/dev/null
      then
        echo $log "Соединение установлено" >> log
        break
    fi
    echo $log "Сервер не доступен. Попытка соединения $count..." >> log
    ((count++))
    if [ $count -gt 10 ]
      then
        exit
    else
      sleep 3  #В проде увеличить до 600
    fi
done


if ssh -o stricthostkeychecking=no -o userknownhostsfile=/dev/null -o passwordauthentication=no $user@$server : 2>/dev/null
  then
    echo $log "Доступ разрешен" >> log
  else
    echo $log "Доступ пользователя $user запрещен" >> log
    exit
fi

}


main() {

check
get_files
ssh $user@$server "rm -rf $DIR/*"
comparison

}

main
