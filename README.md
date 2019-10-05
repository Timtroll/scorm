# scorm
Обучающая система. В основе создания - соглашение Tin Can (https://timtroll.github.io/xAPI-SpecRu/).

## DEMO 
* Admin App - [DEMO](https://freee.su)
* Site App
* Cabinet App

# запуск после перезагрузки
Скопируйте файл freee.service в каталог /etc/systemd/system/ 

Смотрим его статус systemctl status freee

* freee.service - Freee
*    Loaded: loaded (/etc/systemd/system/freee.service; disabled)
*    Active: inactive (dead)

Видим, что он disabled — разрешаем его
* systemctl enable freee
* systemctl -l status freee

Если нет никаких ошибок в юните — то вывод будет вот такой:

* freee.service - Freee
*    Loaded: loaded (/etc/systemd/system/freee.service; enabled)
*    Active: inactive (dead)


Запускаем сервис
* systemctl start freee

Смотрим красивый статус:
* systemctl -l status freee

Если есть ошибки — читаем вывод в статусе, исправляем, не забываем после исправлений в юните перегружать демон systemd

* systemctl daemon-reload
