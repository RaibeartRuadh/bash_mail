#!/bin/sh
PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/script/
########################
#
# Укажите адрес электронной почты
mail=yourmail@yandex.ru
#
########################
echo 'Подготовленный отчет' | mail -s 'Отчет по файлу access.log' -A './formail.log'  $mail
