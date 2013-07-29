@echo off

:: название bat файла
set filenamebat=%~n0

:: путь до bat файла
set path_to_filename=%~dp0

:: путь до лога
set log_file="%path_to_filename%%filenamebat%.log"

:: путь до pid файла
set pid_file="%path_to_filename%%filenamebat%.pid"

if exist %pid_file% (
    echo ошибка. %filenamebat% уже запущен >> %log_file%
    exit /b 1
    )
echo off > %pid_file%

:: форматирование даты yyyy.mm.dd
for /f "tokens=1-3 delims=. " %%a in ('date /t') do set cur_date=%%c.%%b.%%a

:: форматирование времени hh.mm
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set cur_time=%%a.%%b

:: путь до старого лога
set old_log_file="%path_to_filename%%filenamebat%-%cur_date%-%cur_time%.log"

:: путь до программы дефрагментации
set defrag_prog="%windir%\system32\defrag.exe"

:: буква диска
set vol=c:

:: параметры дефрагментации
set defrag_prog_param=%vol% -f -v

:: выполнение дефрагментации
%defrag_prog% %defrag_prog_param% >> %log_file%

:: перемещение лога
move %log_file% %old_log_file%

:: удаление pid файла
del %pid_file%

exit /b