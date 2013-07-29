
wscript.echo exists_folder("\\Pc77\c$\Documents and Settings\")


function exists_folder(path)

  dim fso

  set fso = createobject("Scripting.FileSystemObject")
  exists_folder = fso.folderexists(path)

end function