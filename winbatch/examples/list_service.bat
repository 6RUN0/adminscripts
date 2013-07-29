@echo off
for /f "tokens=1* delims=: " %%a in (' sc query type^= service state^= all ^| find "SERVICE_NAME" ') do (
  for /f "tokens=1,2* delims=: " %%i in (' sc qc %%b ^| find "START_TYPE" ') do (
    echo %%b -- %%i -- %%j -- %%k 
  )
)
pause