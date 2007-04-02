#NoTrayIcon
#NoEnv
#Include mb_IniTools.ahk
#Include mb_TextTools.ahk
U3HVer = 1.4

EnvGet U3_DEVICE_SERIAL, U3_DEVICE_SERIAL                    ; serial number of device (copy protection)
EnvGet U3_DEVICE_PATH, U3_DEVICE_PATH                        ; drive letter to device (F:)
EnvGet U3_DEVICE_DOCUMENT_PATH, U3_DEVICE_DOCUMENT_PATH      ; path to documents (F:\Documents)
EnvGet U3_DEVICE_VENDOR, U3_DEVICE_VENDOR                    ; vendor
EnvGet U3_DEVICE_PRODUCT, U3_DEVICE_PRODUCT                  ; product name string
EnvGet U3_DEVICE_VENDOR_ID, U3_DEVICE_VENDOR_ID              ; vendor id (decimal!! 2284 = 0x08ec)
EnvGet U3_APP_DATA_PATH, U3_APP_DATA_PATH                    ; data path for app (on device)
EnvGet U3_HOST_EXEC_PATH, U3_HOST_EXEC_PATH                  ; path to exe on host
EnvGet U3_DEVICE_EXEC_PATH, U3_DEVICE_EXEC_PATH              ; path to needed files on device
EnvGet U3_ENV_VERSION, U3_ENV_VERSION                        ; should be 1.0
EnvGet U3_ENV_LANGUAGE, U3_ENV_LANGUAGE                      ; language id of LaunchPad
EnvGet U3_IS_UPGRADE, U3_IS_UPGRADE                          ; can be "false" or "true"
EnvGet U3_IS_DEVICE_AVAILABLE, U3_IS_DEVICE_AVAILABLE        ; "true"/"false"
EnvGet U3_IS_AUTORUN, U3_IS_AUTORUN                          ; is this an autorun-launch? "true"/"false"
EnvGet U3_DAPI_CONNECT_STRING, U3_DAPI_CONNECT_STRING        ; who needs this?
EnvGet eALLUSERSPROFILE, ALLUSERSPROFILE                     ; C:\Documents and Settings\All Users
EnvGet eAPPDATA, APPDATA                                     ; C:\Doc...\<username>\Application Data
EnvGet eCommonProgramFiles, CommonProgramFiles               ; C:\Program Files\Common Files
EnvGet eHOMEPATH, HOMEPATH                                   ; C:\Documents and Settings\<username>
EnvGet eProgramFiles, ProgramFiles                           ; C:\Program Files
EnvGet eSystemRoot, SystemRoot                               ; C:\WINDOWS
EnvGet eUSERPROFILE, USERPROFILE                             ; C:\Documents and Settings\<username>
EnvGet eTEMP, TEMP                                           ; C:\DOCUME~1\<username8.3>\LOCALS~1\Temp
EnvGet ewindir, windir                                       ; C:\WINDOWS

SplitPath A_ScriptFullPath, null, ScrDir, null, ScrFile, ScrDrive
INIFile = %ScrDir%\%ScrFile%.ini
IniRead AppName, %INIFile%, U3Helper, AppName, unknown
IniRead AppExe, %INIFile%, U3Helper, AppExe, cmd.exe
IniRead Unattended, %INIFile%, U3Helper, Unattended, 0
IniGetKeys("regsvr", INIFile, "regsvr32")
IniGetKeys("datexe", INIFile, "DataToExecDir")
IniGetKeys("regbak", INIFile, "RegBackup")
IniGetKeys("regdel", INIFile, "RegDelete")
IniGetKeys("fildel", INIFile, "FileDelete")

Perc(pos, all)
{
  perc := Floor(pos*100//all)
  str = %perc%
  str .= "% ["
  lc := perc//10
  Loop %lc%
  {
    str .= "|"
  }
  Loop % (109-perc)//10
  {
    str .= "."
  }
  str .= "]"
  return str
}

Status(msg)
{
  global AppName
  if (StrLen(msg) > 0)
  {
    ToolTip %AppName%`n%msg%
  }
  Else
  {
    ToolTip
  }
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
  MsgBox No parameter given.
}
