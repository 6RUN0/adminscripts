option explicit

const HARD_DRIVE = 2
const DEFRAG_PROGRAM ="defrag "
const DEFRAG_PROGRAM_VERBOSE_FLAG =" -v"
const DEFRAG_PROGRAM_FORCE_FLAG =" -f"
const MIN_FREE_SPACE = 15
const SUCCESS = 0
const ERROR = 1
const WARNING = 2

dim file_system_object
dim wshshell
dim drive_collection
dim drive
dim drive_letter
dim defrag_flags
dim run_cmd
dim return_code
dim message

set file_system_object = createobject("scripting.filesystemobject")
set wshshell = createobject("wscript.shell")
set drive_collection = file_system_object.drives

for each  drive in drive_collection
   if drive.drivetype = HARD_DRIVE then
         'defrag_flags = DEFRAG_PROGRAM_VERBOSE_FLAG
         defrag_flags = ""
         if drive.freespace/drive.totalsize*100 < MIN_FREE_SPACE then
            defrag_flags=defrag_flags & DEFRAG_PROGRAM_FORCE_FLAG
            wshshell.logevent WARNING,"На диске " & drive.driveletter & ":" & " недостаточно места для дефрагментации"
         end if
      run_cmd = DEFRAG_PROGRAM & drive.driveletter & ":" & defrag_flags
      return_code=wshshell.run(run_cmd,,true)
      if return_code = SUCCESS then
         message = "Дефрагментация диска " & drive.driveletter & ":" & " успешно завершена"
        else
         message = "Дефрагментация диска " & drive.driveletter & ":" & " не выполнена"
      end if
      wshshell.logevent return_code, message  
   end if
next