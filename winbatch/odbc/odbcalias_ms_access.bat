:: ������ �������� ������� Microsoft Access
@echo off

set sql_aliases="DSN=DATABASEALIAS1|Driver=%SystemRoot%\system32\odbcjt32.dll|FIL=MS Access|DBQ=C:\path\to\file1.mdb" ^
 "DSN=DATABASEALIAS2|Driver=%SystemRoot%\system32\odbcjt32.dll|FIL=MS Access|DBQ=C:\path\to\file2.mdb" ^
 "DSN=DATABASEALIAS3|Driver=%SystemRoot%\system32\odbcjt32.dll|FIL=MS Access|DBQ=C:\path\to\file3.mdb" ^
 "DSN=DATABASEALIASN|Driver=%SystemRoot%\system32\odbcjt32.dll|FIL=MS Access|DBQ=C:\path\to\fileN.mdb" ^

:: ������� ������������ �������
:: ���������������� DSN
::reg delete "hkcu\software\odbc\odbc.ini" /f
:: ��������� DSN
::reg delete "hklm\software\odbc\odbc.ini" /f
:: �������� ����� �������
for %%a in (%sql_aliases%) do (
  odbcconf CONFIGDSN "Microsoft Access Driver (*.mdb)" %%a
)

exit /b