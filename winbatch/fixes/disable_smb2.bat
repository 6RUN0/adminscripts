@echo off

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters"^
 /v Smb2 /t REG_DWORD /d 0 /f