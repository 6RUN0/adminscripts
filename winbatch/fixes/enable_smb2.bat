@echo off

reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters"^
 /v Smb2 /f