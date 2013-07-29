' Опись оборудования и ПО
option explicit
On error resume next


private const DEFAULT_PROGRAMS_LIST = "programs.csv"
private const DEFAULT_DEVICE_LIST = "device.csv"
private const DEFAULT_WINDOWS_LICENSE_LIST = "windows-license.csv"
private const DEFAULT_OFFICE_LICENSE_LIST = "office-license.csv"
private const DEFAULT_COMPUTER_NAME = "."
private computer_name
private programs_list, device_list
private windows_license_list, office_license_list

' В будущем у скрипта появятся параметры запуска
' Вот поэтому ниже идет чехарда с переменными
computer_name = DEFAULT_COMPUTER_NAME
programs_list = DEFAULT_PROGRAMS_LIST
device_list = DEFAULT_DEVICE_LIST
windows_license_list = DEFAULT_WINDOWS_LICENSE_LIST
office_license_list = DEFAULT_OFFICE_LICENSE_LIST
if (computer_name = DEFAULT_COMPUTER_NAME) then
  computer_name = get_computer_name()
end if

office_info_csv office_license_list, computer_name
windows_info_csv windows_license_list, computer_name
list_installed_sofware_csv programs_list, computer_name
list_PNP_signed_drivers_csv device_list, computer_name
wscript.echo "Данные все собранны"


' Описание процедур и функций

' Пишет в файл информацию об установленном ПО
sub list_installed_sofware_csv(byval csv_file, byval computer_name)
  const SEPARATOR = ";"
  dim objWMIService, objSoftware, colSoftware
  set objWMIService = getObject("winmgmts:" & _
    "{impersonationLevel=impersonate}!\\" & computer_name & "\root\cimv2")
  set colSoftware = objWMIService.execQuery("Select * from Win32_Product")
  if not exists_file(csv_file) then
    touch(csv_file)
    writeln_file csv_file, "Computer" & SEPARATOR & _
      "Caption" & SEPARATOR & _
      "Description" & SEPARATOR & _
      "Identifying Number" & SEPARATOR & _
      "Install Date" & SEPARATOR & _
      "Install Location" & SEPARATOR & _
      "Install State" & SEPARATOR & _
      "Name" & SEPARATOR & _ 
      "Package Cache" & SEPARATOR & _
      "SKU Number" & SEPARATOR & _
      "Vendor" & SEPARATOR & _
      "Version" & SEPARATOR
  end if
  for each objSoftware in colSoftware
    with objSoftware
      writeln_file csv_file, computer_name & SEPARATOR & _
      .caption & SEPARATOR & _
      .description & SEPARATOR & _
      .identifyingNumber & SEPARATOR & _
      .installDate2 & SEPARATOR & _
      .installLocation & SEPARATOR & _
      .installState & SEPARATOR & _
      .name & SEPARATOR & _
      .packageCache & SEPARATOR & _
      .SKUNumber & SEPARATOR & _
      .vendor & SEPARATOR & _
      .version & SEPARATOR
    end with
  next
end sub

' Пишет в файл информацию об устроуствах
sub list_PNP_signed_drivers_csv(byval csv_file, byval computer_name)
  const SEPARATOR = ";"
  dim objWMIService, objItem, colItems
  set objWMIService = getObject("winmgmts:" & _
    "{impersonationLevel=impersonate}!\\" & computer_name & "\root\cimv2")
  set colItems = objWMIService.execQuery("Select * from Win32_PnPSignedDriver")
  if not exists_file(csv_file) then
    touch(csv_file)
    writeln_file csv_file, "Computer" & SEPARATOR & _
      "Class Guid" & SEPARATOR & _
      "Compatability ID" & SEPARATOR & _
      "Description" & SEPARATOR & _
      "Device Class" & SEPARATOR & _
      "Device ID" & SEPARATOR & _
      "Device Name" & SEPARATOR & _
      "Driver Date" & SEPARATOR & _
      "Driver Provider Name" & SEPARATOR & _
      "Driver Version" & SEPARATOR & _
      "Hardware ID" & SEPARATOR & _
      "INF Name" & SEPARATOR & _
      "Is Signed" & SEPARATOR & _
      "Manufacturer" & SEPARATOR & _
      "PDO" & SEPARATOR & _
      "Signer" & SEPARATOR
  end if
  for each objItem in colItems
    with objItem
      writeln_file csv_file, computer_name & SEPARATOR & _
      .classGuid & SEPARATOR & _
      .compatID & SEPARATOR & _
      .description & SEPARATOR & _
      .deviceClass & SEPARATOR & _
      .deviceID  & SEPARATOR & _
      .deviceName & SEPARATOR & _
      WMIDateStringToDate(.DriverDate) & SEPARATOR & _
      .driverProviderName & SEPARATOR & _
      .driverVersion   & SEPARATOR & _
      .hardWareID & SEPARATOR & _
      .infName & SEPARATOR & _
      .isSigned & SEPARATOR & _
      .manufacturer & SEPARATOR & _
      .PDO & SEPARATOR & _
      .signer & SEPARATOR
    end with
  next
end sub

sub windows_info_csv(byval csv_file, byval computer_name)
  const SEPARATOR = ";"
  const PREFIX = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"
  if not exists_file(csv_file) then
    touch(csv_file)
    writeln_file csv_file, "Computer" & SEPARATOR & _
      "SubVersion Number" & SEPARATOR & _
      "Current Build" & SEPARATOR & _
      "Install Date" & SEPARATOR & _
      "Product Name" & SEPARATOR & _
      "Reg Done" & SEPARATOR & _
      "Registered Organization" & SEPARATOR & _
      "Registered Owner" & SEPARATOR & _
      "Software Type" & SEPARATOR & _
      "Current Version" & SEPARATOR & _
      "Current Build Number" & SEPARATOR & _
      "Build Lab" & SEPARATOR & _
      "CurrentType" & SEPARATOR & _
      "CSD Version" & SEPARATOR & _
      "System Root" & SEPARATOR & _
      "Source Path" & SEPARATOR & _
      "Product Id" & SEPARATOR &_
      "Digital Product Id" & SEPARATOR '& _
      '"License Info" & SEPARATOR &_
      '"AGTS Type" & SEPARATOR
  end if
  writeln_file csv_file, computer_name & SEPARATOR & _
  reg_read(PREFIX & "SubVersionNumber") & SEPARATOR & _
  reg_read(PREFIX & "CurrentBuild") & SEPARATOR & _
  reg_read(PREFIX & "InstallDate") & SEPARATOR & _
  reg_read(PREFIX & "ProductName") & SEPARATOR & _
  reg_read(PREFIX & "RegDone")  & SEPARATOR & _
  reg_read(PREFIX & "RegisteredOrganization") & SEPARATOR & _
  reg_read(PREFIX & "RegisteredOwner") & SEPARATOR & _
  reg_read(PREFIX & "SoftwareType") & SEPARATOR & _
  reg_read(PREFIX & "CurrentVersion")   & SEPARATOR & _
  reg_read(PREFIX & "CurrentBuildNumber") & SEPARATOR & _
  reg_read(PREFIX & "BuildLab") & SEPARATOR & _
  reg_read(PREFIX & "CurrentType") & SEPARATOR & _
  reg_read(PREFIX & "CSDVersion") & SEPARATOR & _
  reg_read(PREFIX & "SystemRoot") & SEPARATOR & _
  reg_read(PREFIX & "SourcePath") & SEPARATOR & _
  reg_read(PREFIX & "ProductId") & SEPARATOR & _
  get_key(reg_read(PREFIX & "DigitalProductId")) & SEPARATOR '& _
  'reg_read(PREFIX & "LicenseInfo") & SEPARATOR & _
  'reg_read(PREFIX & "AGTSType") & SEPARATOR
end sub

sub office_info_csv(byval csv_file, byval computer_name)
  dim office_keys
  office_keys = get_office_keys()
  const SEPARATOR = ";"
  if not exists_file(csv_file) then
    touch(csv_file)
    writeln_file csv_file, "Computer" & SEPARATOR & _
      "Product Id" & SEPARATOR & _
      "Current" & SEPARATOR & _
      "Digital Product Id" & SEPARATOR
  end if
  writeln_file csv_file, computer_name & SEPARATOR & _
  reg_read(office_keys & "ProductId") & SEPARATOR & _
  reg_read(office_keys & "Current") & SEPARATOR & _
  get_key(reg_read(office_keys & "DigitalProductId")) & SEPARATOR
end sub

function get_office_keys()
  dim word
  set word = createObject("Word.Application")
  get_office_keys = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\" & _
    word.version & "\Registration\" & word.ProductCode & "\"
end function

' Конвертирует дату
function WMIDateStringToDate(byval dtmWMIDate)
    if not isNull(dtmWMIDate) then
    WMIDateStringToDate = cDate(mid(dtmWMIDate, 5, 2) & "/" & _
      mid(dtmWMIDate, 7, 2) & "/" & left(dtmWMIDate, 4) & " " & _
      mid(dtmWMIDate, 9, 2) & ":" & _
      mid(dtmWMIDate, 11, 2) & ":" & mid(dtmWMIDate,13, 2))
    end if
end function

' Поручает имя текущего компьютера
function get_computer_name()
  get_computer_name = createObject("WScript.Network").computerName
end function

' Чтение ключа реестра
function reg_read(byval key)
  reg_read = createObject("WScript.Shell").regRead(key)
end function

' Проверка существования файла
function exists_file(byval path)
  exists_file = createObject("Scripting.FileSystemObject").fileExists(path)
end function

' Создает текстовый файл
sub touch(byval path)
  createObject("Scripting.FileSystemObject").createTextFile(path)
end sub

sub writeln_file(byval path, byval str)
  dim textStream
  set textStream = createObject("Scripting.FileSystemObject").getFile(path).openAsTextStream(8)
  textStream.writeLine str
  textStream.close
end sub

function get_key(byval p)
  const PC = "BCDFGHJKMPQRTVWXY2346789"
  dim productKey, i, a, j
  for i=0 to 28
    a=0
    for j=0 to 14 
      a=p(66-j)+a*256 
      p(66-j)=(a\24) and 255 
      a=a mod 24
    next
    productKey = mid(PC,a+1,1) & productKey
    if (((i+2) mod 6)=0) and (i<28) then
      i=i+1
      productKey = "-" & productKey
    end if
  next
  get_key = productKey
end function