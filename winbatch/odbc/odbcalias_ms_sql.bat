:: Скрипт создания алиасов MS SQL
@echo off

set sql_aliases="DSN=DATABASEALIAS1|Server=DATABASESERVER1|Database=DATABASENAME1|Description=DATABASE DESCRIPTION1|Trusted_Connection=NO" ^
 "DSN=DATABASEALIAS2|Server=DATABASESERVER2|Database=DATABASENAME2|Description=DATABASE DESCRIPTION2|Trusted_Connection=NO" ^
 "DSN=DATABASEALIAS3|Server=DATABASESERVER3|Database=DATABASENAME3|Description=DATABASE DESCRIPTION3|Trusted_Connection=NO" ^
 "DSN=DATABASEALIASN|Server=DATABASESERVERN|Database=DATABASENAMEN|Description=DATABASE DESCRIPTIONN|Trusted_Connection=NO" ^

:: Очистка существуюших алиасов
:: Пользовательский DSN
::reg delete "hkcu\software\odbc\odbc.ini" /f
:: Системный DSN
::reg delete "hklm\software\odbc\odbc.ini" /f
:: Создание новых алиасов
for %%a in (%sql_aliases%) do (
  odbcconf CONFIGDSN "SQL Server" %%a
)

exit /b