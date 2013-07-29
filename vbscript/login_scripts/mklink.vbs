option explicit

const CREATE_FLAG = "-c"
const DELETE_FLAG = "-d"
const HELP_FLAG = "-h"
const LIST_FLAG = "-l"
const EQUAL = "="
const DEFAULT_LIST_LINKS = "links.txt"
const SEPARATOR = "|"
const QUANTITY_COLUMNS = 5
const NUMBER_OF_FOLDER = 1
const NUMBER_OF_LINKTARGET = 2
const NUMBER_OF_LINKMANE = 0
const NUMBER_OF_LINKOWNGROUP = 4
const NUMBER_OF_FLAGS = 3
const EXTENSION = ".lnk"

dim obj_textstream
dim str_location
dim str_line, str_word
dim str_folder, str_linktarget, str_linkmane, str_linkowngroup, str_link, str_flags
dim groups, group
dim str_flag, str_argument, int_size_of_flag
dim str_left_part, str_right_part
dim str_actcion_flag, str_list_file
dim help

help = wscript.scriptname & " - ������� ������" & VBNEWLINE & _
       "�������������: " & VBNEWLINE & _
       wscript.scriptname & " [-c|-d|-h] [-l=<��� �����>]" & VBNEWLINE & _
       " -c  ������� ������." & VBNEWLINE & _
       " -d  ������� ������." & VBNEWLINE & _
       "     ���� ����� -c ��� -d �� �������, �� ������ ������� ������" & VBNEWLINE & _
       " -h  �������." & VBNEWLINE & _
       " -l  ����, ���������� ������ �������. �������� �� ��������� " & DEFAULT_LIST_LINKS & VBNEWLINE & _
       "     ��������� �����:" & VBNEWLINE & _
       "       <��� ������>|<��� ���� ����� Windows>|<���� �� ������� ��������� �����>|<��������� �������>|<������ AD>" & VBNEWLINE & _
       "       ���" & VBNEWLINE & _
       "       <��� ������> - �������� �������� �����;" & VBNEWLINE & _
       "       <��� ����������� ����� Windows>" & VBNEWLINE & _
       "       ���������� ��������:" & VBNEWLINE & _
       "        AllUsersDesktop - ������� ���� ���� �������������" & VBNEWLINE & _
       "        AllUsersStartMenu - ���� ���� ���� �������������" & VBNEWLINE & _
       "        AllUsersPrograms - ��� ��������� � ���� ���� ���� �������������" & VBNEWLINE & _
       "        AllUsersStartup - ������������ ��� ���� �������������" & VBNEWLINE & _
       "        Desktop - ������� ���� �������� ������������" & VBNEWLINE & _
       "        Favorites - ���������" & VBNEWLINE & _
       "        Fonts - ������" & VBNEWLINE & _
       "        MyDocuments - ��� ��������� �������� ������������" & VBNEWLINE & _
       "        NetHood - ����� ������� ���������" & VBNEWLINE & _
       "        PrintHood - ����� �������� � �����" & VBNEWLINE & _
       "        Programs - ��� ��������� � ���� ���� �������� ������������" & VBNEWLINE & _
       "        Recent - �������� ���������" & VBNEWLINE & _
       "        SendTo - ���� ���������" & VBNEWLINE & _
       "        StartMenu - ���� ���� �������� ������������" & VBNEWLINE & _
       "        Startup - ������������ �������� ������������" & VBNEWLINE & _
       "        Template - �������." & VBNEWLINE & _
       "        ���� �������� �� ����� ��� ����� �� ���������, �� ������ �� ����� �������." & VBNEWLINE & _
       "       <���� �� ������� ��������� �����> - ������ ���� �� �����(�����) , ��� ��������(��) ��������� �����" & VBNEWLINE & _
       "       <��������� �������> - ��������� �������, ��������� �� �����������" & VBNEWLINE & _
       "       <������ AD> - ������ ������������� � Active Directory." & VBNEWLINE & _
       "       ������:" & VBNEWLINE & _
       "       naname00|MyDocuments|q:\EXE\!cbank.bat||CN=Administrators,CN=Users,DC=localdomain,DC=local" & VBNEWLINE & _
       "       naname01|MyDocuments|q:\EXE\!cbank.bat|/c:..\cfgs\%USERNAME%.cfg|CN=Administrators,CN=Users,DC=localdomain,DC=local" & VBNEWLINE & _
        VBNEWLINE
str_list_file = DEFAULT_LIST_LINKS
str_actcion_flag = CREATE_FLAG
for each str_argument in wscript.arguments
  str_flag=split(str_argument,EQUAL,2)
  int_size_of_flag = ubound(str_flag)
  if int_size_of_flag = 1 then
    str_left_part=str_flag(0)
    str_right_part=str_flag(1)
  end if
  if int_size_of_flag = 0 then
    str_left_part=str_argument
    str_right_part=VBNULLSTRING
  end if
  select case str_left_part
    case CREATE_FLAG
      str_actcion_flag = CREATE_FLAG
    case DELETE_FLAG
      str_actcion_flag = DELETE_FLAG
    case LIST_FLAG
      str_list_file = str_right_part
    case HELP_FLAG
      wscript.echo help
      wscript.quit
    case else 
      wscript.echo "����������� ���������: "  & str_left_part & VBNEWLINE & _
                   help
      wscript.quit
  end select 
next
if not fn_file_exist(str_list_file) then
  wscript.echo "���� " & str_list_file & " �� ������"
  wscript.quit
end if
set obj_textstream = createobject("scripting.filesystemobject").opentextfile(str_list_file)
groups = fn_groups()
while not obj_textstream.atendofstream
  str_line = trim(replace(obj_textstream.readline(),VBTAB," "))
  if (str_line <> " ") and (str_line <> VBNULLSTRING) then
    str_word = split(str_line,SEPARATOR,QUANTITY_COLUMNS)
    if ubound(str_word) = QUANTITY_COLUMNS - 1 then
      str_folder = trim(str_word(NUMBER_OF_FOLDER))
      str_flags = trim(str_word(NUMBER_OF_FLAGS))
      str_linktarget = trim(str_word(NUMBER_OF_LINKTARGET))
      str_linkmane = trim(str_word(NUMBER_OF_LINKMANE))
      str_linkowngroup = trim(str_word(NUMBER_OF_LINKOWNGROUP))
      str_location = wscript.createobject("wscript.shell").specialfolders(str_folder) & "\"
      str_link = str_location & str_linkmane & EXTENSION
      if fn_is_path(str_linktarget) and _
      (str_linkmane <> VBNULLSTRING) and _
      (str_location <> VBNULLSTRING) then
        if str_actcion_flag = CREATE_FLAG then
          for each group in groups
            if str_linkowngroup = group then
              sub_create_link str_linktarget, str_flags, str_link
            end if
          next
        end if
        if str_actcion_flag = DELETE_FLAG and _
        fn_file_exist(str_link) then
          sub_delete_file(str_link)
        end if
      end if
    end if
  end if
wend
wscript.quit

' ������� ������
' ���������:
'   target - ���� �� ������� ��������� �����
'   flags - ����� �������
'   link - ������������ ������
sub sub_create_link(target, flags, link)
  with wscript.createobject("wscript.shell").createshortcut(link)
    .targetpath = target
    .arguments = flags
    .workingdirectory = fn_get_parent(target)
    .save
  end with
end sub

' �������� ������������� �����
' ���� ���� ���������� ���������� ture
' ����� false
' ���������:
'   file - ���� �� �����
function fn_file_exist(file)
  fn_file_exist = createobject("scripting.filesystemobject").fileexists(file)
end function

' ���������� ������������ �������
' ���������:
'   file - ���� �� �����
function fn_get_parent(file)
  fn_get_parent = createobject("scripting.filesystemobject").getfile(file).parentfolder.path
end function

' ���� str �������� ����� � �����/�����
' �� ������� ���������� true, ����� false
' ���������:
'   str - ������
function fn_is_path(str)
  const PATTERN = "^(\.\.|\.|[a-z]\:|\\\\[^\\/*|?<>:\x22]{1,256}){0,1}(\\[^\\/*|?<>:\x22]{1,256}){0,32000}$"
  fn_is_path = fn_regexp_test(str,PATTERN,TRUE,TRUE,FALSE)
end function

'str - C�����, ��� ������
'pattern - ������, ������������ ��� ������.
'global - ����� (������). False - ��������� �� ������� ������������,
' True - ��������� �� ����� ������. �� ��������� - False. 
'ignorecase - ����� (������). False - ��������� ������� ��������,
' True - ������������ ������� ��������. �� ��������� - False. 
'multiline - ����� (������). False - ������������ ������,
' True - �������������. �� ��������� - False. 
function fn_regexp_test(str,pattern,global,ignorecase,multiline)
  with createobject("vbscript.regexp")
    .pattern = pattern
    .ignorecase = ignorecase
    .global = global
    .multiline = multiline
    fn_regexp_test = .test(str)
  end with
end function

' ���������� ������ ����� � ������� ������ ������������
' (�� ����� �������� ��� �������� ������)
function fn_groups()
  ' LDAP ����������� ������ � ������� ��������, ����� ����� ������
  fn_groups = getobject("LDAP://" & createobject("adsysteminfo").username).getex("memberof")
end function

' ������� ����
' ���������:
' file - ���� �� �����
sub sub_delete_file(file)
  createobject("scripting.filesystemobject").deletefile file, TRUE
end sub