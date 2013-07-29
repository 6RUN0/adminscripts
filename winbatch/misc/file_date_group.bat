:: Скрипт группирует фалы по дате создания
@echo off
set folder=E:\Scanner\
set mask=*

for %%f in ("%folder%%mask%") do (
  for /f "tokens=1-3 delims=.: " %%i in ("%%~tf") do (
    mkdir "%folder%%%k\%%j"
    move /y "%%f" "%folder%%%k\%%j"
  )
)
exit