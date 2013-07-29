@echo off

:: Директории СЭДов для списков отзыва
:: Пример:
::set sed_crl_dir="c:\FkServers\FkServ1\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkServMB\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkServOB\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkClients\Ap\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkClients\UfkFb\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkClients\UfkMb\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkClients\UfkOb\SUBSYS\Keys\CryptApi\COMMON\CRL\"

:: Название bat файла
set batname=%~n0

:: Директория, куда сохраняются списки отозванных сертификатов
:: В конце символ "\" не ставить
set download_dir=""

:: Название процесса
set ps_name="Process %batname%"

:: Путь до лога
set log="%batname%.log"

:: Путь до файла со списком установленных сертификатов
set db=""

:: Путь до файла конфигурации
set conf="%batname%.conf"

:: Путь до wget
set wget="%ProgramFiles%\GnuWin32\bin\wget.exe"

:: Путь до certutil
set certutil="certutil.exe"

:: Расширение списков отзыва
set crl_mask=*_new.crl

cls
call :log ================== Запуск скрипта %batname% ==================
call :checkrun %ps_name%
if %errorlevel% equ 0 (
  call :log Ошибка. %batname% уже запущен
  exit /b 1
)
title %ps_name%
if not exist %wget% (
  call :log Программа %wget% не найдена
  exit /b 1
)
if not exist %certutil% (
  call :log Программа %certutil% не найдена
  exit /b 1
)

:: Скачивание отозванных сертификатов
%wget% -a %log% -P %download_dir% -r -N -l inf -np -nd -nH -k --cut-dirs=3 --restrict-file-names=windows -A %crl_mask% http://crl.roskazna.ru/crl/
:: Установка списка отозванных сертификатов
for %%f in (%download_dir%\%crl_mask%) do (
  setlocal enabledelayedexpansion
  for /f "tokens=1-5 delims=.: "  %%a in ("%%~tf") do set mod_time=%%a%%b%%c%%d%%e
  set db_file_name="%db%!mod_time!_%%~nf.dat"
  if not exist !db_file_name! (
    call :log Установка списка отозванных сертификатов %%~nf
    echo %date% %time% > !db_file_name!
    %certutil% -addstore -user my "%%f" >> !db_file_name!
    %certutil% -addstore ca "%%f" >> !db_file_name!
    if defined sed_crl_dir (
      call :sync "%%f" %sed_crl_dir%
    )
  ) else (
    call :log Список отозванных сертификатов %%f уже установлен
  )
  endlocal enabledelayedexpansion
)
exit

:: Функция логгирования
:: Вход:
::      %* Собщение
:log
  echo %date% %time% %* >> %log%
exit /b

:: Проверяет запущен ли батник.
:: Если после выполнения функции
:: errorlevel равен 0 то
:: данный батник уже выполняется
:: иначе батник не запущен
:checkrun
  tasklist /v | find %* > nul
exit /b

:: Копирует файлы в директории
:: Вход:
::      %1 Файл
::      %2 Список директорий
:sync
  for /f "tokens=1* delims= " %%a in ("%*") do (
    set file=%%a
    set mirrors=%%b
  )
  for %%m in (%mirrors%) do (
    call :log Копирование %file% в %%m
    xcopy %file% %%m /y /f >> %log%
  )
exit /b