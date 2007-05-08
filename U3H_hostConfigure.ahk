; ##########################################################################
; ###                                                                    ###
; ### hostConfigure                                                      ###
; ###                                                                    ###
; ##########################################################################

StepsAll = 0
IfNotExist %U3_HOST_EXEC_PATH%\%A_ScriptName%
  StepsAll++
If regsvr0 > 0
  StepsAll++
If dattxt0 > 0
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

; made following step not to display b/c it occurs only once on the first launch of any U3H-app
IfNotExist %U3_HOST_EXEC_PATH%\%A_ScriptName%
{
  Progress % StepsPos*StepsStep, Copying U3Helper to disk...
  FileCopy %A_ScriptFullPath%, %U3_HOST_EXEC_PATH%\%A_ScriptName%, 0
  StepsPos++
}

;******************************************************************************

Progress % StepsPos*StepsStep, Checking registry settings...
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
      IfNotInString A_LoopReadLine, `%
      {
        ; no envvars to replace --- skip processing
        FileAppend %A_LoopReadLine%`n
        Continue
      }
      FileAppend % EnvParseStr(A_LoopReadLine) . "`n"
  
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

;******************************************************************************

;Copy data files
SetWorkingDir %U3_APP_DATA_PATH%
Loop %datexe0%
{
  OutIndex = %A_Index%
  CurMask := datexe%A_Index%
  Copied = 0
  Errors = 0
  Dirs = 0
  
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
    TargFile := U3_HOST_EXEC_PATH . "\" . CurFile
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
      If ErrorLevel > 0
        Errors++
      Else
        Copied++
    }
  }
}
SetWorkingDir %A_ScriptDir%

If datexe0 > 0
  StepsPos++

;******************************************************************************

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

;******************************************************************************

Progress 100, hostConfigure done.
