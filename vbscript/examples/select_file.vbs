Set objDialog = CreateObject("UserAccounts.CommonDialog")
objDialog.Filter = "All Files|*.*"
objDialog.InitialDir = "C:\"
intResult = objDialog.ShowOpen

If intResult = 0 Then
     Wscript.Quit
 Else
     Wscript.Echo objDialog.FileName
 End If
