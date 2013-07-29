@echo off

set list_share=Z$ Y$ X$ W$ V$ U$ T$ S$ R$ Q$ P$ O$ N$ M$ L$ K$ J$ I$ H$ G$ F$ E$ D$ C$ B$ A$ admin$

:: Удаление админских шар
reg add "hklm\system\CurrentControlSet\Services\LanmanServer\Parameters" ^
 /v AutoShareWks /t REG_DWORD /d 0 /f
reg add "hklm\system\CurrentControlSet\Services\LanmanServer\Parameters" ^
 /v AutoShareServer /t REG_DWORD /d 0 /f
for %%a in (%list_share%) do (
   net share %%a /delete
)

:: Отключение автозапуска
:: Значение по умолчанию подраздела NoDriveTypeAutoRun 
:: Microsoft Windows Server 2003	0x95
:: Microsoft Windows XP	0x91
:: Microsoft Windows 2000	0x95
reg delete "hkcu\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer" ^
 /v NoDriveTypeAutorun /f
reg add "hkcu\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer" ^
 /v NoDriveTypeAutorun /t REG_DWORD /d 0xff /f
reg delete "hku\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer" ^
 /v NoDriveTypeAutorun /f
reg add "hku\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer" ^
 /v NoDriveTypeAutorun /t REG_DWORD /d 0xff /f

exit