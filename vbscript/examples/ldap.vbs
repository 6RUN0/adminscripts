for each group in fn_groups()
 wscript.echo group
next

' Возвращает список групп в которые входит пользователь
' (от имени которого был запусчен скрипт)
function fn_groups()
  ' LDAP обязательно писать в верхнем регистре, иначе будет ошибка
  fn_groups = getobject("LDAP://" & createobject("adsysteminfo").username).getex("memberof")
end function
