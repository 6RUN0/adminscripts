@echo off
:: Расширения файлов
set ext=.com .exe .bat .cmd .vbs .vbe .js .jse .wsh .msc .lnk
for %%a in (%ext%) do (
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%%a" /f
)
exit /b