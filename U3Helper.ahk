#NoTrayIcon
#NoEnv
#Include mb_EnvTools.ahk
#Include mb_IniTools.ahk
#Include mb_RegTools.ahk
#Include mb_TextTools.ahk
U3HVer = 2.3
U3HUUID = 0f90f88c-5e05-4cab-8c3a-e1c0112b06fd

U3_APP_DATA_PATH := EnvValue("U3_APP_DATA_PATH")
U3_HOST_EXEC_PATH := EnvValue("U3_HOST_EXEC_PATH")
U3_DEVICE_EXEC_PATH := EnvValue("U3_DEVICE_EXEC_PATH")
EnvGet U3_IS_DEVICE_AVAILABLE, U3_IS_DEVICE_AVAILABLE
EnvGet U3_IS_AUTORUN, U3_IS_AUTORUN

SplitPath A_ScriptFullPath, null, ScrDir, null, ScrFile, ScrDrive
INIFile = %ScrDir%\%ScrFile%.ini
If (StrLen(U3_HOST_EXEC_PATH) > 0)
  INIFile = %U3_HOST_EXEC_PATH%\%ScrFile%.ini

IniRead AppName, %INIFile%, U3Helper, AppName, unknown
IniRead AppExe, %INIFile%, U3Helper, AppExe, cmd.exe
IniRead Unattended, %INIFile%, U3Helper, Unattended, 0
IniGetKeys("runcon", INIFile, "RunBeforeConfig")
IniGetKeys("runsta", INIFile, "RunBeforeStart")
IniGetKeys("runstp", INIFile, "RunBeforeStop")
IniGetKeys("runeje", INIFile, "RunBeforeEject")
IniGetKeys("regsvr", INIFile, "regsvr32")
IniGetKeys("datexe", INIFile, "DataToExecDir")
IniGetKeys("dattxt", INIFile, "ParseFiles")
IniGetKeys("regbak", INIFile, "RegBackup")
IniGetKeys("regdel", INIFile, "RegDelete")
IniGetKeys("fildel", INIFile, "FileDelete")
; backward compatibility:
IniGetKeys("dattxt", INIFile, "ParseIniFiles")   ; backward compatibility
IniRead RunBeforeStop, %INIFile%, U3Helper, RunBeforeStop, %A_Space%
IniRead RunBeforeEject, %INIFile%, U3Helper, RunBeforeEject, %A_Space%
If (StrLen(RunBeforeStop) > 0)
{
  runstp0++
  runstp%runstp0% := RunBeforeStop
}
If (StrLen(RunBeforeEject) > 0)
{
  runeje0++
  runeje%runeje0% := RunBeforeEject
}

;******************************************************************************
;** Get Taskbar position
;******************************************************************************

WinGetPos,Tx,Ty,Tw,Th,ahk_class Shell_TrayWnd,,,
; Tw>Th: horizontal taskbar (top or bottom)
; Tw<Th: vertical taskbar (left or right)
; Tx=0 and Ty=0: top or left
; Tx>0: right
; Ty>0: bottom
PT := 0
PL := 0
PH := 78
PW := 400
PFM := 10
PFS := 8
PTrans := 204

if (Tw>Th and Ty<=0) {
  ;taskbar top
  PL := A_ScreenWidth - PW
  PT := Ty + Th
} else if (Tw>Th and Ty>0) {
  ;taskbar bottom
  PL := A_ScreenWidth - PW
  PT := Ty - PH
} else if (Tw<Th and Ty=0) {
  ;taskbar left
  PL := Tx + Tw
  PT := A_ScreenHeight - PH
} else if (Tw<Th and Ty>0) {
  ;taskbar right
  PL := Tx - PW
  PT := A_ScreenHeight - PH
}

;******************************************************************************

;******************************************************************************
;** Get names in local language for "Application Data", "Local Settings" and
;** "Application Data" below "Local Settings"
;******************************************************************************

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

EnvAddX("U3H_AppData", ADn)
EnvAddX("U3H_LocalSettings", LSn)
EnvAddX("U3H_LocalAppData", LSn . "\" . LADn)
EnvSort()

;******************************************************************************

FileCopyNewer(srcf, dstf)
{
  IfNotExist %srcf%
  {
    ErrorLevel = 1
    return false
  }
  IfExist %dstf%
  {
    FileGetSize FilSize1, %srcf%
    FileGetSize FilSize2, %dstf%
    FileGetTime FilStamp1, %srcf%
    FileGetTime FilStamp2, %dstf%
    if ((FilSize1 = FilSize2) and (FilStamp1 = FilStamp2)) {
      ; Both versions are same size and same date/time - skip
      ErrorLevel = -1
      return true
    }
  }
  SplitPath dstf, oFn, oDir, oExt, oName, oDrive
  IfNotExist %oDir%
    FileCreateDir %oDir%
  
  FileCopy %srcf%, %dstf%, 1
  If ErrorLevel
  {
    ErrorLevel = 2
    return false
  }
  return true
}

;******************************************************************************

IfExist %AppExe%
  Menu Tray, Icon, %AppExe%

If 1 = config
{
  #Include U3H_hostConfigure.ahk
}
Else If 1 = unconfig
{
  #Include U3H_hostCleanUp.ahk
}
Else If 1 = appstart
{
  #Include U3H_appStart.ahk
}
Else If 1 = appstop
{
  #Include U3H_appStop.ahk
}
Else
{
  MsgBox 48, U3Helper %U3HVer% - About, This is the U3Helper tool for making applications U3-Smart. It cannot be directly started.`n`nNo parameter given.`n`nSee http://www.autohotkey.com/forum/topic11839.html for info.`n`n(c)2006-2007 Markus Birth <mbirth@webwriters.de>
  MsgBox 64, U3Helper %U3HVer% - Debug info, % EnvList(), 30
}
