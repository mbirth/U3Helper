EnvSet USERPROFILE, % EnvValue("U3_APP_DATA_PATH")
EnvSet HOMEPATH, % EnvValue("U3_APP_DATA_PATH")
EnvSet APPDATA, % EnvValue("U3_APP_DATA_PATH") . "\Application Data"

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
