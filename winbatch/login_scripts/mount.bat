@echo off

:: Алфавит в обратном порядке
:: Z Y X W V U T S R Q P O N M L K J I H G F E D C B A
set shares="Z: "\\fileserver1\share1" " ^
 "Y: "\\fileserver1\share2" " ^
 "X: "\\fileserver1\share3" " ^
 "W: "\\fileserver2\share1" " ^
 "V: "\\fileserver2\share2" " ^
 "U: "\\fileserver2\share3" " ^
 "T: "\\fileserver3\share1" "

net time \\PDC /set /yes || net time \\RDC /set /yes
net use * /delete /yes
for %%a in (%shares%) do (
  net use %%~a
)
exit