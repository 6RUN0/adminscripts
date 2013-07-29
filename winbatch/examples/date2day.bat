@echo off

call :date2day "1.1.2012"
set begindate=%date2day%
call :date2day "12.9.2012"
set enddate=%date2day%
set /a diffday=%enddate%-%begindate%+1
echo %diffday%
pause
exit

:date2day
  for /f "tokens=1-3 delims=." %%a in ("%*") do (
    set year=%%c
    set month=%%b
    set day=%%a
  )
  set leap_year=4
  set month31=1 3 5 7 8 10 12
  set month30=4 6 9 11
  set /a residual=%year%%%leap_year%
  set /a num_leap_year=%year%/%leap_year%
  set /a days_in_year=%year%*365+%num_leap_year%
  set /a num_full_month=%month%-1
  set days_in_month=0
  for /l %%m in (1,1,%num_full_month%) do (
    for %%i in (%month31%) do (
      if %%m==%%i (
        set /a days_in_month+=31
      )
    )
    for %%i in (%month30%) do (
      if %%m==%%i (
        set /a days_in_month+=30
      )
    )
    if %%m==2 (
      if %residual%==0 (
        set /a days_in_month+=29
      ) else (
        set /a days_in_month+=28
      )
    )
  )
  set /a date2day=%day%+%days_in_month%+%days_in_year%
exit /b

:day2date
  set day=%*
  set /a year=4*%day%/1461
  echo %year%
exit /b