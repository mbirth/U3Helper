; get names in local language for "Application Data", "Local Settings" and "Application Data" below "Local Settings"
RegRead AD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders, AppData
RegRead LS, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders, Local Settings
RegRead LAD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders, Local AppData

If LAD
  LAD := AD

StringRight ADc, AD, 1
StringRight LSc, LS, 1
StringRight LADc, LAD, 1

If (ADc = "\")
  StringTrimRight AD, AD, 1

If (LSc = "\")
  StringTrimRight LS, LS, 1

If (LADc = "\")
  StringTrimRight LAD, LAD, 1

SplitLast(null, ADn, AD, "\")
SplitLast(null, LSn, LS, "\")
SplitLast(null, LADn, LAD, "\")

EnvSet USERPROFILE, %U3_APP_DATA_PATH%

; %HOMEPATH% is without drive letter and colon, do it also here
EnvGet eSystemDrive, SystemDrive
StringReplace eHOMEPATH, U3_APP_DATA_PATH, %eSystemDrive%
EnvSet HOMEPATH, %U3_APP_DATA_PATH%
EnvSet HOMEDRIVE, % EnvValue("U3_DEVICE_PATH")
EnvSet APPDATA, % U3_APP_DATA_PATH . "\" . ADn

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
IfNotExist %U3_APP_DATA_PATH%\%LSn%\%LADn%
{
  FileCreateDir %U3_APP_DATA_PATH%\%LSn%\%LADn%
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
