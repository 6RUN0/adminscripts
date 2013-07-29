option explicit


msgbox sizefile("rotatelogs.conf","K")


' path - путь дофайла
' metr - ед. измерения, возможние значения:
' K - Килобайт 2 ^ 10 = 1024
' M - Мегабайт 2 ^ 20 = 1048576
' G - Гигабайт 2 ^ 30 = 1073741824
' T - Террабайт 2 ^ 40 = 1099511627776
function sizefile(path, metr)

dim fso
dim file

set fso = createobject("Scripting.FileSystemObject")
set file = fso.getfile(path)
if metr = "K" then
   sizefile = file.size/1024
elseif metr = "M" then
   sizefile = file.size/1048576
elseif metr = "G" then
   sizefile = file.size/1073741824
elseif metr = "T" then
   sizefile = file.size/1099511627776
else 
   sizefile = file.size 
end if

end function