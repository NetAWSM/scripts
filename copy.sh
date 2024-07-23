DIR="/opt/copy/"   # Директория на удаленном сервере
server="s001dev-nss01" # адрес удаленного сервера
user="net" # Пользовтель для подключения
BDATE=$(date +\%d-\%m-\%y:%H)
fail=1
count=1


get_files() {

ssh $user@$server 'for i in $(find /opt/copy -type f -name *.jpg); do sha256sum $i; done' > temp  #$после find надо вписать путь из DIR, сам DIR почему то не работает
if [ -s temp ]
  then
    mkdir $DIR/$BDATE
else
  echo $(date +\%d-\%m-\%y:%H:%M:%S) "Новых файлов для передачи не найдено" >> log
  rm -f temp
  exit
fi

for i in $(cat temp | awk '{print$2}');
  do
    scp $user@$server:$i $DIR/$BDATE
    sleep 2
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
    echo $(date +\%d-\%m-\%y:%H:%M:%S) "Файлы успешно скопированы" >> log
    ssh $user@$server "rm -rf $DIR/*"  #Ошибку при удалении в лог
else
    echo $(date +\%d-\%m-\%y:%H:%M:%S) "Ошибка копирования файлов. Попытка перезапуска $fail" >> log
    ((fail++))
    rm -rf $DIR/$BDATE # Ошибку при удалении в лог
    if [ $fail -gt 3 ]
      then
        echo $(date +\%d-\%m-\%y:%H:%M:%S) "Выполнение программы завершено с ошибкой." >> log
        exit
    fi
    #diff -q temp_list temp_dmz_list >> log # отформатировать лог
    main
fi

rm -f dmz_list list temp_list temp_dmz_list

}


check() {

while :
  do
    if nc -z $server 22 2>/dev/null
      then
        echo $(date +\%d-\%m-\%y:%H:%M:%S) "Соединение установлено" >> log
        break
    fi
    echo $(date +\%d-\%m-\%y:%H:%M:%S) "Сервер не доступен. Попытка соединения $count..." >> log
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
    echo $(date +\%d-\%m-\%y:%H:%M:%S) "Доступ разрешен" >> log
  else
    echo $(date +\%d-\%m-\%y:%H:%M:%S) "Доступ пользователя $user запрещен" >> log
    exit
fi

}


main() {

check
get_files
comparison

}

main
