EnvSet USERPROFILE, %U3_APP_DATA_PATH%
EnvSet HOMEPATH, %U3_APP_DATA_PATH%
EnvSet APPDATA, %U3_APP_DATA_PATH%\Application Data

; add custom PATH directories
EnvGet ePATH, PATH
IniGetKeys("envdir", INIFile, "EnvPath")
Loop %envdir0%
{
  CurPath := envdir%A_Index%
  StringReplace CurPath, CurPath, % "%ALLUSERSPROFILE%", %eALLUSERSPROFILE%, A
  StringReplace CurPath, CurPath, % "%APPDATA%", %eAPPDATA%, A
  StringReplace CurPath, CurPath, % "%CommonProgramFiles%", %eCommonProgramFiles%, A
  StringReplace CurPath, CurPath, % "%HOMEPATH%", %eHOMEPATH%, A
  StringReplace CurPath, CurPath, % "%ProgramFiles%", %eProgramFiles%, A
  StringReplace CurPath, CurPath, % "%SystemRoot%", %eSystemRoot%, A
  StringReplace CurPath, CurPath, % "%USERPROFILE%", %eUSERPROFILE%, A
  StringReplace CurPath, CurPath, % "%WINDIR%", %ewindir%, A
  StringReplace CurPath, CurPath, % "%TEMP%", %eTEMP%, A
  StringReplace CurPath, CurPath, % "%U3_APP_DATA_PATH%", %U3_APP_DATA_PATH%, A
  StringReplace CurPath, CurPath, % "%U3_DEVICE_DOCUMENT_PATH%", %U3_DEVICE_DOCUMENT_PATH%, A
  StringReplace CurPath, CurPath, % "%U3_DEVICE_EXEC_PATH%", %U3_DEVICE_EXEC_PATH%, A
  StringReplace CurPath, CurPath, % "%U3_HOST_EXEC_PATH%", %U3_HOST_EXEC_PATH%, A
  
  ePATH := CurPath . ";" . ePATH
}
EnvSet PATH, %ePATH%

IfNotExist %APPDATA%
{
  FileCreateDir %APPDATA%
}

cmdl := AppExe
Loop %0%
{
  If (A_Index > 1)
  {
    cmdl := cmdl . " " . %A_Index%
  }
}
OnExit ASOnExit
RunWait %cmdl%
Goto ASCloseDone

ASOnExit:
Counter = 0
ToolTip Closing %AppName% ...

SplitPath AppExe, AppFile, null, null, null, null

ASTryClose:
Process Exist, %AppFile%
If ErrorLevel
  ProgPID = %ErrorLevel%
Else
  ExitApp

WinClose ahk_pid %ProgPID%, , 0.5
If Counter >= 10
  Process Close, %ProgPID%
Counter += 1
Sleep 200
Goto ASTryClose

ASCloseDone:
Tooltip
