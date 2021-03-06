ASOnExit:

StepsAll = 1
If runstp0 > 0
  StepsAll++
StepsStep := 100/StepsAll
StepsPos = 0

Progress b2 x%PL% y%PT% w%PW% m FM%PFM% FS%PFS%, U3Helper %U3HVer% - (c)2006-2007 Markus Birth <mbirth@webwriters.de>, Stopping %AppName% ..., AHKProgress-%AppName%
WinSet Transparent, %PTrans%, AHKProgress-%AppName%

Loop %runstp0%
{
  CurCmd := runstp%A_Index%
  Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/runstp0, Running stop command ... %CurCmd%
  CurCmd := EnvParseStr(CurCmd)
  RunWait %CurCmd%
}
If runstp0 > 0
  StepsPos++

SplitPath AppExe, AppFile, null, null, null, null

Counter = 0
CounterMax = 10

TryClose:
Progress % StepsPos*StepsStep+StepsStep*Counter/CounterMax, Stopping %AppName% ...
Process Exist, %AppFile%
If ErrorLevel
  ProgPID = %ErrorLevel%
Else
  Goto CloseDone

WinClose ahk_pid %ProgPID%, , 0.5
If Counter >= %CounterMax%
{
  Progress 100, Killing %AppName% ...
  Process Close, %ProgPID%
}
Counter += 1
Goto TryClose

CloseDone:
Progress 100, appStop done.
ExitApp
