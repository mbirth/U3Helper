#Include mb_TextTools.ahk

; Gets all keys in a section and assigns them to an array.
; Result contains the name of the new array as string
IniGetKeys(Result, IniFile, IniSection)
{
  global
  %Result%0 = 0
  local i, Inside, TrimLine, SectTest, cp, Key, Value
  i = 1
  Inside = 0
  Loop Read, %IniFile%
  {
    TrimLine = %A_LoopReadLine%
    SectTest := IniGetSectFromLine(A_LoopReadLine)
    If (Inside = 0 and SectTest = IniSection)
    {
      Inside = 1
      Continue
    }
    If (Inside = 1 and StrLen(SectTest) > 0)
    {
      Inside = 0
      Break
    }
    StringLeft cp, TrimLine, 1
    If (cp = ";")
    {
      ; It's a comment line
      Continue
    }
    If (Inside = 1 and StrLen(TrimLine) > 0)
    {
      SplitFirst(Key, Value, A_LoopReadLine, "=")
      %Result%%i% = %Key%
      i++
    }
  }
  %Result%0 := i-1
  return i-1
}

; Check whether Probe is something like [blabla] and return "blabla"
; if it's no section, return an empty string
IniGetSectFromLine(Probe)
{
  result := ""
  Probe = %Probe%  ; trim whitespaces or tabs
  StringLeft ls, Probe, 1
  StringRight rs, Probe, 1
  If (ls = "[" and rs = "]")
  {
    sl := StrLen(Probe) - 2
    StringMid result, Probe, 2, %sl%
  }
  return result
}
