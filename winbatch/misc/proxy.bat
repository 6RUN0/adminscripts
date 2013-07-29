@echo off

set proxy_override= "*.localdomain.local;192.168.1.*;<local>"

:: Примеры:
::set proxy_server= "ftp=192.168.1.1:21;http=192.168.1.1:80;https=192.168.1.1:445;socks=192.168.1.1:1080"
set proxy_server="http=192.168.1.1:80"

:: Отключить прокси
::set proxy_enable= "0"
:: Включить прокси
set proxy_enable= "1"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d %proxy_override% /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d %proxy_server% /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d %proxy_enable% /f