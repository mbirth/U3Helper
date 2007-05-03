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

  ;Copy data files
  CopyErrors := ""
  Loop %datexe0%
  {
    CurFile := datexe%A_Index%
    FileGetAttrib FilAttr, %U3_HOST_EXEC_PATH%\%CurFile%
    IfInString FilAttr, D
    {
      ; CurFile is a directory
      IfExist %U3_HOST_EXEC_PATH%\%CurFile%
      {
        Copied = 0
        Skipped = 0
        Errors = 0
        OutIndex = %A_Index%
        FileCount = 0
        SetWorkingDir %U3_HOST_EXEC_PATH%\%CurFile%
        Loop *.*, 1, 1
        {
          FileCount++
        }
        Loop *.*, 1, 1
        {
          Progress % StepsPos*StepsStep+StepsStep*(OutIndex-1.00+(A_Index/FileCount))/datexe0, Saving data directory %CurFile% ... (CPY:%Copied% / SKP:%Skipped% / ERR:%Errors%)
          FileGetAttrib FAttr, %A_LoopFileLongPath%
          IfInString FAttr, D
          {
            IfNotExist %U3_APP_DATA_PATH%\%CurFile%\%A_LoopFileFullPath%
              FileCreateDir %U3_APP_DATA_PATH%\%CurFile%\%A_LoopFileFullPath%
            If ErrorLevel
              Errors++
            Else
              Copied++
          }
          Else
          {
            FileCopyNewer(A_LoopFileLongPath, U3_APP_DATA_PATH . "\" CurFile . "\" . A_LoopFileFullPath)
            If ErrorLevel = 2
            {
              CopyErrors .= "Dir-entry: " . CurFile . "\" . A_LoopFileFullPath . " (Error while copying)`n"
              Errors++
            }
            else if ErrorLevel = 1
            {
              CopyErrors .= "Dir-entry: " . CurFile . "\" . A_LoopFileFullPath . " (File does not exist)`n"
              Errors++
            }
            else if ErrorLevel = -1
              Skipped++
            else
              Copied++
          }
        }
        SetWorkingDir %A_ScriptDir%
      }
      Else
      {
        ; Folder got deleted in the meantime, remove it from backup
        Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/datexe0, Removing data directory %CurFile% ...
        FileSetAttrib -RSH, %U3_APP_DATA_PATH%\%CurFile%
        FileSetAttrib -RSH, %U3_APP_DATA_PATH%\%CurFile%\*.*, 1, 1
        FileRemoveDir %U3_APP_DATA_PATH%\%CurFile%, 1
      }
    }
    Else
    {
      ; CurFile is a file
      IfExist %U3_HOST_EXEC_PATH%\%CurFile%
      {
        Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/datexe0, Saving data file %CurFile% ...
        FileCopyNewer(U3_HOST_EXEC_PATH . "\" . CurFile, U3_APP_DATA_PATH . "\" . CurFile)
        If ErrorLevel > 0
          CopyErrors .= "File: " . CurFile . "`n"
      }
      Else
      {
        ; File got deleted in the meantime, remove it from backup
        Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/datexe0, Removing data file %CurFile% ...
        FileSetAttrib -RSH, %U3_APP_DATA_PATH%\%CurFile%
        FileDelete %U3_APP_DATA_PATH%\%CurFile%
      }
    }
  }

  If (CopyErrors <> "")
    MsgBox 4112, Error while copying, Following files could not be backed up:`n`n%CopyErrors%`n`nTry to manually save them now.`n`n%U3_HOST_EXEC_PATH%`n`nAfter pressing OK, those files will be deleted.

  If datexe0 > 0
    StepsPos++

  Loop %datexe0%
  {
    CurFile := datexe%A_Index%
    FileGetAttrib FilAttr, %U3_APP_DATA_PATH%\%CurFile%
    IfInString FilAttr, D
    {
      ; CurFile is a directory
      IfExist %U3_APP_DATA_PATH%\%CurFile%
      {
        Deleted = 0
        Skipped = 0
        Errors = 0
        OutIndex = %A_Index%
        FileCount = 0
        SetWorkingDir %U3_APP_DATA_PATH%\%CurFile%
        Loop *.*, 1, 1
        {
          FileCount++
        }
        Loop *.*, 1, 1
        {
          Progress % StepsPos*StepsStep+StepsStep*(OutIndex-1.00+(A_Index/FileCount))/datexe0, Cleaning data directory %CurFile% ... (DEL:%Deleted% / SKP:%Skipped% / ERR:%Errors%)
          IfNotExist %U3_HOST_EXEC_PATH%\%CurFile%\%A_LoopFileFullPath%
          {
            ; file doesn't exist on host, also delete on U3 drive
            FileGetAttrib FAttr, %A_LoopFileLongPath%
            IfInString FAttr, D
            {
              FileSetAttrib -RSH, %A_LoopFileLongPath%
              FileSetAttrib -RSH, %A_LoopFileLongPath%\*.*, 1, 1
              FileRemoveDir %A_LoopFileLongPath%, 1
              If ErrorLevel
                Errors++
              Else
                Deleted++
            }
            Else
            {
              FileSetAttrib -RSH, %A_LoopFileLongPath%
              FileDelete %A_LoopFileLongPath%
              If ErrorLevel
                Errors++
              Else
                Deleted++
            }
          }
          Else
          {
            ; file still exists on host, leave it also on U3 drive
            Skipped++
          }
        }
        SetWorkingDir %A_ScriptDir%
      }
    }    
  }
  
  If datexe0 > 0
    StepsPos++

  ;Translate paths in text files
  Loop %dattxt0%
  {
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/dattxt0, Translating paths in file %CurFile% ...
    CurFile := dattxt%A_Index%
    IfExist %U3_APP_DATA_PATH%\%CurFile%
    {
      TmpFile := "$$$" . CurFile
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

  If dattxt0 > 0
    StepsPos++
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
  
If (KeepSettings = "0" or Unattended = "1")
{
  Loop %regdel0%
  {
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/regdel0, Removing add. registry settings #%A_Index% from host ...
    CurBranch := regdel%A_Index%
    SplitFirst(RegRoot, RegSub, CurBranch, "\")
    RegDelete %RegRoot%, %RegSub%
  }
  
  If regdel0 > 0
    StepsPos++

  ; regsvr32 stuff
  Loop %regsvr0%
  {
    CurDLL := regsvr%A_Index%
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/regsvr0, Unregistering file %CurDLL% ...
    RunWait regsvr32 /S /U "%U3_HOST_EXEC_PATH%\%CurDLL%"
  }
  
  If regsvr0 > 0
    StepsPos++
  
  ; remove files
  Loop %fildel0%
  {
    CurFile := fildel%A_Index%
    CurFile := EnvParseStr(CurFile)
    FileGetAttrib FilAttr, %CurFile%
    IfInString FilAttr, D
    {
      Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/fildel0, Removing directory #%A_Index% from host ...
      FileSetAttrib -RSH, %CurFile%
      FileSetAttrib -RSH, %CurFile%\*.*, 1, 1
      FileRemoveDir %CurFile%, 1
    }
    Else
    {
      Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/fildel0, Removing file #%A_Index% from host ...
      FileSetAttrib -RSH, %CurFile%
      FileDelete %CurFile%
    }
  }
  
  If fildel0 > 0
    StepsPos++
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

Progress 100, hostCleanUp done.

If (U3_IS_DEVICE_AVAILABLE = "true")
{
  IniDelete %INIFile%, U3Helper, ForeignSettings
  IniDelete %INIFile%, U3Helper, KeepSettings
}
