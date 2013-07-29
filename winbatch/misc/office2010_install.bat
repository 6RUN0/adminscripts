@echo off
:: Надо на ком-н протестить
set ProductName=Office14.PROPLUS
:: set ProductName=Office14.STANDARD
set DeployServer="\\line\distr\editors\microsoft office\SW_DVD5_Office_Professional_Plus_2010w_SP1_W32_Russian_CORE_MLF_X17-76999"
:: set DeployServer="\\line\distr\editors\microsoft office\sw_dvd5_office_2010w_sp1_w32_russian_core_mlf_x17-82148"
set ConfigFile="%DeployServer%\ProPlus.WW\config.xml"
:: set ConfigFile="%DeployServer%\Standard.WW\config.xml"

reg query "HKLM\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall\%ProductName%" && exit 0
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ProductName%" && exit 0

"%DeployServer%\setup.exe" /config %ConfigFile%
exit 0