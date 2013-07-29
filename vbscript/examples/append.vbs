dim fso
dim file
dim textstream

set fso = createobject("Scripting.FileSystemObject")
fso.createtextfile "ttttt"
set file = fso.getfile("ttttt")

set textstream = file.openastextstream(8)
textstream.WriteLine "Text"
textstream.close


