; ##########################################################################
; ###                                                                    ###
; ### hostConfigure                                                      ###
; ###                                                                    ###
; ##########################################################################

Menu Tray, Icon
TrayTip Preparing %AppName% ..., U3Helper %U3HVer%`n(c)2006 Markus Birth`nmbirth@webwriters.de, 3, 1

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
    Status("Backing up registry settings #" . A_Index . " " . StrCopy(".", A_Index))
    RunWait regedit /E "%U3_HOST_EXEC_PATH%\U3Hregbak%A_Index%.reg" "%CurBranch%"
    Status("Cleaning registry settings #" . A_Index . " " . StrCopy(".", A_Index))
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
    Status("Importing registry settings #" . A_Index . " " . StrCopy(".", A_Index))
    RunWait regedit /S "%U3_APP_DATA_PATH%\regdata%A_Index%.reg"
  }
  IfExist %U3_APP_DATA_PATH%\regdataX.reg
  {
    Status("Importing special registry settings ...")
    RunWait regedit /S "%U3_APP_DATA_PATH%\regdataX.reg"
  }
  Loop %regbak0%
  {
    Status("Translating paths in registry #" . A_Index . " " . StrCopy(".", A_Index))
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
    Status("Copying data directory " . CurFile . " " . StrCopy(".", A_Index))
    FileCopyDir %U3_APP_DATA_PATH%\%CurFile%, %U3_HOST_EXEC_PATH%\%CurFile%, 1
  }
  Else
  {
    Status("Copying data file " . CurFile . " " . StrCopy(".", A_Index))
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
    Status("Registering file " . CurDLL . " " . StrCopy(".", A_Index))
    RunWait regsvr32 /S "%U3_HOST_EXEC_PATH%\%CurDLL%"
  }
}
Status("")
