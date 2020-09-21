#!/bin/sh
PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/script/
#################################
#                               #
# Укажите полный путь к файлу access.log NGIXN или APACHE2
name=/opt/script/access.log
#                               #
#################################
#                               #
# Введите количество записей ТОП для выборок Кто запрашивает и Что запрашивают
ttn=5
#                               #
#################################
#mail=alexandra.skyland@gmail.com
# Далее нам нужно определить на какой строке лога мы завершили анализ. Если лог добавился, то нужно продолить с новых строк
# Если значение 0, то считаем с самого начала
# В качестве файла для хранения используется файл row_counter_log
# Считываем его и назначаем переменной point это значение
# если файла row_counter_log нет, то команда создаст его, если нет, то не изменит
if [ -f row_counter_log ]; then 
echo "Файл учёта количеста обработанных строк существует!"
else
touch row_counter_log 
echo "Файл учёта количеста обработанных строк создан!" 
echo 0 > row_counter_log

fi
# назначаем точку 
point=$(cat ./row_counter_log 2>/dev/null);status=$?
# Проверяем количество строк в анализируемом файле 
verify_lines=$(wc $name | awk '{print $1}')

if ! [ -n "$point" ]
then
     # Диапазон времени в логе

     startpoint=$(awk '{print $4 $5}' $name | sed 's/\[//; s/\]//' | sed -n 1p)
     endpoint=$(awk '{print $4 $5}' $name | sed 's/\[//; s/\]//' | sed -n "$verify_lines"p)
	 
	 echo "Выборка с:" $startpoint " по: "$endpoint >  formail.log && cat formail.log
	 echo ""	
	 
	 echo $verify_lines > ./row_counter_log
	 	 
     # Кто запрашивает 
     echo " Топ-"$ttn "IP-адресов с указанием кол-ва запросов c момента последнего запуска скрипта" > queryIP.log
     #awk '{print $1}' $name | sort | uniq -c | sort -rn | head -n $ttn > queryIP.log && tail -n $ttn queryIP.log &&
	 awk "NR>$verify_lines" $name | awk '{print $1}' | sort | uniq -c | sort -rn | head -n $ttn >> queryIP.log && cat queryIP.log &&
     echo " " 
     # Что запрашивают
     echo " Топ-"$ttn " запрашиваемых адресов с указанием кол-ва запросов c момента последнего запуска скрипта" > requestIP.log
     #awk '{print $7}' $name | sort | uniq -c | sort -rn | head -n $ttn > requestIP.log && cat requestIP.log &&
	 awk "NR>$verify_lines" $name | awk '{print $7}' $name | sort | uniq -c | sort -rn | head -n $ttn >> requestIP.log && cat requestIP.log &&
     echo " "
     # Все коды возврата
     echo " Список всех кодов возврата с указанием их кол-ва с момента последнего запуска" > allresponces.log
     #awk '{print $9}'  $name | sort | uniq -c | sort -nr > allresponces.log && cat allresponces.log &&
	 awk "NR>$verify_lines" $name | awk '{print $9}'  $name | sort | uniq -c | sort -nr >> allresponces.log && cat allresponces.log &&
     echo " "
     # Все коды ошибок HTTP
     echo " Все коды ошибок HTTP c момента последнего запуска (с сортировкой по количеству)" > errorresponces.log
     #awk '$9 ~ /(^4|^5)/ {print $9;}'  $name  | sort | uniq -c | sort -gr > errorresponces.log && cat  errorresponces.log
     echo " "
     awk "NR>$verify_lines" $name | awk '$9 ~ /(^4|^5)/ {print $9;}'  $name  | sort | uniq -c | sort -gr >> errorresponces.log && cat  errorresponces.log
	 # Все данные сливаем в один файл
     cat queryIP.log  requestIP.log allresponces.log errorresponces.log >>  formail.log
	 # Очищаем промежуточные файлы, так как они не нужны
     rm -f queryIP.log requestIP.log allresponces.log errorresponces.log
     # Отправка почты
     mail.sh
	 
else
    # Дата начала и конца
    startpoint=$(awk '{print $4 $5}' $name | sed 's/\[//; s/\]//' | sed -n "$(($point+1))"p)
    endpoint=$(awk '{print $4 $5}' $name | sed 's/\[//; s/\]//' | sed -n "$verify_lines"p)

	echo "Выборка с:" $startpoint " по: "$endpoint >  formail.log && cat formail.log
	echo ""	
	# Кто запрашивает 
	echo " Топ-"$ttn "IP-адресов с указанием кол-ва запросов c момента последнего запуска скрипта" > queryIP.log 
    awk '{print $1}' $name | sort | uniq -c | sort -rn | head -n $ttn >> queryIP.log && cat queryIP.log &&
	echo " " 
	# Что запрашивают
	echo " Топ-"$ttn " запрашиваемых адресов с указанием кол-ва запросов c момента последнего запуска скрипта" > requestIP.log
	awk '{print $7}' $name | sort | uniq -c | sort -rn | head -n $ttn >> requestIP.log && cat requestIP.log &&
	echo " "	
	# Все коды возврата
	echo " Список всех кодов возврата с указанием их кол-ва с момента последнего запуска" > allresponces.log
	awk '{print $9}'  $name | sort | uniq -c | sort -nr >> allresponces.log && cat allresponces.log &&
    echo " " 
    # Все коды ошибок HTTP	
	echo " Все коды ошибок HTTP c момента последнего запуска (с сортировкой по количеству)" > errorresponces.log
	awk '$9 ~ /(^4|^5)/ {print $9;}'  $name  | sort | uniq -c | sort -gr >> errorresponces.log && cat  errorresponces.log
    echo $verify_lines > ./row_counter_log
    # Все данные сливаем в один файл
    cat queryIP.log  requestIP.log allresponces.log errorresponces.log >>  formail.log
	# Очищаем промежуточные файлы, так как они не нужны
    rm -f queryIP.log requestIP.log allresponces.log errorresponces.log
	# Отправка почты
    mail.sh

fi



