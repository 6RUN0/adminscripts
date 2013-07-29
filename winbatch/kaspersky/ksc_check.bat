:: Check connect to Kaspersky Security Center
@echo off

set klnagchk="%ProgramFiles%\Kaspersky Lab\Kaspersky Security Center\klnagchk.exe"^
 "%ProgramFiles%\Kaspersky Lab\NetworkAgent\klnagchk.exe"^
 "%ProgramFiles%\Kaspersky Lab\NetworkAgent 8\klnagchk.exe"
set flags="-logfile \\smbserver\share-rw\%computername%-report.txt"^
 "-savecert \\smbserver\share-rw\%computername%-sert.cer" 

for %%p in (%klnagchk%) do (
  if exist %%p (
    for %%f in (%flags%) do (
      %%p %%~f
    )
  )
)
pause
exit