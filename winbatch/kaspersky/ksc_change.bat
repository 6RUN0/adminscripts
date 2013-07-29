:: Change the Administration Server Kaspersky Security Center
@echo off

set klmover="%ProgramFiles%\Kaspersky Lab\NetworkAgent\klmover.exe"^
 "%ProgramFiles%\Kaspersky Lab\NetworkAgent 8\klmover.exe"
set flags=-address NEWSERVER

for %%p in (%klmover%) do (
  if exist %%p (
    %%p %flags%
  )
)
pause
exit