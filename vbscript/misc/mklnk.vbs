option explicit

const TARGET_FLAG="-t"
const OPTION_FLAG="-o"
const NAME_FLAG="-n"
'const LINK_EXT="lnk"
const SPECIAL_DIR_FLAG="-d"
const HELP_FLAG="-h"
const PIONEER_SLASH = "\"
const QUOTE = 34
const SEPARATOR = "="

dim str_argument
dim str_flag, int_size_of_flag
dim str_left_part, str_right_part
dim str_target_flag, str_option_flag, str_name_flag, str_special_dir_flag
dim str_help, chr_quote
chr_quote = chr(QUOTE)
str_help = wscript.scriptname & " - ������� �����" & VBNEWLINE & _
          "�������������: " & VBNEWLINE & _
           wscript.scriptname & " [" & HELP_FLAG & "|" & TARGET_FLAG & "=<���� �� ����� �� ������� ��������� �����> " & _
           OPTION_FLAG & "=<����� �������> " & SPECIAL_DIR_FLAG & "=<���� �����> " & NAME_FLAG & "=<��� ������>]" & VBNEWLINE & _
           TARGET_FLAG & " ���� �� ����� �� ������� ��������� �����. ���� � ���� ���������� �������, �� ���������� ��������� ��� � �������" & VBNEWLINE & _
           OPTION_FLAG & " ����� �������. ���� ����������." & VBNEWLINE & _
           NAME_FLAG & " ��� ������ � �����������." & VBNEWLINE & _
           SPECIAL_DIR_FLAG & " ��� ����������� ����� Windows" & VBNEWLINE & _
           "   ���������� ��������:" & VBNEWLINE & _
           "   AllUsersDesktop - ������� ���� ���� �������������" & VBNEWLINE & _
           "   AllUsersStartMenu - ���� ���� ���� �������������" & VBNEWLINE & _
           "   AllUsersPrograms - ��� ��������� � ���� ���� ���� �������������" & VBNEWLINE & _
           "   AllUsersStartup - ������������ ��� ���� �������������" & VBNEWLINE & _
           "   Desktop - ������� ���� �������� ������������" & VBNEWLINE & _
           "   Favorites - ���������" & VBNEWLINE & _
           "   Fonts - ������" & VBNEWLINE & _
           "   MyDocuments - ��� ��������� �������� ������������" & VBNEWLINE & _
           "   NetHood - ����� ������� ���������" & VBNEWLINE & _
           "   PrintHood - ����� �������� � �����" & VBNEWLINE & _
           "   Programs - ��� ��������� � ���� ���� �������� ������������" & VBNEWLINE & _
           "   Recent - �������� ���������" & VBNEWLINE & _
           "   SendTo - ���� ���������" & VBNEWLINE & _
           "   StartMenu - ���� ���� �������� ������������" & VBNEWLINE & _
           "   Startup - ������������ �������� ������������" & VBNEWLINE & _
           "   Template - �������." & VBNEWLINE & _
           "-h  �������." & VBNEWLINE & _
           "������:" & VBNEWLINE & _
           wscript.scriptname & " " & TARGET_FLAG & "=" & chr_quote & "%WINDIR%\system32\cmd.exe" & chr_quote & " " & _
           OPTION_FLAG & "=" & chr_quote & "/C ping e1.ru" & chr_quote & " " & _
           SPECIAL_DIR_FLAG & "=Desktop " & NAME_FLAG & "=" & chr_quote & "���� e1.ru.lnk" & chr_quote & VBNEWLINE 
str_target_flag = VBNULLSTRING
str_option_flag = VBNULLSTRING
str_name_flag = VBNULLSTRING
str_special_dir_flag = VBNULLSTRING
for each str_argument in wscript.arguments
  wscript.echo str_argument
  str_flag=split(str_argument,SEPARATOR,2)
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
    case TARGET_FLAG
      str_target_flag = str_right_part
      if not is_path(str_target_flag) then
        wscript.echo str_target_flag & " ��������� ��������. �������� ������������ ��������� ���� �� �����."
        wscript.quit
      end if
    case OPTION_FLAG
      str_option_flag = replace(str_right_part,"'",chr_quote)
    case NAME_FLAG
      str_name_flag = str_right_part
    case SPECIAL_DIR_FLAG
      str_special_dir_flag = str_right_part
    case HELP_FLAG
      wscript.echo str_help
      wscript.quit
    case else 
      wscript.echo "����������� ���������: "  & str_left_part & VBNEWLINE & str_help
      wscript.quit
  end select 
next
if str_target_flag=VBNULLSTRING or _
   str_special_dir_flag=VBNULLSTRING or str_name_flag=VBNULLSTRING then
  wscript.echo "���� ��� ��������� ���������� �� ������." & VBNEWLINE & str_help
  wscript.quit
end if
create_link str_target_flag, str_option_flag, get_path_to_specdir(str_special_dir_flag) & PIONEER_SLASH & str_name_flag

sub create_link(target, flags, link)
  with wscript.createobject("wscript.shell").createshortcut(link)
    .targetpath = target
    .arguments = flags
    .workingdirectory = get_parent(target)
    .save
  end with
end sub

function get_path_to_specdir(specdir)
  get_path_to_specdir = createobject("wscript.shell").specialfolders(specdir)
end function

function get_parent(file)
  get_parent = createobject("scripting.filesystemobject").getfile(file).parentfolder.path
end function

function is_path(str)
 const PATTERN = "^(\.\.|\.|[a-z]\:|\\\\[^\\/*|?<>:\x22]{1,256}){0,1}(\\[^\\/*|?<>:\x22]{1,256}){0,32000}$"
 is_path = regexp_test(str,PATTERN,TRUE,TRUE,FALSE)
end function

function regexp_test(str,pattern,global,ignorecase,multiline)
with createobject("vbscript.regexp")
  .pattern = pattern
  .ignorecase = ignorecase
  .global = global
  .multiline = multiline
  regexp_test = .test(str)
end with
end function