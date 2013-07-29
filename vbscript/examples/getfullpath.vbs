
wscript.echo getfullpath("%programfiles%")


function getfullpath(path)
  
  dim fso

  set fso = createobject("Scripting.FileSystemObject")
  getfullpath = fso.getabsolutepathname(path)

end function