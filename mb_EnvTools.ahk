#NoEnv

EnvVars0 = 0
EnvVals0 = 0

; initial list of EnvVars to load
EnvVarsAll := "U3_DEVICE_SERIAL,U3_DEVICE_PATH,U3_DEVICE_DOCUMENT_PATH,U3_DEVICE_VENDOR,U3_DEVICE_PRODUCT,U3_DEVICE_VENDOR_ID"
EnvVarsAll .= ",U3_APP_DATA_PATH,U3_HOST_EXEC_PATH,U3_DEVICE_EXEC_PATH,U3_ENV_VERSION,U3_ENV_LANGUAGE,U3_IS_UPGRADE"
EnvVarsAll .= ",U3_IS_DEVICE_AVAILABLE,U3_IS_AUTORUN,U3_DAPI_CONNECT_STRING"
EnvVarsAll .= ",ALLUSERSPROFILE,APPDATA,CommonProgramFiles,HOMEPATH,ProgramFiles,SystemRoot,USERPROFILE,TEMP,windir"

StringSplit EnvVarsx, EnvVarsAll, `,%A_Space%

; Load EnvVar-Values and store in EnvVals-array
Loop %EnvVarsx0%
{
  EnvName := EnvVarsx%A_Index%
  EnvGet EnvValsx%A_Index%, %EnvName%
}
EnvValsx0 = %EnvVarsx0%

; Sort EnvVar-Values by StrLen() for re-replacement (value to var)
; and clean out empty vars
CurIndex = 1
Loop %EnvVarsx0%
{
  MaxIndex = -1
  MaxLen = -1
  Loop %EnvValsx0%
  {
    CurNam := EnvVarsx%A_Index%
    CurVal := EnvValsx%A_Index%
    If ((StrLen(CurVal) >= MaxLen) and (StrLen(CurNam) > 0))
    {
      MaxLen := StrLen(CurVal)
      MaxIndex := A_Index
    }
  }
  If (StrLen(EnvValsx%MaxIndex%) > 0)
  {
    EnvVars%CurIndex% := EnvVarsx%MaxIndex%
    EnvVals%CurIndex% := EnvValsx%MaxIndex%
    CurIndex++
  }
  EnvVarsx%MaxIndex% := ""
  EnvValsx%MaxIndex% := ""
}

EnvVars0 := CurIndex-1
EnvVals0 := CurIndex-1

; Debugging stuff:
;MsgBox % "comspec:" . EnvValue("comspec")
;MsgBox % EnvList()
;MsgBox % EnvParseStr("This is a %temp% test running %comspec%!")




EnvList()
{
  global
  local result
  result := ""
  Loop %EnvVars0%
  {
    result .= EnvVars%A_Index% . " = " . EnvVals%A_Index% . "`n"
  }
  return result
}

EnvValue(envname)
{
  global
  local result
  result := ""
  Loop %EnvVars0%
  {
    If (EnvVars%A_Index% = envname)
    {
      return EnvVals%A_Index%
    }
  }
  ; EnvVar not in list - try to catch it
  EnvGet result, %envname%
  If (StrLen(result) > 0)
  {
    ; seems like a result ~~> add to list
    MyPointer := ++EnvVars0
    EnvVars%MyPointer% := envname
    EnvVals%MyPointer% := result
    EnvVals0++
  }
  return result
}

EnvParseStr(instring)
{
  global
  local ReplFrom, ReplTo
  Loop %EnvVars0%
  {
    ReplFrom := "%" . EnvVars%A_Index% . "%"
    ReplTo := EnvVals%A_Index%
    StringReplace instring, instring, %ReplFrom%, %ReplTo%, A
  }
  return instring
}

EnvUnparseStr(instring)
{
  global
  local ReplFrom, ReplTo
  Loop %EnvVals0%
  {
    ReplFrom := EnvVals%A_Index%
    ReplTo := "%" . EnvVars%A_Index% . "%"
    StringReplace instring, instring, %ReplFrom%, %ReplTo%, A
  }
  return instring
}
