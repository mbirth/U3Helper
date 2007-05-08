#NoEnv

EnvVars0 = 0
EnvVals0 = 0

; initial list of EnvVars to load
EnvVarsAll := "U3_DEVICE_PATH,U3_DEVICE_DOCUMENT_PATH,U3_DEVICE_VENDOR,U3_DEVICE_PRODUCT,U3_APP_DATA_PATH,U3_HOST_EXEC_PATH"
EnvVarsAll .= ",U3_DEVICE_EXEC_PATH,ALLUSERSPROFILE,APPDATA,CommonProgramFiles,HOMEPATH,ProgramFiles,SystemRoot,USERPROFILE,TEMP,windir"

StringSplit EnvVars, EnvVarsAll, `,%A_Space%

; Load EnvVar-Values and store in EnvVals-array
Loop %EnvVars0%
{
  EnvName := EnvVars%A_Index%
  EnvGet EnvVals%A_Index%, %EnvName%
}
EnvVals0 = %EnvVars0%
EnvSort()

;******************************************************************************


EnvSort()
{
  global
  local CurIndex, CurNam, CurVal, MaxIndex, MaxLen

  Loop %EnvVars0%
  {
    EnvVarsx%A_Index% := EnvVars%A_Index%
    EnvValsx%A_Index% := EnvVals%A_Index%
  }
  EnvVarsx0 := EnvVars0
  EnvValsx0 := EnvVals0
  
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
      If ((StrLen(CurVal) > MaxLen) and (StrLen(CurNam) > 1))
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
}

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

EnvValue(envname, add = 1)
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
  If (add && StrLen(result) > 0)
  {
    ; seems like a result ~~> add to list
    EnvAddX(envname, result)
    EnvSort()
  }
  return result
}

EnvAddX(var, val = "%%")
{
  global
  local MyPointer
  If (val = "%%")
  {
    EnvGet val, %var%
  }
  If (StrLen(val) > 0)
  {
    MyPointer := ++EnvVars0
    EnvVars%MyPointer% := var
    EnvVals%MyPointer% := val
    EnvVals0++
    return 1
  }
  return 0
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
