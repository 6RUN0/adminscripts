' ��������� ���:
' taskkill /im excel.exe && cscript summ_matrix.vbs *.xls
option explicit

private const XSL_FILES = "^.*\.xlsx?$"
private const CELL_X1 = 4
private const CELL_Y1 = 8
private const CELL_X2 = 11
private const CELL_Y2 = 29
private const RESULT_FILE = "c:\path\to\result_file.xls"
private const RESULT_CELL_X1 = 4
private const RESULT_CELL_Y1 = 6
private const RESULT_CELL_X2 = 11
private const RESULT_CELL_Y2 = 27

dim strArgument, stdOut, i
dim size, dX, dY, file
dX = CELL_X2 - CELL_X1
dY = CELL_Y2 - CELL_Y1
public table
reDim table(dX, dY)

'for each strArgument in wscript.arguments
'  wscript.echo strArgument
'next

for each file in list(XSL_FILES)
  ' ����� ������� ��������� ����������� :-)
  table = sum_matrix2d(table, read_table_xsl(CELL_X1, CELL_Y1, CELL_X2, CELL_Y2, file), dX ,dY)
next

write_table_xsl RESULT_CELL_X1, RESULT_CELL_Y1, RESULT_CELL_X2, RESULT_CELL_Y2, table, RESULT_FILE
'print_matrix2d table, dX, dY
wscript.echo "������ �������� ��� ��������"

' ����� �������
' matrix - ������ m �� n
' m - ����� �������� �������
' n - ����� ����� �������
sub print_matrix2d(byVal matrix, byVal m, byVal n)
  dim i, j, result
  result = VBNULLSTRING
  for j = 0 to n
    for i = 0 to m
      result = result & " " & matrix(i,j)
    next
    result = result & VBNEWLINE
  next
  wscript.echo result
end sub

' ������� ����������� ��������� 2 ������� � ���������� ��������� � �����
' ���������� �������
' matrix1 - ������ ���������
' matrix2 - ������ ���������
' m - ����� �������� �������
' n - ����� ����� �������
function sum_matrix2d(byVal matrix1, byVal matrix2, byVal m, byVal n)
  dim i, j
  reDim result(m, n)
  for i = 0 to m
    for j = 0 to n
      result(i,j) = matrix1(i,j) + matrix2(i,j)
    next
  next
  sum_matrix2d = result
end function

' ��������� �������� �� ����� ������� excel
' x1, y1 - ���������� ������� ����� ������
' x2, y2 - ���������� ������ ������ ������
' fullPath - ������ ���� �� ����� xsl
' ���������� ��������� ������ � � �������
function read_table_xsl(byVal x1, byVal y1, byVal x2, byVal y2, byVal fullPath)
  dim objExcel, objWorkbook
  dim i, j, dX, dY', tmp
  set objExcel = CreateObject("Excel.Application")
  set objWorkbook = objExcel.workbooks.open(fullPath)
  objExcel.visible = FALSE
  dX = x2 - x1
  dY = y2 - y1
  reDim result(dX, dY)
  for j = 0 to dY
    for i = 0 to dX
      result(i,j) = objExcel.cells(y1+j, x1+i).value
      'tmp = tmp &" "& objExcel.cells(y1+j, x1+i).value
    next
    'tmp = tmp & VBNEWLINE
  next
  objWorkbook.save
  objWorkbook.close
  objExcel.quit
  'wscript.echo tmp
  read_table_xsl = result
end function

' ��������� ���������� ������ � ������� ex�el
' x1, y1 - ���������� ������� ����� ������
' x2, y2 - ���������� ������ ������ ������
' matrix - ������
' fullPath - ������ ���� �� ����� xsl
sub write_table_xsl(byVal x1, byVal y1, byVal x2, byVal y2, byVal matrix, byVal fullPath)
  dim objExcel, objWorkbook
  dim i, j, dX, dY
  set objExcel = CreateObject("Excel.Application")
  set objWorkbook = objExcel.workbooks.open(fullPath)
  objExcel.visible = FALSE
  dX = x2 - x1
  dY = y2 - y1
  for j = 0 to dY
    for i = 0 to dX
      objExcel.cells(y1+j, x1+i).value = matrix(i,j)
    next
  next
  objWorkbook.save
  objWorkbook.close
  objExcel.quit
end sub

' ���������� ������� �������� ������ (regexp)
' ���������� ������
function list(byVal regexp)
  dim objFolder, strFile, i
  reDim arrElements(0)
  set objFolder = createObject("Scripting.FileSystemObject") _
  .getFolder(get_current_dir())
  i = 0
  for each strFile in objFolder.files
    if regexp_test(strFile, regexp, FALSE, TRUE, FALSE) then
      reDim preserve arrElements(i)
      arrElements(i) = strFile.path
      i = i + 1
    end if
  next
  list = arrElements
end function

' ������� �� ����� ����������
' ���������� ������� ����������, �������� ���
function get_current_dir()
  get_current_dir = createObject("WScript.Shell").currentDirectory
end function

' ���������:
' strSearch - C�����, ��� ������
' strPattern - ������, ������������ ��� ������.
' global - ����� (������). False - ��������� �� ������� ������������,
'  True - ��������� �� ����� ������. �� ��������� - False. 
' ignorecase - ����� (������). False - ��������� ������� ��������,
'  True - ������������ ������� ��������. �� ��������� - False. 
' multiline - ����� (������). False - ������������ ������,
'  True - �������������. �� ��������� - False. 
' ������������ �������� - ������ (�����). 
function regexp_test(byVal strSearch, byVal strPattern, byVal global, _
byVal ignorecase, byVal multiline)
with createobject("vbscript.regexp")
  .pattern = strPattern
  .ignorecase = ignorecase
  .global = global
  .multiline = multiline
  regexp_test = .test(strSearch)
end with
end function