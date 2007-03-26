; ##########################################################################
; ###                                                                    ###
; ### hostCleanUp                                                        ###
; ###                                                                    ###
; ##########################################################################
 
If (U3_IS_DEVICE_AVAILABLE <> "true")
{
  ; U3 stick not plugged in!!
  MsgBox 4112, U3 Device Not Available (%U3_IS_DEVICE_AVAILABLE%), Your U3 Device seems to be disconnected. The settings cannot be saved!`n`nAll your changes made since plugging in the U3 Device are likely to be lost. Try to manually save them now.`n`n%U3_HOST_EXEC_PATH%`n`nAfter pressing OK, registry entries will be removed.
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
  CopyErrors := ""
  Loop %datexe0%
  {
    CurFile := datexe%A_Index%
    FileGetAttrib FilAttr, %U3_HOST_EXEC_PATH%\%CurFile%
    IfInString FilAttr, D
    {
      IfExist %U3_HOST_EXEC_PATH%\%CurFile%
      {
        Status("Saving data directory " . CurFile . " ...")
        SetWorkingDir %U3_HOST_EXEC_PATH%\%CurFile%
        Loop *.*, 0, 1
        {
          FileCopyNewer(A_LoopFileLongPath, U3_APP_DATA_PATH . "\" CurFile . "\" . A_LoopFileFullPath)
          If ErrorLevel
            CopyErrors := CopyErrors . "Dir-entry: " . CurFile . "\" . A_LoopFileFullPath . "`n"
        }
        SetWorkingDir %A_ScriptDir%
      }
      Else
      {
        ; Folder got deleted in the meantime, remove it from backup
        Status("Removing data directory " . CurFile . " ...")
        FileRemoveDir %U3_APP_DATA_PATH%\%CurFile%, 1
      }
    }
    Else
    {
      IfExist %U3_HOST_EXEC_PATH%\%CurFile%
      {
        Status("Saving data file " . CurFile . " ...")
        FileCopyNewer(U3_HOST_EXEC_PATH . "\" . CurFile, U3_APP_DATA_PATH . "\" . CurFile)
        If ErrorLevel
          CopyErrors := CopyErrors . "File: " . CurFile . "`n"
      }
      Else
      {
        ; File got deleted in the meantime, remove it from backup
        Status("Removing data file " . CurFile . " ...")
        FileSetAttrib -RSH, %U3_APP_DATA_PATH%\%CurFile%
        FileDelete %U3_APP_DATA_PATH%\%CurFile%
      }
    }
  }
  If (CopyErrors <> "")
    MsgBox 4112, Error while copying, Following files could not be backed up:`n`n%CopyErrors%`n`nTry to manually save them now.`n`n%U3_HOST_EXEC_PATH%`n`nAfter pressing OK, those files will be deleted.
}

IniRead KeepSettings, %INIFile%, U3Helper, KeepSettings, 0
RevertSettings := "0"
If (KeepSettings <> "0")
{
  If (Unattended = "0")
  {
    MsgBox 4131, %AppName%: Foreign settings, Do you want to keep the changed settings for %AppName%?`n`n(Select No to revert to the former settings. Cancel to erase settings.)
    IfMsgBox No
    {
      RevertSettings := "1"
    }
    IfMsgBox Cancel
    {
      KeepSettings := "0"
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
If (KeepSettings = "0" or Unattended = "1")
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
