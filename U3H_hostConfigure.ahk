; ##########################################################################
; ###                                                                    ###
; ### hostConfigure                                                      ###
; ###                                                                    ###
; ##########################################################################

StepsAll = 0
If regsvr0 > 0
  StepsAll++
If datexe0 > 0
  StepsAll++
If regbak0 > 0
  StepsAll += 3
IfExist %U3_APP_DATA_PATH%\regdataX.reg
  StepsAll++
StepsStep := 100/StepsAll
StepsPos = 0

Progress b2 x%PL% y%PT% w%PW% m FM%PFM% FS%PFS%, U3Helper %U3HVer% - (c)2006-2007 Markus Birth <mbirth@webwriters.de>, Preparing %AppName% ..., AHKProgress-%AppName%
WinSet Transparent, %PTrans%, AHKProgress-%AppName%

Progress, , Checking registry settings...
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
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/regbak0, Backing up registry settings #%A_Index% ...
    RunWait regedit /E "%U3_HOST_EXEC_PATH%\U3Hregbak%A_Index%.reg" "%CurBranch%"
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-0.5)/regbak0, Cleaning registry settings #%A_Index% ...
    RegDelete %RegRoot%, %RegSub%
  }
}

If regbak0 > 0
  StepsPos++

If (keycount > 0)
{
  Progress % StepsPos*StepsStep, Registry settings found!
  IniWrite 1, %INIFile%, U3Helper, KeepSettings
  If (Unattended = "0")
  {
    MsgBox 4132, %AppName%: Duplicate settings, Settings for %AppName% were already found on this PC. Do you want to use them?`n`nIf you select NO, the local settings will be overwritten by those saved on your U3 stick.`n(They have been backed up and can be restored upon eject of the stick.)
    IfMsgBox Yes
    {
      IniWrite 1, %INIFile%, U3Helper, ForeignSettings
      StepsPos += 2
    }
  }
}
IniRead ForeignSettings, %INIFile%, U3Helper, ForeignSettings, 0
If (ForeignSettings = "0")
{
  Loop %regbak0%
  {
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/regbak0, Importing registry settings #%A_Index% ...
    RunWait regedit /S "%U3_APP_DATA_PATH%\regdata%A_Index%.reg"
  }
  If regbak0 > 0
    StepsPos++
  IfExist %U3_APP_DATA_PATH%\regdataX.reg
  {
    Progress % StepsPos*StepsStep, Importing special registry settings ...
    RunWait regedit /S "%U3_APP_DATA_PATH%\regdataX.reg"
    StepsPos++
  }
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
        NewRegValue := EnvParseStr(RegValue)
        If (NewRegValue <> RegValue)
        {
          RegWrite %NewRegValue%
        }
      }
    }
  }
  If regbak0 > 0
    StepsPos++
}


;Copy data files
Loop %datexe0%
{
  CurFile := datexe%A_Index%
  FileGetAttrib FilAttr, %U3_APP_DATA_PATH%\%CurFile%
  IfInString FilAttr, D
  {
    Copied = 0
    Errors = 0
    OutIndex = %A_Index%
    FileCount = 0
    SetWorkingDir %U3_APP_DATA_PATH%\%CurFile%
    Loop *.*, 0, 1
    {
      FileCount++
    }
    IfNotExist %U3_HOST_EXEC_PATH%\%CurFile%
      FileCreateDir %U3_HOST_EXEC_PATH%\%CurFile%
    Loop *.*, 0, 1
    {
      Progress % StepsPos*StepsStep+StepsStep*(OutIndex-1.00+(A_Index/FileCount))/datexe0, Copying data directory %CurFile% ... (CPY:%Copied% / ERR:%Errors%)
      IfNotExist %U3_HOST_EXEC_PATH%\%CurFile%\%A_LoopFileDir%
        FileCreateDir %U3_HOST_EXEC_PATH%\%CurFile%\%A_LoopFileDir%
      FileCopy %A_LoopFileLongPath%, %U3_HOST_EXEC_PATH%\%CurFile%\%A_LoopFileFullPath%, 1
      If ErrorLevel
        Errors++
      Else
        Copied++
    }
    SetWorkingDir %A_ScriptDir%
    ; FileCopyDir %U3_APP_DATA_PATH%\%CurFile%, %U3_HOST_EXEC_PATH%\%CurFile%, 1
  }
  Else
  {
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/datexe0, Copying data file %CurFile% ...
    FileCopy %U3_APP_DATA_PATH%\%CurFile%, %U3_HOST_EXEC_PATH%\%CurFile%, 1
  }
}

If datexe0 > 0
  StepsPos++

; regsvr32 stuff
IniRead KeepSettings, %INIFile%, U3Helper, KeepSettings, 0
If (KeepSettings = "0")
{
  Loop %regsvr0%
  {
    CurDLL := regsvr%A_Index%
    Progress % StepsPos*StepsStep+StepsStep*(A_Index-1)/regsvr0, Registering file %CurDLL% ...
    RunWait regsvr32 /S "%U3_HOST_EXEC_PATH%\%CurDLL%"
  }
}

If regsvr0 > 0
  StepsPos++

Progress 100, hostConfigure done.
