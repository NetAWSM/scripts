DIR="/opt/copy/"   # Директория на удаленном сервере
server="91.224.86.112" # адрес удаленного сервера
user="net" # Пользовтель для подключения
BDATE=$(date +\%d-\%m-\%y:%H)
count=1

get_files() {

ssh $user@$server 'for i in $(find /opt/copy -type f -name *.jpg); do sha256sum $i; done' > temp  #$после find надо вписать путь из DIR, сам DIR почему то не работает
if [ -s temp ]
  then
    mkdir $DIR/$BDATE
else
  echo $(date +\%d-\%m-\%y:%H:%M) "Новых файлов для передачи не найдено" >> log
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
    echo $(date +\%d-\%m-\%y:%H:%M) "Файлы успешно скопированы" >> log
else
    echo $(date +\%d-\%m-\%y:%H:%M) "Ошибка копирования файлов" >> log
    rm -rf $DIR/$BDATE # Если ошибка копирования, то надо удалить и скрипт перезапустить
    diff temp_list temp_dmz_list >> log # отформатировать лог
fi

rm -f dmz_list
rm -f list

}


main() {

get_files
ssh $user@$server "rm -rf $DIR/*"
comparison

}

while [ $count -lt 10 ]
  do
    if nc -z $server 22 2>/dev/null
      then
        echo $(date +\%d-\%m-\%y:%H:%M) "Соединение установлено" >> log
        main
        break
    fi
    sleep 3
    echo $(date +\%d-\%m-\%y:%H:%M) "Сервер не доступен. Попытка соединения $count..." >> log
    ((count++))
  done