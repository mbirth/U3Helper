#NoTrayIcon
#NoEnv
#Include mb_IniTools.ahk
#Include mb_TextTools.ahk

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

If 1 = config
{
  ; ##########################################################################
  ; ###                                                                    ###
  ; ### hostConfigure                                                      ###
  ; ###                                                                    ###
  ; ##########################################################################
  
  Menu Tray, Icon
  TrayTip Preparing %AppName% ..., U3Helper`n(c)2006 Markus Birth`nmbirth@webwriters.de, 3, 1
  
  Status("Checking registry settings...")
  keycount = 0
  ;Registry stuff
  Loop %regbak0%
  {
    CurBranch := regbak%A_Index%
    SplitFirst(RegRoot, RegSub, CurBranch, "\")
    Loop %RegRoot%, %RegSub%, 1, 1
    {
      keycount += 1  
    }
    If (keycount > 0)
    {
      Status("Backing up registry settings #" . A_Index . " ...")
      RunWait regedit /E "%U3_HOST_EXEC_PATH%\U3Hregbak%A_Index%.reg" "%CurBranch%"
      Status("Cleaning registry settings #" . A_Index . " ...")
      RegDelete %RegRoot%, %RegSub%
    }
  }

  If (keycount > 0)
  {
    Status("")
    IniWrite 1, %INIFile%, U3Helper, KeepSettings
    If (Unattended = "0")
    {
      MsgBox 4132, %AppName%: Duplicate settings, Settings for %AppName% were already found on this PC. Do you want to use them?`n`nIf you select NO, the local settings will be overwritten by those saved on your U3 stick.`n(They have been backed up and can be restored upon eject of the stick.)
      IfMsgBox Yes
      {
        IniWrite 1, %INIFile%, U3Helper, ForeignSettings
      }
    }
  }
  IniRead ForeignSettings, %INIFile%, U3Helper, ForeignSettings, 0
  If (ForeignSettings = "0")
  {
    Loop %regbak0%
    {
      Status("Importing registry settings #" . A_Index . " ...")
      RunWait regedit /S "%U3_APP_DATA_PATH%\regdata%A_Index%.reg"
    }
    IfExist %U3_APP_DATA_PATH%\regdataX.reg
    {
      Status("Importing special registry settings ...")
      RunWait regedit /S "%U3_APP_DATA_PATH%\regdataX.reg"
    }
    Loop %regbak0%
    {
      Status("Translating paths in registry #" . A_Index . " ...")
      CurBranch := regbak%A_Index%
      SplitFirst(RegRoot, RegSub, CurBranch, "\")
      Loop %RegRoot%, %RegSub%, 0, 1
      {
        If (A_LoopRegType = "REG_SZ" or A_LoopRegType = "REG_EXPAND_SZ" or A_LoopRegType = "REG_MULTI_SZ")
        {
          RegRead RegValue
          StringReplace NewRegValue, RegValue, % "%U3_HOST_EXEC_PATH%", %U3_HOST_EXEC_PATH%, A
          StringReplace NewRegValue, NewRegValue, % "%U3_APP_DATA_PATH%", %U3_APP_DATA_PATH%, A
          StringReplace NewRegValue, NewRegValue, % "%U3_DEVICE_EXEC_PATH%", %U3_DEVICE_EXEC_PATH%, A
          StringReplace NewRegValue, NewRegValue, % "%U3_DEVICE_DOCUMENT_PATH%", %U3_DEVICE_DOCUMENT_PATH%, A
          StringReplace NewRegValue, NewRegValue, % "%TEMP%", %eTEMP%, A
          StringReplace NewRegValue, NewRegValue, % "%SystemRoot%", %eSystemRoot%, A
          StringReplace NewRegValue, NewRegValue, % "%WINDIR%", %ewindir%, A
          StringReplace NewRegValue, NewRegValue, % "%APPDATA%", %eAPPDATA%, A
          StringReplace NewRegValue, NewRegValue, % "%USERPROFILE%", %eUSERPROFILE%, A
          StringReplace NewRegValue, NewRegValue, % "%ALLUSERSPROFILE%", %eALLUSERSPROFILE%, A
          StringReplace NewRegValue, NewRegValue, % "%CommonProgramFiles%", %eCommonProgramFiles%, A
          StringReplace NewRegValue, NewRegValue, % "%ProgramFiles%", %eProgramFiles%, A
          If (NewRegValue <> RegValue)
          {
            RegWrite %NewRegValue%
          }
        }
      }
    }
  }

  ;Copy data files
  Loop %datexe0%
  {
    CurFile := datexe%A_Index%
    FileGetAttrib FilAttr, %U3_APP_DATA_PATH%\%CurFile%
    IfInString FilAttr, D
    {
      Status("Copying data directory " . CurFile . " ...")
      FileCopyDir %U3_APP_DATA_PATH%\%CurFile%, %U3_HOST_EXEC_PATH%\%CurFile%, 1
    }
    Else
    {
      Status("Copying data file " . CurFile . " ...")
      FileCopy %U3_APP_DATA_PATH%\%CurFile%, %U3_HOST_EXEC_PATH%\%CurFile%, 1
    }
  }

  ; regsvr32 stuff
  IniRead KeepSettings, %INIFile%, U3Helper, KeepSettings, 0
  If (KeepSettings = "0")
  {
    Loop %regsvr0%
    {
      CurDLL := regsvr%A_Index%
      Status("Registering file " . CurDLL . " ...")
      RunWait regsvr32 /S "%U3_HOST_EXEC_PATH%\%CurDLL%"
    }
  }
  Status("")
}
Else If 1 = unconfig
{
  ; ##########################################################################
  ; ###                                                                    ###
  ; ### hostCleanUp                                                        ###
  ; ###                                                                    ###
  ; ##########################################################################
  
  If (U3_IS_DEVICE_AVAILABLE <> "true")
  {
    ; U3 stick not plugged in!!
    MsgBox 4112, U3 Device Not Available, Your U3 Device seems to be disconnected. The settings cannot be saved!`n`nAll your changes made since plugging in the U3 Device are likely to be lost. Try to manually save them now.`n`nAfter pressing OK, registry entries will be removed.
  }
  Else
  {
    ; U3 stick plugged in
    IniRead ForeignSettings, %INIFile%, U3Helper, ForeignSettings, 0
    If (ForeignSettings <> "0")
    {
      MsgBox 4132, %AppName%: Foreign settings, You chose to use the settings previously stored on this PC for %AppName%.`n`nDo you want to copy them to your U3 stick so that you have these settings available the next time?
      IfMsgBox Yes
      {
        IniDelete %INIFile%, U3Helper, ForeignSettings
      }
    }
    IniRead ForeignSettings, %INIFile%, U3Helper, ForeignSettings, 0
    If (ForeignSettings = "0")
    {
      Loop %regbak0%
      {
        Status("Translating paths in registry #" . A_Index . " ...")
        CurBranch := regbak%A_Index%
        SplitFirst(RegRoot, RegSub, CurBranch, "\")
        Loop %RegRoot%, %RegSub%, 0, 1
        {
          If (A_LoopRegType = "REG_SZ" or A_LoopRegType = "REG_EXPAND_SZ" or A_LoopRegType = "REG_MULTI_SZ")
          {
            RegRead RegValue
            StringReplace NewRegValue, RegValue, %U3_HOST_EXEC_PATH%, % "%U3_HOST_EXEC_PATH%", A
            StringReplace NewRegValue, NewRegValue, %U3_APP_DATA_PATH%, % "%U3_APP_DATA_PATH%", A
            StringReplace NewRegValue, NewRegValue, %U3_DEVICE_EXEC_PATH%, % "%U3_DEVICE_EXEC_PATH%", A
            StringReplace NewRegValue, NewRegValue, %U3_DEVICE_DOCUMENT_PATH%, % "%U3_DEVICE_DOCUMENT_PATH%", A
            StringReplace NewRegValue, NewRegValue, %eTEMP%, % "%TEMP%", A
            StringReplace NewRegValue, NewRegValue, %eSystemRoot%, % "%SystemRoot%", A
            StringReplace NewRegValue, NewRegValue, %eAPPDATA%, % "%APPDATA%", A
            StringReplace NewRegValue, NewRegValue, %eUSERPROFILE%, % "%USERPROFILE%", A
            StringReplace NewRegValue, NewRegValue, %eALLUSERSPROFILE%, % "%ALLUSERSPROFILE%", A
            StringReplace NewRegValue, NewRegValue, %eCommonProgramFiles%, % "%CommonProgramFiles%", A
            StringReplace NewRegValue, NewRegValue, %eProgramFiles%, % "%ProgramFiles%", A
            If (NewRegValue <> RegValue)
            {
              RegWrite %NewRegValue%
            }
          }
        }
      }
      Loop %regbak0%
      {
        CurBranch := regbak%A_Index%
        Status("Saving registry settings #" . A_Index . " ...")
        RunWait regedit /E "%U3_APP_DATA_PATH%\regdata%A_Index%.reg" "%CurBranch%"
      }
    }
  
    ;Copy data files
    Loop %datexe0%
    {
      CurFile := datexe%A_Index%
      FileGetAttrib FilAttr, %U3_HOST_EXEC_PATH%\%CurFile%
      IfInString FilAttr, D
      {
        Status("Saving data directory " . CurFile . " ...")
        FileCopyDir %U3_HOST_EXEC_PATH%\%CurFile%, %U3_APP_DATA_PATH%\%CurFile%, 1
      }
      Else
      {
        Status("Saving data file " . CurFile . " ...")
        FileCopy %U3_HOST_EXEC_PATH%\%CurFile%, %U3_APP_DATA_PATH%\%CurFile%, 1
      }
    }
  }

  IniRead KeepSettings, %INIFile%, U3Helper, KeepSettings, 0
  RevertSettings := "0"
  If (KeepSettings <> "0")
  {
    If (Unattended = "0")
    {
      MsgBox 4132, %AppName%: Foreign settings, Do you want to keep the changed settings for %AppName%?`n`n(Select No to revert to the former settings.)
      IfMsgBox No
      {
        RevertSettings := "1"
      }
    }
    Else
    {
      RevertSettings := "1"
    }
  }
  If (KeepSettings = "0" or RevertSettings = "1")
  {
    Loop %regbak0%
    {
      Status("Removing registry settings #" . A_Index . " from host system ...")
      CurBranch := regbak%A_Index%
      SplitFirst(RegRoot, RegSub, CurBranch, "\")
      RegDelete %RegRoot%, %RegSub%
      If (RevertSettings = "1")
      {
        Status("Restoring registry settings #" . A_Index . " from backup ...")
        RunWait regedit /S "%U3_HOST_EXEC_PATH%\U3Hregbak%A_Index%.reg"
      }
    }
  }
  If (KeepSettings = "0")
  {
    Loop %regdel0%
    {
      Status("Removing add. registry settings #" . A_Index . " from host system ...")
      CurBranch := regdel%A_Index%
      SplitFirst(RegRoot, RegSub, CurBranch, "\")
      RegDelete %RegRoot%, %RegSub%
    }

    ; regsvr32 stuff
    Loop %regsvr0%
    {
      CurDLL := regsvr%A_Index%
      Status("Unregistering file " . CurDLL . " ...")
      RunWait regsvr32 /S /U "%U3_HOST_EXEC_PATH%\%CurDLL%"
    }
    
    ; remove files
    Loop %fildel0%
    {
      CurFile := fildel%A_Index%
      StringReplace CurFile, CurFile, % "%ALLUSERSPROFILE%", %eALLUSERSPROFILE%, A
      StringReplace CurFile, CurFile, % "%APPDATA%", %eAPPDATA%, A
      StringReplace CurFile, CurFile, % "%CommonProgramFiles%", %eCommonProgramFiles%, A
      StringReplace CurFile, CurFile, % "%HOMEPATH%", %eHOMEPATH%, A
      StringReplace CurFile, CurFile, % "%ProgramFiles%", %eProgramFiles%, A
      StringReplace CurFile, CurFile, % "%SystemRoot%", %eSystemRoot%, A
      StringReplace CurFile, CurFile, % "%USERPROFILE%", %eUSERPROFILE%, A
      StringReplace CurFile, CurFile, % "%WINDIR%", %ewindir%, A
      StringReplace CurFile, CurFile, % "%TEMP%", %eTEMP%, A
      StringReplace CurFile, CurFile, % "%U3_APP_DATA_PATH%", %U3_APP_DATA_PATH%, A
      StringReplace CurFile, CurFile, % "%U3_DEVICE_DOCUMENT_PATH%", %U3_DEVICE_DOCUMENT_PATH%, A
      StringReplace CurFile, CurFile, % "%U3_DEVICE_EXEC_PATH%", %U3_DEVICE_EXEC_PATH%, A
      FileGetAttrib FilAttr, %CurFile%
      IfInString FilAttr, D
      {
        Status("Removing directory #" . A_Index . " from host system ...")
        FileRemoveDir %CurFile%, 1
      }
      Else
      {
        Status("Removing file #" . A_Index . " from host system ...")
        FileDelete %CurFile%
      }
    }
  }

  Status("")
  If (U3_IS_DEVICE_AVAILABLE = "true")
  {
    IniDelete %INIFile%, U3Helper, ForeignSettings
    IniDelete %INIFile%, U3Helper, KeepSettings
  }
}
Else If 1 = appstart
{
  EnvSet USERPROFILE, %U3_APP_DATA_PATH%
  EnvSet HOMEPATH, %U3_APP_DATA_PATH%
  EnvSet APPDATA, %U3_APP_DATA_PATH%\Application Data
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
  RunWait %cmdl%
}
Else If 1 = appstop
{
  Counter = 0
  
  ToolTip Closing %AppName% ...
  
  TryClose:
  Process Exist, %AppExe%
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
}
Else
{
  MsgBox No parameter given.
}
