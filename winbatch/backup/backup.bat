:: Версия 1.4.5 betta
@echo off
:: Название bat файла
set filenamebat=%~n0
:: Название процесса
set ps_name="Process %filenamebat%"
:: Путь до лога
set default_log_file="%filenamebat%.log"
:: Путь до файла конфигурации
set default_conf_file="%filenamebat%.conf"
:: Список переменных, которые объявляются в конфигурационном файле
:: и проверяются на непустоту
set varlist=arch_type arch_flags dirbackup
:: Путь до списка
set default_list="%filenamebat%.list"
for %%a in (%*) do (
  for /f "tokens=1* delims=:" %%a in ("%%a") do (
    if %%a==/a (
      set action=%%b
    )
    if %%a==/o (
      set log_file=%%b
    )
    if %%a==/c (
      set conf_file=%%b
    )  
    if %%a==/l (
      set list=%%b
    )
    if %%a==/h (
      call :help
      exit /b
    )
  )
)
if not defined log_file (
  set log_file=%default_log_file%
)
if not defined conf_file (
  set conf_file=%default_conf_file%
)
if not defined list (
  set list=%default_list%
)
call :checkrun %ps_name%
if %errorlevel% equ 0 (
  call :log Ошибка. %filenamebat% уже запущен
  exit /b 1
)
title %ps_name%
call :get_date
set datestart=%getdate%
call :log ===== Начинаем резервное копирование =====
if not exist %conf_file% (
  call :log Ошибка Файл конфигурации %conf_file% не найден
  exit /b 1
)
if not exist %list% (
  call :log Ошибка. Список файлов %list% не найден
  exit /b 1
)
call :log Считывание параметров из конфигурации %conf_file%
:: Обработка файла c настройками
for /f "usebackq eol=# delims==  tokens=1*" %%a in (%conf_file%) do (
  call :log %%a=%%b
  set %%a=%%b
)
:: Проверка переменных на пустое значение
for %%a in (%varlist%) do (
  if not defined %%a (
    call :log Ошибка. Параметр %%a не определен
    exit /b 1
  )
)
:: Проверка налчия архиватора по указанному адресу
if not exist %acrh% (
  call :log Ошибка. Не найден архиватор %acrh%
  exit /b 1
)
:: Обработка дейтвий переданных как аргумент
for /f "tokens=1,2* delims=: " %%a in ("%action%") do (
  if %%a==backup_mssql (
    call :backup_mssql %%b %%c
    exit /b
  )
  if %%a==backup_ntbakup (
    call :backup_ntbakup %%b %%c
    exit /b
  )
  if %%a==backup_file (
    call :backup_file %%b %%c
    exit /b
  )
  if %%a==delete_old (
    call :delete_old %%b %%c
    exit /b
  )
  if %%a==make_report (
    call :make_report %%b %%c
    exit /b
  )
  if %%a==clear_trn (
    call :clear_trn %%b %%c
    exit /b
  )
  if %%a==checkdatabase_mssql (
    call :checkdatabase_mssql %%b %%c
    exit /b
  )
  if %%a==shrinkdatabase_mssql (
    call :shrinkdatabase_mssql %%b %%c
    exit /b
  )
  if %%a==maintenance_mssql (
    call :shrinkdatabase_mssql %%b %%c
    call :checkdatabase_mssql %%b %%c
    exit /b
  )
)
:: Обработка списка
for /f "usebackq eol=# tokens=1,2* delims=| " %%a in (%list%) do (
  if %%a==backup_mssql (
    call :backup_mssql %%b %%c
  )
  if %%a==backup_ntbakup (
    call :backup_ntbakup %%b %%c
  )
  if %%a==backup_file (
    call :backup_file %%b %%c
  )
  if %%a==delete_old (
    call :delete_old %%b %%c
  )
  if %%a==make_report (
    call :make_report %%b %%c
  )
  if %%a==clear_trn (
    call :clear_trn %%b %%c
  )
  if %%a==exec (
    call :exec %%b %%c
  )
  if %%a==checkdatabase_mssql (
    call :checkdatabase_mssql %%b %%c
  )
  if %%a==shrinkdatabase_mssql (
    call :shrinkdatabase_mssql %%b %%c
  )
  if %%a==maintenance_mssql (
    call :shrinkdatabase_mssql %%b %%c
    call :checkdatabase_mssql %%b %%c
  )

)
exit /b

::
:: Описание "функций"
::

:: Форматирование даты YYYYMMDD
:get_date
  for /f "tokens=1-3 delims=.-/ " %%a in ("%date%") do set getdate=%%c%%b%%a
exit /b

:: Форматирование времени HH.MM.ss.mm
:get_time
  for /f "tokens=1-4 delims=:, " %%a in ("%time%") do set gettime=%%a.%%b.%%c.%%d
exit /b

:: Функция бекапа БД MSSQL
::
:: Вход:
::  %1 Имя архива
::  %2 Строка вида <username>:<password>@<host>/<databasename>, 
::     где <username> - имя пользователя БД
::         <password> - пароль к БД
::         <host> - сервер БД
::         <databasename> - имя БД
:backup_mssql
  :: Проверка налчия утилиты isql по указанному адресу
  if not exist %isql% (
    call :log Предупреждение. Не найдена утилита %isql%. Бекап БД не будет выполнен.
    exit /b
  )
  for /f "tokens=1-4 delims=:@/ " %%a in ("%2") do (
    set username=%%a
    set password=%%b
    set dbserver=%%c
    set dbname=%%d
  )
  set arch_name="%dirbackup%\%datestart%_%1.%arch_type%"
  set query="backup database %dbname% to DISK='%dirbackup%\%datestart%_%1.bak'"
  set bak_file="%dirbackup%\%datestart%_%1.bak"
  set log_bak_file="%dirbackup%\%datestart%_%1.log"
  if exist %arch_name% (
    call :log Предупреждение. Резервная копия БД %dbname% сервера %dbserver% за %datestart% уже сделанна %arch_name%
  ) else (
    call :log Создание резервной копии базы данных %dbname% в файл %bak_file%
    %isql% -S %dbserver% -d %dbname% -U %username% -P %password% -Q %query% -o %log_bak_file%
    type %log_bak_file% >> %log_file%
    if exist %bak_file% (
      call :log Резервная копия %bak_file% создана
      call :log Архивирование %bak_file%, %log_bak_file%
      call :copmress %arch_name% %bak_file% %log_bak_file%
      if exist %arch_name% (
        call :log Архив %arch_name% создан
        call :rm %bak_file%
        call :rm %log_bak_file%
        call :sync %arch_name% %mirrors%
      ) else (
        call :log Архив %arch_name% не создан
      )
    ) else (
      call :log Резервная копия %bak_file% не создана
    )
  )
exit /b

:: Проверяет логическую и физическую целостность объектов в БД
::
:: Вход:
::  %* Строка вида <username>:<password>@<host>/<databasename>, 
::     где <username> - имя пользователя БД
::         <password> - пароль к БД
::         <host> - сервер БД
::         <databasename> - имя БД
:checkdatabase_mssql
  if not exist %isql% (
    call :log Предупреждение. Не найдена утилита %isql%. Проверка БД не будет выполнена.
    exit /b
  )
  for /f "tokens=1-4 delims=:@/ " %%a in ("%*") do (
    set username=%%a
    set password=%%b
    set dbserver=%%c
    set dbname=%%d
  )
  set query="DBCC CHECKDB (%dbname%) WITH NO_INFOMSGS"
  set log_query="%tmp%\%datestart%_log_query"
  call :log Проверка базы данных %dbname%
  %isql% -S %dbserver% -d %dbname% -U %username% -P %password% -Q %query% -o %log_query%
  type %log_query% >> %log_file%
  call :rm %log_query%
exit /b

:: Сокращает размер файлов данных и файлов журнала в указанной базе данных.
::
:: Вход:
::  %* Строка вида <username>:<password>@<host>/<databasename>, 
::     где <username> - имя пользователя БД
::         <password> - пароль к БД
::         <host> - сервер БД
::         <databasename> - имя БД
:shrinkdatabase_mssql
  if not exist %isql% (
    call :log Предупреждение. Не найдена утилита %isql%. Сжатие БД не будет выполнено.
    exit /b
  )
  for /f "tokens=1-4 delims=:@/ " %%a in ("%*") do (
    set username=%%a
    set password=%%b
    set dbserver=%%c
    set dbname=%%d
  )
  set query="DBCC SHRINKDATABASE (%dbname%,  TRUNCATEONLY) WITH NO_INFOMSGS"
  set log_query="%tmp%\%datestart%_log_query"
  call :log Сжатие базы данных %dbname%
  %isql% -S %dbserver% -d %dbname% -U %username% -P %password% -Q %query% -o %log_query%
  type %log_query% >> %log_file%
  call :rm %log_query%
exit /b

:: Функция бекапа файлов *.bks
::
:: Вход:
::  %1 Имя архива
::  %2 Полный путь до bks файла
:backup_ntbakup
  :: Проверка налчия ntbackup по указанному адресу
  if not exist %ntbackup% (
    call :log Предупреждение. Не найдена программа %ntbackup%. ntbackup не будет выполнен
    exit /b
  )
  for /f "tokens=1* delims= " %%a in ("%*") do (
    set name=%%a
    set bksfile=%%b
  )
  set bkf_file="%dirbackup%\%datestart%_%name%.bkf"
  set arch_name="%dirbackup%\%datestart%_%name%.%arch_type%"
  set log_bkf_file="%userprofile%\Local Settings\Application Data\Microsoft\Windows NT\NTBackup\data\*.log"
  if exist %arch_name% (
    call :log Предупреждение. Резервная копия %name% за %datestart% уже сделанна %arch_name%
  ) else (
    call :log Создание резервной копии %name% в файл  %bkf_file%
    %ntbackup% backup "@%bksfile%" /J "%name%" /F %bkf_file% /V:yes /L:f /M normal /SNAP:on
    if exist %bkf_file% (
      call :log Резервная копия %bkf_file% создана
      call :log Архивирование %bkf_file%
      call :copmress %arch_name% %bkf_file% %log_bkf_file%
      if exist %arch_name% (
        call :log Архив %arch_name% создан
        call :sync %arch_name% %mirrors%
        call :rm %bkf_file%
        call :rm %log_bkf_file%
      ) else (
        call :log Архив %arch_name% не создан
      )
    ) else (
      call :log Резервная копия %bkf_file% не создана
    )
  )
exit /b

:: Функция бекапа файл(ов)
::
:: Вход:
::  %1 Имя архива
::  %2 Список файлов, каждый файл должен быть заключен в кавычки, разделитель между файлами - пробел
:backup_file
  for /f "tokens=1* delims= " %%a in ("%*") do (
    set name=%%a
    set files=%%b
  )
  set arch_name="%dirbackup%\%datestart%_%name%.%arch_type%"
  if exist %arch_name% (
    call :log Предупреждение. Резервная копия файлов %files% за %datestart% уже сделанна %arch_name%
  ) else (
    call :log Архивирование файлов %files%
    call :copmress %arch_name% %files%
    if exist %arch_name% (
      call :log Архив %arch_name% создан
      call :sync %arch_name% %mirrors%
    ) else (
      call :log Архив %arch_name% не создан
    )
  )
exit /b

:: Функция удаления "устаревших" бекапов
::
:: Вход:
::  %1 - Имя бекапа
::  %2 - Количество СОХРАНЯЕМЫХ файлов, т.е. если количество файлов превышает
::       заданное значение, они будут удалены.
:delete_old
  setlocal enabledelayedexpansion
  for %%m in (%mirrors% "%dirbackup%") do (
    set quantity=%2
    for /f "tokens=*" %%a in (' dir %%m /b ^| findstr /i "^[0-9][0-9][0-9][0-9][01][0-9][0-3][0-9]_%1[.]%arch_type%$" ^| sort /r ') do (
      if !quantity! leq 0 (
        call :log Удаляем бекап %%a в каталоге %%m
        call :rm "%%m\%%a"
      )
      set /a quantity-=1
    )
  )
  endlocal
exit /b

:: Функция логгирования
:: 
:: Вход:
::      %* Собщение
:log
  echo %date% %time% %* >> %log_file%
exit /b

:: Сжатие файлов
::
:: Вход:
::      %1 - Имя архива
::      %2 - Файл(ы) или директория(ии)
::
:copmress
  for /f "tokens=1* delims= " %%a in ("%*") do (
    set arhive_name=%%a
    set files_or_directories=%%b
  )
  %acrh% %arch_flags% %arhive_name% %files_or_directories% >> %log_file%
  echo. >> %log_file%
exit /b

:: Проверяет запусчен ли батник.
:: Если после выполнения функции
:: errorlevel равен 0 то
:: данный батник уже выполняется
:: иначе батник не запусщен
:checkrun
  tasklist /v | find %* > nul
exit /b

:: Копирует бекапы на зеркала
:: Вход:
::      %1 Файл
::      %2 Список зеркал
:sync
  for /f "tokens=1* delims= " %%a in ("%*") do (
    set file=%%a
    set mirrors=%%b
  )
  for %%m in (%mirrors%) do (
    call :log Зеркалирование %file% в %%m
    xcopy %file% %%m /y /f >> %log_file%
  )
exit /b

:: Делает листинг файлов в указанных
:: директориях
:: Вход:
::      %1 Часть названия файла отчета
::      %2 Путь до папки с отчетом
:make_report
  for /f "tokens=1* delims= " %%a in ("%*") do (
    set report_name=%%a
    set report_path=%%b
  )
  set report=%report_path%\%datestart%_%report_name%.txt
  for %%m in (%mirrors% "%dirbackup%") do (
    dir %%m >> %report%
    echo. >> %report%
  )
exit /b

:: Функция очистки лога транзакций
::
:: Вход:
::  %1 Имя файла транзикаци
::     Посмотреть его можно в свойсвах БД,
::     вкладка Transaction log
::  %2 Строка вида <username>:<password>@<host>/<databasename>, 
::     где <username> - имя пользователя БД
::         <password> - пароль к БД
::         <host> - сервер БД
::         <databasename> - имя БД
:clear_trn
  :: Проверка налчия утилиты isql по указанному адресу
  if not exist %isql% (
    call :log Предупреждение. Не найдена утилита %isql%. Бекап БД не будет выполнен.
    exit /b
  )
  for /f "tokens=1-4 delims=:@/ " %%a in ("%2") do (
    set username=%%a
    set password=%%b
    set dbserver=%%c
    set dbname=%%d
  )
  set query="DBCC SHRINKFILE(%1,2)"
  set log_srink_file= "%TEMP%\srink_file_%1.log"
  call :log Очистка журнала транзакций для БД %dbname%
  %isql% -S %dbserver% -d %dbname% -U %username% -P %password% -Q %query% -o %log_srink_file%
  type %log_srink_file% >> %log_file%
  call :rm %log_srink_file%
exit /b

:: Выполняет команду
::
:: Вход:
::  %* Команда
:exec
  call :log Выполнение команды %*
  start /wait /b %*
exit /b

:: Функция удаленя
::
:: Вход:
::      %* имя файла(ов)
:rm
  del /f /s /q %*
exit /b

:: Вывод справки
:help
  set message= ^
   " Синтаксис:" ^
   "   %filenamebat% [параметры]" ^
   " Параметры:" ^
   " /a - Действие, которое нужно выполнить. Если данный параметр задействован," ^
   "      то файл списка заданий не обрабатывается." ^
   "      Синтаксис: <название действия>:<парамерт1>:<парамерты2>" ^
   "      Возможные действия:" ^
   "      backup_mssql - создание резервной копии БД MSSQL и последующее" ^
   "      копирование ее на заркала" ^
   "      backup_mssql:backup_name:username:password@dbserver/dbname" ^
   "      checkdatabase_mssql - проверяет целостность БД" ^
   "      checkdatabase_mssql:username:password@dbserver/dbname" ^
   "      shrinkdatabase_mssql - сжатие БД" ^
   "      shrinkdatabase_mssql:username:password@dbserver/dbname" ^
   "      maintenance_mssql - Обслуживание БД, включает в себя две последовательные" ^
   "      операции: " ^
   "                1. сжатие БД" ^
   "                2. проверка целостности БД" ^
   "      maintenance_mssql:username:password@dbserver/dbname" ^
   "      backup_ntbakup - создание резервное копии с помощью утилиты ntbakup" ^
   "      и последующее копирование ее на зеркала" ^
   "      backup_ntbakup:backup_name:C:\path\to\systemstate.bks" ^
   "      backup_file - создание ахива файлов и последующее копирование его" ^
   "      на зеркала" ^
   "      backup_file:backup_name: path\to\dir1\ path\to\dir2\" ^
   "      delete_old - очистка заркал от устаревших резервных копий" ^
   "      delete_old:backup_name:100500" ^
   "      Последний параметр указывает число СОХРАНЯЕМЫХ копий, если" ^
   "      число копий больше чем данное чило, то происходит удаление" ^
   "      излишка" ^
   "      make_report - создание отчета о резервном копировании" ^
   "      make_report:name_report:\path\to\reportdir\" ^
   "      clear_trn - очистка транзакций для БД MSSQL" ^
   "      clear_trn:transaction_name:username:password@dbserver/dbname" ^
   "      очистка файла транзакций от заверщенных транзакций" ^
   " /c - Путь до файла конфигурации. Если путь содержит пробелы, то" ^
   "      следует его заключить в кавычки. Если параметр не указан" ^
   "      будет использованно значение по умолчанию:" ^
   "      %default_conf_file%" ^
   " /l - Путь до файла, содержащего инструкии для резервного копирования." ^
   "      Если путь содержит пробелы, то необходимо заключить его в кавычки." ^
   "      Если параметр на задан. будет использованно значение по умолчаню:" ^
   "      %default_log_file%" ^
   " /o - Путь до файла журнала. Если путь содержит пробелы, то следует" ^
   "      заключить его в кавачки. Если параметр на задан будет использованно" ^
   "      значение по умолчанию:" ^
   "      %default_list%" ^
   " /h - Вывод справки" ^
   " Пример:" ^
   " %filenamebat% /c:config.txt /l:list.txt /o:log.txt /a:make_report:name_report:\path\to\reportdir\"
   for %%a in (%message%) do (
     echo %%~a
   )
exit /b