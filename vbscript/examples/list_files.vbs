option explicit

msgbox listmaskfiles("c:\var\log\amd.log")


function listmaskfiles(mask)

dim fso
dim folder
dim file
dim result

set fso = createobject("Scripting.FileSystemObject")
set folder = fso.getfolder(fso.getparentfoldername(mask))

for each file in folder.files
   if instr(fso.getfilename(file), fso.getfilename(mask)) = 1 then
      result = result & file & VbCrLf
   end if
next
listmaskfiles = result

end function