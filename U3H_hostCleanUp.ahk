; ##########################################################################
; ###                                                                    ###
; ### hostCleanUp                                                        ###
; ###                                                                    ###
; ##########################################################################
 
StepsAll = 0
If (StrLen(RunBeforeEject) > 0)
  StepsAll++
If regsvr0 > 0
  StepsAll++
If dattxt0 > 0
  StepsAll++
If datexe0 > 0
  StepsAll += 2
If regbak0 > 0
  StepsAll += 2
IfExist %U3_APP_DATA_PATH%\regdataX.reg
  StepsAll++
If regdel0 > 0
  StepsAll++
If fildel0 > 0
  StepsAll++
StepsStep := 100/StepsAll
StepsPos = 0

Progress b2 x%PL% y%PT% w%PW% m FM%PFM% FS%PFS%, U3Helper %U3HVer% - (c)2006-2007 Markus Birth <mbirth@webwriters.de>, Cleaning up %AppName% ..., AHKProgress-%AppName%
WinSet Transparent, %PTrans%, AHKProgress-%AppName%

If (StrLen(RunBeforeEject) > 0)
{
  Progress % StepsPos*StepsStep, Running shutdown command ...
  RunBeforeEject := EnvParseStr(RunBeforeEject)
  RunWait %RunBeforeEject%
  StepsPos++
}

If (U3_IS_DEVICE_AVAILABLE <> "true")
{
  ; U3 stick not plugged in!!
  MsgBox 4112, U3 Device Not Available (%U3_IS_DEVICE_AVAILABLE%), Your U3 Device seems to be disconnected. The settings cannot be saved!`n`nAll your changes made since plugging in the U3 Device are likely to be lost. Try to manually save them now.`n`n%U3_HOST_EXEC_PATH%`n`nAfter pressing OK, registry entries will be removed.
  If regbak0 > 0
    StepsPos++
  If datexe0 > 0
    StepsPos++
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

  ;******************************************************************************

  IniRead ForeignSettings, %INIFile%, U3Helper, ForeignSettings, 0
  If (ForeignSettings = "0")
  {
    Loop %regbak0%
    {
      Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/regbak0, Translating paths in registry #%A_Index% ...
      CurBranch := regbak%A_Index%
      SplitFirst(RegRoot, RegSub, CurBranch, "\")
      Loop %RegRoot%, %RegSub%, 0, 1
      {
        If (A_LoopRegType = "REG_SZ" or A_LoopRegType = "REG_EXPAND_SZ" or A_LoopRegType = "REG_MULTI_SZ")
        {
          RegRead RegValue
          NewRegValue := EnvUnparseStr(RegValue)
          If (NewRegValue <> RegValue)
          {
            RegWrite %NewRegValue%
          }
        }
      }
      Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/regbak0, Saving registry settings #%A_Index% ...
      RunWait regedit /E "%U3_APP_DATA_PATH%\regdata%A_Index%.reg" "%CurBranch%"
    }
  }
  
  If regbak0 > 0
    StepsPos++

  ;******************************************************************************

  ;Copy data files
  SetWorkingDir %U3_HOST_EXEC_PATH%
  CopyErrors := ""
  Loop %datexe0%
  {
    OutIndex = %A_Index%
    CurMask := datexe%A_Index%
    Copied = 0
    Skipped = 0
    Errors = 0
    Dirs = 0
    CopyErrors := ""

    FileGetAttrib FAttr, %CurMask%
    IfInString FAttr, D
      CurMask .= "\*.*"

    FileCount = 0
    Loop %CurMask%, 1, 1
    {
      FileCount++
    }
    Loop %CurMask%, 1, 1
    {
      CurFile := A_LoopFileFullPath
      TargFile := U3_APP_DATA_PATH . "\" . CurFile
      FileGetAttrib FAttr, %CurFile%
      IfInString FAttr, D
      {
        ; also create empty directories
        Progress % StepsPos*StepsStep+StepsStep*(OutIndex-1.00+(A_Index/FileCount))/datexe0, Creating directory %CurFile% ... (CPY:%Copied% / DIR:%Dirs% / ERR:%Errors%)
        FileCreateDir %TargFile%
        Dirs++
      }
      Else 
      {
        Progress % StepsPos*StepsStep+StepsStep*(OutIndex-1.00+(A_Index/FileCount))/datexe0, Copying data %CurFile% ... (CPY:%Copied% / DIR:%Dirs% / ERR:%Errors%)
        FileCopyNewer(CurFile, TargFile)
        If ErrorLevel = 2
        {
          CopyErrors .= "Dir-entry: " . CurFile . "\" . A_LoopFileFullPath . " (Error while copying)`n"
          Errors++
        }
        Else If ErrorLevel = 1
        {
          CopyErrors .= "Dir-entry: " . CurFile . "\" . A_LoopFileFullPath . " (File does not exist)`n"
          Errors++
        }
        Else If ErrorLevel = -1
          Skipped++
        Else
          Copied++
      }
    }
  }
  SetWorkingDir %A_ScriptDir%

  If (CopyErrors <> "")
    MsgBox 4112, Error while copying, Following files could not be backed up:`n`n%CopyErrors%`n`nTry to manually save them now.`n`n%U3_HOST_EXEC_PATH%`n`nAfter pressing OK, those files will be deleted.

  If datexe0 > 0
    StepsPos++

  ;******************************************************************************
  
  ;Cleaning deleted files from stick
  SetWorkingDir %U3_APP_DATA_PATH%
  Loop %datexe0%
  {
    OutIndex = %A_Index%
    CurMask := datexe%A_Index%
    Deleted = 0
    Skipped = 0
    Errors = 0

    FileGetAttrib FAttr, %CurMask%
    IfInString FAttr, D
      CurMask .= "\*.*"

    FileCount = 0
    Loop %CurMask%, 1, 1
    {
      FileCount++
    }
    Loop %CurMask%, 1, 1
    {
      CurFile := A_LoopFileFullPath
      Progress % StepsPos*StepsStep+StepsStep*(OutIndex-1.00+(A_Index/FileCount))/datexe0, Cleaning data %CurFile% ... (DEL:%Deleted% / SKP:%Skipped% / ERR:%Errors%)
      TargFile := U3_HOST_EXEC_PATH . "\" . CurFile
      IfExist %TargFile%
      {
        ; file still exists on host
        Skipped++
        Continue
      }
      ; target directory or file doesn't exist anymore, delete on U3
      FileSetAttrib -RSH, %CurFile%
      FileGetAttrib FAttr, %CurFile%
      IfInString FAttr, D
      {
        ; target is a directory
        FileSetAttrib -RSH, %CurFile%\*.*, 1, 1
        FileRemoveDir %CurFile%, 1
        If ErrorLevel
          Errors++
        Else
          Deleted++
      }
      Else
      {
        ; target is a single file only
        FileDelete %CurFile%
        If ErrorLevel
          Errors++
        Else
          Deleted++
      }
    }
  }
  SetWorkingDir %A_ScriptDir%
  
  If datexe0 > 0
    StepsPos++

  ;******************************************************************************

  ;Translate paths in text files
  SetWorkingDir %U3_APP_DATA_PATH%
  Loop %dattxt0%
  {
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/dattxt0, Translating paths in file %CurFile% ...
    CurMask := dattxt%A_Index%
    Loop %CurMask%
    {
      CurFile := A_LoopFileFullPath
      TmpFile := A_LoopFileDir . "\$$$" . A_LoopFileName
      FileMove %U3_APP_DATA_PATH%\%CurFile%, %U3_APP_DATA_PATH%\%TmpFile%, 1
      Progress % StepsPos*StepsStep+StepsStep*(A_Index-0.5)/dattxt0, Translating paths in file %CurFile% ...
      Loop Read, %U3_APP_DATA_PATH%\%TmpFile%, %U3_APP_DATA_PATH%\%CurFile%
      {
        IfNotInString A_LoopReadLine, \
        {
          ; no paths to replace --- skip processing
          FileAppend %A_LoopReadLine%`n
          Continue
        }
        FileAppend % EnvUnparseStr(A_LoopReadLine) . "`n"
      }
      IfExist %U3_APP_DATA_PATH%\%CurFile%
      {
        FileDelete %U3_APP_DATA_PATH%\%TmpFile%
      }
      Else
      {
        FileMove %U3_APP_DATA_PATH%\%TmpFile%, %U3_APP_DATA_PATH%\%CurFile%
        MsgBox 4112, Error while translating, The datafile %CurFile% could not be translated. The original state has been restored (hopefully).
      }
    }
  }
  SetWorkingDir %A_ScriptDir%

  If dattxt0 > 0
    StepsPos++
}

;******************************************************************************

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
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/regbak0, Removing registry settings #%A_Index% from host ...
    CurBranch := regbak%A_Index%
    SplitFirst(RegRoot, RegSub, CurBranch, "\")
    RegDelete %RegRoot%, %RegSub%
    If (RevertSettings = "1")
    {
      Progress % StepsPos*StepsStep+StepsStep*(A_Index-0.5)/regbak0, Restoring registry settings #%A_Index% from backup ...
      RunWait regedit /S "%U3_HOST_EXEC_PATH%\U3Hregbak%A_Index%.reg"
    }
  }
}

If regbak0 > 0
  StepsPos++
  
;******************************************************************************

If (KeepSettings = "0" or Unattended = "1")
{

  ;******************************************************************************

  Loop %regdel0%
  {
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/regdel0, Removing add. registry settings #%A_Index% from host ...
    CurBranch := regdel%A_Index%
    SplitFirst(RegRoot, RegSub, CurBranch, "\")
    RegDelete %RegRoot%, %RegSub%
  }
  
  If regdel0 > 0
    StepsPos++

  ;******************************************************************************

  ; regsvr32 stuff
  Loop %regsvr0%
  {
    CurDLL := regsvr%A_Index%
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/regsvr0, Unregistering file %CurDLL% ...
    RunWait regsvr32 /S /U "%U3_HOST_EXEC_PATH%\%CurDLL%"
  }
  
  If regsvr0 > 0
    StepsPos++
  
  ;******************************************************************************

  ; remove files
  ; if not specified, all file operations run on A_ScriptDir which is U3_HOST_EXEC_PATH
  Loop %fildel0%
  {
    OutIndex = %A_Index%
    CurMask := fildel%A_Index%
    Deleted = 0
    Errors = 0
    Skipped = 0
    
    CurMask := EnvParseStr(CurFile)
    FileGetAttrib FAttr, %CurMask%
    IfInString FAttr, D
      CurMask .= "\*.*"
    
    FileCount = 0
    Loop %CurMask%, 1, 1
    {
      FileCount++
    }
    Loop %CurMask%, 1, 1
    {
      CurFile := A_LoopFileFullPath
      Progress % StepsPos*StepsStep+StepsStep*(OutIndex-1.00+(A_Index/FileCount))/fildel0, Removing data %CurFile% from host ... (DEL:%Deleted% / SKP:%Skipped% / ERR:%Errors%)
      IfNotExist %CurFile%
      {
        Skipped++
        Continue
      }
      FileSetAttrib -RSH, %CurFile%
      FileGetAttrib FAttr, %CurFile%
      IfInString FAttr, D
      {
        ; target is a directory
        FileSetAttrib -RSH, %CurFile%\*.*, 1, 1
        FileRemoveDir %CurFile%, 1
        If ErrorLevel
          Errors++
        Else
          Deleted++
      }
      Else
      {
        ; target is a single file only
        FileDelete %CurFile%
        If ErrorLevel
          Errors++
        Else
          Deleted++
      }
    }
  }
  
  If fildel0 > 0
    StepsPos++

  ;******************************************************************************

}
Else
{
  If regdel0 > 0
    StepsPos++
  If regsvr0 > 0
    StepsPos++
  If fildel0 > 0
    StepsPos++
}

;******************************************************************************

Progress 100, hostCleanUp done.

If (U3_IS_DEVICE_AVAILABLE = "true")
{
  IniDelete %INIFile%, U3Helper, ForeignSettings
  IniDelete %INIFile%, U3Helper, KeepSettings
}
