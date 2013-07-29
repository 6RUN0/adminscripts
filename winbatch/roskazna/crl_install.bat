@echo off

:: ��४�ਨ ����� ��� ᯨ᪮� ��뢠
:: �ਬ��:
::set sed_crl_dir="c:\FkServers\FkServ1\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkServMB\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkServOB\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkClients\Ap\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkClients\UfkFb\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkClients\UfkMb\SUBSYS\Keys\CryptApi\COMMON\CRL\" ^
:: "c:\FkServers\FkClients\UfkOb\SUBSYS\Keys\CryptApi\COMMON\CRL\"

:: �������� bat 䠩��
set batname=%~n0

:: ��४���, �㤠 ��࠭����� ᯨ᪨ �⮧������ ���䨪�⮢
:: � ���� ᨬ��� "\" �� �⠢���
set download_dir=""

:: �������� �����
set ps_name="Process %batname%"

:: ���� �� ����
set log="%batname%.log"

:: ���� �� 䠩�� � ᯨ᪮� ��⠭�������� ���䨪�⮢
set db=""

:: ���� �� 䠩�� ���䨣��樨
set conf="%batname%.conf"

:: ���� �� wget
set wget="%ProgramFiles%\GnuWin32\bin\wget.exe"

:: ���� �� certutil
set certutil="certutil.exe"

:: ����७�� ᯨ᪮� ��뢠
set crl_mask=*_new.crl

cls
call :log ================== ����� �ਯ� %batname% ==================
call :checkrun %ps_name%
if %errorlevel% equ 0 (
  call :log �訡��. %batname% 㦥 ����饭
  exit /b 1
)
title %ps_name%
if not exist %wget% (
  call :log �ணࠬ�� %wget% �� �������
  exit /b 1
)
if not exist %certutil% (
  call :log �ணࠬ�� %certutil% �� �������
  exit /b 1
)

:: ���稢���� �⮧������ ���䨪�⮢
%wget% -a %log% -P %download_dir% -r -N -l inf -np -nd -nH -k --cut-dirs=3 --restrict-file-names=windows -A %crl_mask% http://crl.roskazna.ru/crl/
:: ��⠭���� ᯨ᪠ �⮧������ ���䨪�⮢
for %%f in (%download_dir%\%crl_mask%) do (
  setlocal enabledelayedexpansion
  for /f "tokens=1-5 delims=.: "  %%a in ("%%~tf") do set mod_time=%%a%%b%%c%%d%%e
  set db_file_name="%db%!mod_time!_%%~nf.dat"
  if not exist !db_file_name! (
    call :log ��⠭���� ᯨ᪠ �⮧������ ���䨪�⮢ %%~nf
    echo %date% %time% > !db_file_name!
    %certutil% -addstore -user my "%%f" >> !db_file_name!
    %certutil% -addstore ca "%%f" >> !db_file_name!
    if defined sed_crl_dir (
      call :sync "%%f" %sed_crl_dir%
    )
  ) else (
    call :log ���᮪ �⮧������ ���䨪�⮢ %%f 㦥 ��⠭�����
  )
  endlocal enabledelayedexpansion
)
exit

:: �㭪�� �����஢����
:: �室:
::      %* ���饭��
:log
  echo %date% %time% %* >> %log%
exit /b

:: �஢���� ����饭 �� ��⭨�.
:: �᫨ ��᫥ �믮������ �㭪樨
:: errorlevel ࠢ�� 0 �
:: ����� ��⭨� 㦥 �믮������
:: ���� ��⭨� �� ����饭
:checkrun
  tasklist /v | find %* > nul
exit /b

:: ������� 䠩�� � ��४�ਨ
:: �室:
::      %1 ����
::      %2 ���᮪ ��४�਩
:sync
  for /f "tokens=1* delims= " %%a in ("%*") do (
    set file=%%a
    set mirrors=%%b
  )
  for %%m in (%mirrors%) do (
    call :log ����஢���� %file% � %%m
    xcopy %file% %%m /y /f >> %log%
  )
exit /b