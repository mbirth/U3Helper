#NoTrayIcon
#NoEnv
#Include mb_EnvTools.ahk
#Include mb_IniTools.ahk
#Include mb_TextTools.ahk
U3HVer = 1.7

SplitPath A_ScriptFullPath, null, ScrDir, null, ScrFile, ScrDrive
INIFile = %ScrDir%\%ScrFile%.ini
IniRead AppName, %INIFile%, U3Helper, AppName, unknown
IniRead AppExe, %INIFile%, U3Helper, AppExe, cmd.exe
IniRead Unattended, %INIFile%, U3Helper, Unattended, 0
IniRead RunBeforeStop, %INIFile%, U3Helper, RunBeforeStop, %A_Space%
IniRead RunBeforeEject, %INIFile%, U3Helper, RunBeforeEject, %A_Space%
IniGetKeys("regsvr", INIFile, "regsvr32")
IniGetKeys("datexe", INIFile, "DataToExecDir")
IniGetKeys("regbak", INIFile, "RegBackup")
IniGetKeys("regdel", INIFile, "RegDelete")
IniGetKeys("fildel", INIFile, "FileDelete")

U3_APP_DATA_PATH := EnvValue("U3_APP_DATA_PATH")
U3_HOST_EXEC_PATH := EnvValue("U3_HOST_EXEC_PATH")
U3_DEVICE_EXEC_PATH := EnvValue("U3_DEVICE_EXEC_PATH")

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
  FileCopy %srcf%, %dstf%, 1
  If ErrorLevel
  {
    ErrorLevel = 2
    return false
  }
  return true
}

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
  MsgBox 48, U3Helper %U3HVer%, No parameter given.`n`nSee http://www.autohotkey.com/forum/topic11839.html for info.`n`n(c)2006-2007 Markus Birth <mbirth@webwriters.de>
  MsgBox 64, U3Helper %U3HVer% - Debug info, % EnvList(), 30
}
