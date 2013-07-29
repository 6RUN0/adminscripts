@echo off

:: �������� bat 䠩��
set filenamebat=%~n0

:: ���� �� bat 䠩��
set path_to_filename=%~dp0

:: ���� �� ����
set log_file="%path_to_filename%%filenamebat%.log"

:: ���� �� pid 䠩��
set pid_file="%path_to_filename%%filenamebat%.pid"

if exist %pid_file% (
    echo �訡��. %filenamebat% 㦥 ����饭 >> %log_file%
    exit /b 1
    )
echo off > %pid_file%

:: �ଠ�஢���� ���� yyyy.mm.dd
for /f "tokens=1-3 delims=. " %%a in ('date /t') do set cur_date=%%c.%%b.%%a

:: �ଠ�஢���� �६��� hh.mm
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set cur_time=%%a.%%b

:: ���� �� ��ண� ����
set old_log_file="%path_to_filename%%filenamebat%-%cur_date%-%cur_time%.log"

:: ���� �� �ணࠬ�� ���ࠣ����樨
set defrag_prog="%windir%\system32\defrag.exe"

:: �㪢� ��᪠
set vol=c:

:: ��ࠬ���� ���ࠣ����樨
set defrag_prog_param=%vol% -f -v

:: �믮������ ���ࠣ����樨
%defrag_prog% %defrag_prog_param% >> %log_file%

:: ��६�饭�� ����
move %log_file% %old_log_file%

:: 㤠����� pid 䠩��
del %pid_file%

exit /b