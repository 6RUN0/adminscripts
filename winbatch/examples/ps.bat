@echo off
set processname="pstest"
title ""
call :checkrun %processname%
echo %errorlevel% > ps.txt
if errorlevel 1 echo ok >> ps.txt
title %processname%
call :checkrun %processname%
echo %errorlevel% >> ps.txt
tasklist /v >> ps.txt
exit

:: ���� errorlevel=0 ��
:: ������ ������ ���������
:: ����� ������ �� ��������
:checkrun
  tasklist /v | find %* > nul
exit /b