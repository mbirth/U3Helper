Counter = 0

ToolTip Closing %AppName% ...

SplitPath AppExe, AppFile, null, null, null, null

TryClose:
Process Exist, %AppFile%
If ErrorLevel
  ProgPID = %ErrorLevel%
Else
  Goto CloseDone

WinClose ahk_pid %ProgPID%, , 0.5
If Counter >= 10
  Process Close, %ProgPID%
Counter += 1
Goto TryClose

CloseDone:
ToolTip
