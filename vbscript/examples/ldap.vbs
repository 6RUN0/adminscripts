for each group in fn_groups()
 wscript.echo group
next

' ���������� ������ ����� � ������� ������ ������������
' (�� ����� �������� ��� �������� ������)
function fn_groups()
  ' LDAP ����������� ������ � ������� ��������, ����� ����� ������
  fn_groups = getobject("LDAP://" & createobject("adsysteminfo").username).getex("memberof")
end function
