EnvSet USERPROFILE, %U3_APP_DATA_PATH%

; %HOMEPATH% is without drive letter and colon, do it also here
EnvGet eSystemDrive, SystemDrive
StringReplace eHOMEPATH, U3_APP_DATA_PATH, %eSystemDrive%
EnvSet HOMEPATH, %U3_APP_DATA_PATH%
EnvSet HOMEDRIVE, % EnvValue("U3_DEVICE_PATH")
EnvSet APPDATA, % U3_APP_DATA_PATH . "\Application Data"

; add custom PATH directories
EnvGet ePATH, PATH
IniGetKeys("envdir", INIFile, "EnvPath")
Loop %envdir0%
{
  CurPath := envdir%A_Index%
  CurPath := EnvParseStr(CurPath)

  ePATH := CurPath . ";" . ePATH
}
EnvSet PATH, %ePATH%

EnvGet APPDATA, APPDATA
IfNotExist %APPDATA%
{
  FileCreateDir %APPDATA%
}

SetWorkingDir %U3_HOST_EXEC_PATH%
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
OnExit
