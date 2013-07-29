:: ����� 1.4.5 betta
@echo off
:: �������� bat 䠩��
set filenamebat=%~n0
:: �������� �����
set ps_name="Process %filenamebat%"
:: ���� �� ����
set default_log_file="%filenamebat%.log"
:: ���� �� 䠩�� ���䨣��樨
set default_conf_file="%filenamebat%.conf"
:: ���᮪ ��६�����, ����� �������� � ���䨣��樮���� 䠩��
:: � �஢������� �� ��������
set varlist=arch_type arch_flags dirbackup
:: ���� �� ᯨ᪠
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
  call :log �訡��. %filenamebat% 㦥 ����饭
  exit /b 1
)
title %ps_name%
call :get_date
set datestart=%getdate%
call :log ===== ��稭��� १�ࢭ�� ����஢���� =====
if not exist %conf_file% (
  call :log �訡�� ���� ���䨣��樨 %conf_file% �� ������
  exit /b 1
)
if not exist %list% (
  call :log �訡��. ���᮪ 䠩��� %list% �� ������
  exit /b 1
)
call :log ���뢠��� ��ࠬ��஢ �� ���䨣��樨 %conf_file%
:: ��ࠡ�⪠ 䠩�� c ����ன����
for /f "usebackq eol=# delims==  tokens=1*" %%a in (%conf_file%) do (
  call :log %%a=%%b
  set %%a=%%b
)
:: �஢�ઠ ��६����� �� ���⮥ ���祭��
for %%a in (%varlist%) do (
  if not defined %%a (
    call :log �訡��. ��ࠬ��� %%a �� ��।����
    exit /b 1
  )
)
:: �஢�ઠ ����� ��娢��� �� 㪠������� �����
if not exist %acrh% (
  call :log �訡��. �� ������ ��娢��� %acrh%
  exit /b 1
)
:: ��ࠡ�⪠ ���⢨� ��।����� ��� ��㬥��
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
:: ��ࠡ�⪠ ᯨ᪠
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
:: ���ᠭ�� "�㭪権"
::

:: ��ଠ�஢���� ���� YYYYMMDD
:get_date
  for /f "tokens=1-3 delims=.-/ " %%a in ("%date%") do set getdate=%%c%%b%%a
exit /b

:: ��ଠ�஢���� �६��� HH.MM.ss.mm
:get_time
  for /f "tokens=1-4 delims=:, " %%a in ("%time%") do set gettime=%%a.%%b.%%c.%%d
exit /b

:: �㭪�� ������ �� MSSQL
::
:: �室:
::  %1 ��� ��娢�
::  %2 ��ப� ���� <username>:<password>@<host>/<databasename>, 
::     ��� <username> - ��� ���짮��⥫� ��
::         <password> - ��஫� � ��
::         <host> - �ࢥ� ��
::         <databasename> - ��� ��
:backup_mssql
  :: �஢�ઠ ����� �⨫��� isql �� 㪠������� �����
  if not exist %isql% (
    call :log �।�०�����. �� ������� �⨫�� %isql%. ����� �� �� �㤥� �믮����.
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
    call :log �।�०�����. ����ࢭ�� ����� �� %dbname% �ࢥ� %dbserver% �� %datestart% 㦥 ᤥ����� %arch_name%
  ) else (
    call :log �������� १�ࢭ�� ����� ���� ������ %dbname% � 䠩� %bak_file%
    %isql% -S %dbserver% -d %dbname% -U %username% -P %password% -Q %query% -o %log_bak_file%
    type %log_bak_file% >> %log_file%
    if exist %bak_file% (
      call :log ����ࢭ�� ����� %bak_file% ᮧ����
      call :log ��娢�஢���� %bak_file%, %log_bak_file%
      call :copmress %arch_name% %bak_file% %log_bak_file%
      if exist %arch_name% (
        call :log ��娢 %arch_name% ᮧ���
        call :rm %bak_file%
        call :rm %log_bak_file%
        call :sync %arch_name% %mirrors%
      ) else (
        call :log ��娢 %arch_name% �� ᮧ���
      )
    ) else (
      call :log ����ࢭ�� ����� %bak_file% �� ᮧ����
    )
  )
exit /b

:: �஢���� �������� � 䨧����� 楫��⭮��� ��ꥪ⮢ � ��
::
:: �室:
::  %* ��ப� ���� <username>:<password>@<host>/<databasename>, 
::     ��� <username> - ��� ���짮��⥫� ��
::         <password> - ��஫� � ��
::         <host> - �ࢥ� ��
::         <databasename> - ��� ��
:checkdatabase_mssql
  if not exist %isql% (
    call :log �।�०�����. �� ������� �⨫�� %isql%. �஢�ઠ �� �� �㤥� �믮�����.
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
  call :log �஢�ઠ ���� ������ %dbname%
  %isql% -S %dbserver% -d %dbname% -U %username% -P %password% -Q %query% -o %log_query%
  type %log_query% >> %log_file%
  call :rm %log_query%
exit /b

:: ����頥� ࠧ��� 䠩��� ������ � 䠩��� ��ୠ�� � 㪠������ ���� ������.
::
:: �室:
::  %* ��ப� ���� <username>:<password>@<host>/<databasename>, 
::     ��� <username> - ��� ���짮��⥫� ��
::         <password> - ��஫� � ��
::         <host> - �ࢥ� ��
::         <databasename> - ��� ��
:shrinkdatabase_mssql
  if not exist %isql% (
    call :log �।�०�����. �� ������� �⨫�� %isql%. ���⨥ �� �� �㤥� �믮�����.
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
  call :log ���⨥ ���� ������ %dbname%
  %isql% -S %dbserver% -d %dbname% -U %username% -P %password% -Q %query% -o %log_query%
  type %log_query% >> %log_file%
  call :rm %log_query%
exit /b

:: �㭪�� ������ 䠩��� *.bks
::
:: �室:
::  %1 ��� ��娢�
::  %2 ����� ���� �� bks 䠩��
:backup_ntbakup
  :: �஢�ઠ ����� ntbackup �� 㪠������� �����
  if not exist %ntbackup% (
    call :log �।�०�����. �� ������� �ணࠬ�� %ntbackup%. ntbackup �� �㤥� �믮����
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
    call :log �।�०�����. ����ࢭ�� ����� %name% �� %datestart% 㦥 ᤥ����� %arch_name%
  ) else (
    call :log �������� १�ࢭ�� ����� %name% � 䠩�  %bkf_file%
    %ntbackup% backup "@%bksfile%" /J "%name%" /F %bkf_file% /V:yes /L:f /M normal /SNAP:on
    if exist %bkf_file% (
      call :log ����ࢭ�� ����� %bkf_file% ᮧ����
      call :log ��娢�஢���� %bkf_file%
      call :copmress %arch_name% %bkf_file% %log_bkf_file%
      if exist %arch_name% (
        call :log ��娢 %arch_name% ᮧ���
        call :sync %arch_name% %mirrors%
        call :rm %bkf_file%
        call :rm %log_bkf_file%
      ) else (
        call :log ��娢 %arch_name% �� ᮧ���
      )
    ) else (
      call :log ����ࢭ�� ����� %bkf_file% �� ᮧ����
    )
  )
exit /b

:: �㭪�� ������ 䠩�(��)
::
:: �室:
::  %1 ��� ��娢�
::  %2 ���᮪ 䠩���, ����� 䠩� ������ ���� �����祭 � ����窨, ࠧ����⥫� ����� 䠩���� - �஡��
:backup_file
  for /f "tokens=1* delims= " %%a in ("%*") do (
    set name=%%a
    set files=%%b
  )
  set arch_name="%dirbackup%\%datestart%_%name%.%arch_type%"
  if exist %arch_name% (
    call :log �।�०�����. ����ࢭ�� ����� 䠩��� %files% �� %datestart% 㦥 ᤥ����� %arch_name%
  ) else (
    call :log ��娢�஢���� 䠩��� %files%
    call :copmress %arch_name% %files%
    if exist %arch_name% (
      call :log ��娢 %arch_name% ᮧ���
      call :sync %arch_name% %mirrors%
    ) else (
      call :log ��娢 %arch_name% �� ᮧ���
    )
  )
exit /b

:: �㭪�� 㤠����� "���ॢ��" �������
::
:: �室:
::  %1 - ��� ������
::  %2 - ������⢮ ����������� 䠩���, �.�. �᫨ ������⢮ 䠩��� �ॢ�蠥�
::       �������� ���祭��, ��� ���� 㤠����.
:delete_old
  setlocal enabledelayedexpansion
  for %%m in (%mirrors% "%dirbackup%") do (
    set quantity=%2
    for /f "tokens=*" %%a in (' dir %%m /b ^| findstr /i "^[0-9][0-9][0-9][0-9][01][0-9][0-3][0-9]_%1[.]%arch_type%$" ^| sort /r ') do (
      if !quantity! leq 0 (
        call :log ����塞 ����� %%a � ��⠫��� %%m
        call :rm "%%m\%%a"
      )
      set /a quantity-=1
    )
  )
  endlocal
exit /b

:: �㭪�� �����஢����
:: 
:: �室:
::      %* ���饭��
:log
  echo %date% %time% %* >> %log_file%
exit /b

:: ���⨥ 䠩���
::
:: �室:
::      %1 - ��� ��娢�
::      %2 - ����(�) ��� ��४���(��)
::
:copmress
  for /f "tokens=1* delims= " %%a in ("%*") do (
    set arhive_name=%%a
    set files_or_directories=%%b
  )
  %acrh% %arch_flags% %arhive_name% %files_or_directories% >> %log_file%
  echo. >> %log_file%
exit /b

:: �஢���� �����祭 �� ��⭨�.
:: �᫨ ��᫥ �믮������ �㭪樨
:: errorlevel ࠢ�� 0 �
:: ����� ��⭨� 㦥 �믮������
:: ���� ��⭨� �� �����饭
:checkrun
  tasklist /v | find %* > nul
exit /b

:: ������� ������ �� ��ઠ��
:: �室:
::      %1 ����
::      %2 ���᮪ ��ઠ�
:sync
  for /f "tokens=1* delims= " %%a in ("%*") do (
    set file=%%a
    set mirrors=%%b
  )
  for %%m in (%mirrors%) do (
    call :log ��ઠ��஢���� %file% � %%m
    xcopy %file% %%m /y /f >> %log_file%
  )
exit /b

:: ������ ���⨭� 䠩��� � 㪠������
:: ��४����
:: �室:
::      %1 ����� �������� 䠩�� ����
::      %2 ���� �� ����� � ���⮬
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

:: �㭪�� ���⪨ ���� �࠭���権
::
:: �室:
::  %1 ��� 䠩�� �࠭�����
::     ��ᬮ���� ��� ����� � ᢮�ᢠ� ��,
::     ������� Transaction log
::  %2 ��ப� ���� <username>:<password>@<host>/<databasename>, 
::     ��� <username> - ��� ���짮��⥫� ��
::         <password> - ��஫� � ��
::         <host> - �ࢥ� ��
::         <databasename> - ��� ��
:clear_trn
  :: �஢�ઠ ����� �⨫��� isql �� 㪠������� �����
  if not exist %isql% (
    call :log �।�०�����. �� ������� �⨫�� %isql%. ����� �� �� �㤥� �믮����.
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
  call :log ���⪠ ��ୠ�� �࠭���権 ��� �� %dbname%
  %isql% -S %dbserver% -d %dbname% -U %username% -P %password% -Q %query% -o %log_srink_file%
  type %log_srink_file% >> %log_file%
  call :rm %log_srink_file%
exit /b

:: �믮���� �������
::
:: �室:
::  %* �������
:exec
  call :log �믮������ ������� %*
  start /wait /b %*
exit /b

:: �㭪�� 㤠����
::
:: �室:
::      %* ��� 䠩��(��)
:rm
  del /f /s /q %*
exit /b

:: �뢮� �ࠢ��
:help
  set message= ^
   " ���⠪��:" ^
   "   %filenamebat% [��ࠬ����]" ^
   " ��ࠬ����:" ^
   " /a - ����⢨�, ���஥ �㦭� �믮�����. �᫨ ����� ��ࠬ��� ������⢮���," ^
   "      � 䠩� ᯨ᪠ ������� �� ��ࠡ��뢠����." ^
   "      ���⠪��: <�������� ����⢨�>:<��ࠬ���1>:<��ࠬ����2>" ^
   "      �������� ����⢨�:" ^
   "      backup_mssql - ᮧ����� १�ࢭ�� ����� �� MSSQL � ��᫥���饥" ^
   "      ����஢���� �� �� ��ઠ��" ^
   "      backup_mssql:backup_name:username:password@dbserver/dbname" ^
   "      checkdatabase_mssql - �஢���� 楫��⭮��� ��" ^
   "      checkdatabase_mssql:username:password@dbserver/dbname" ^
   "      shrinkdatabase_mssql - ᦠ⨥ ��" ^
   "      shrinkdatabase_mssql:username:password@dbserver/dbname" ^
   "      maintenance_mssql - ���㦨����� ��, ����砥� � ᥡ� ��� ��᫥����⥫��" ^
   "      ����樨: " ^
   "                1. ᦠ⨥ ��" ^
   "                2. �஢�ઠ 楫��⭮�� ��" ^
   "      maintenance_mssql:username:password@dbserver/dbname" ^
   "      backup_ntbakup - ᮧ����� १�ࢭ�� ����� � ������� �⨫��� ntbakup" ^
   "      � ��᫥���饥 ����஢���� �� �� ��ઠ��" ^
   "      backup_ntbakup:backup_name:C:\path\to\systemstate.bks" ^
   "      backup_file - ᮧ����� �娢� 䠩��� � ��᫥���饥 ����஢���� ���" ^
   "      �� ��ઠ��" ^
   "      backup_file:backup_name: path\to\dir1\ path\to\dir2\" ^
   "      delete_old - ���⪠ ��ઠ� �� ���ॢ�� १�ࢭ�� �����" ^
   "      delete_old:backup_name:100500" ^
   "      ��᫥���� ��ࠬ��� 㪠�뢠�� �᫮ ����������� �����, �᫨" ^
   "      �᫮ ����� ����� 祬 ������ 稫�, � �ந�室�� 㤠�����" ^
   "      ����誠" ^
   "      make_report - ᮧ����� ���� � १�ࢭ�� ����஢����" ^
   "      make_report:name_report:\path\to\reportdir\" ^
   "      clear_trn - ���⪠ �࠭���権 ��� �� MSSQL" ^
   "      clear_trn:transaction_name:username:password@dbserver/dbname" ^
   "      ���⪠ 䠩�� �࠭���権 �� �����饭��� �࠭���権" ^
   " /c - ���� �� 䠩�� ���䨣��樨. �᫨ ���� ᮤ�ন� �஡���, �" ^
   "      ᫥��� ��� �������� � ����窨. �᫨ ��ࠬ��� �� 㪠���" ^
   "      �㤥� �ᯮ�짮����� ���祭�� �� 㬮�砭��:" ^
   "      %default_conf_file%" ^
   " /l - ���� �� 䠩��, ᮤ�ঠ饣� �����㪨� ��� १�ࢭ��� ����஢����." ^
   "      �᫨ ���� ᮤ�ন� �஡���, � ����室��� �������� ��� � ����窨." ^
   "      �᫨ ��ࠬ��� �� �����. �㤥� �ᯮ�짮����� ���祭�� �� 㬮�砭�:" ^
   "      %default_log_file%" ^
   " /o - ���� �� 䠩�� ��ୠ��. �᫨ ���� ᮤ�ন� �஡���, � ᫥���" ^
   "      �������� ��� � ����窨. �᫨ ��ࠬ��� �� ����� �㤥� �ᯮ�짮�����" ^
   "      ���祭�� �� 㬮�砭��:" ^
   "      %default_list%" ^
   " /h - �뢮� �ࠢ��" ^
   " �ਬ��:" ^
   " %filenamebat% /c:config.txt /l:list.txt /o:log.txt /a:make_report:name_report:\path\to\reportdir\"
   for %%a in (%message%) do (
     echo %%~a
   )
exit /b