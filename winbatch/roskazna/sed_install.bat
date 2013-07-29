@echo off
set install_dir=%HOMEDRIVE%\FkClnt
set run_program="%install_dir%\EXE\!cbank.bat"
set midas_dll="%install_dir%\SYSTEM\midas.dll"
set database=%install_dir%\DATA\Client.mdb

mkdir "%install_dir%"
xcopy /y /s /e . "%install_dir%"
odbcconf CONFIGDSN "Microsoft Access Driver (*.mdb)" "DSN=FK_Client|Driver=%SystemRoot%\system32\odbcjt32.dll|FIL=MS Access|DBQ=%database%"
regsvr32 /s %midas_dll%
cscript mklnk.vbs -t=%run_program% -d="Desktop" -n="ëùÑ Äè.lnk"