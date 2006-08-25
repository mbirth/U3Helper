SplitFirst(ByRef OutLeft, ByRef OutRight, InpText, InpSep)
{
  StringGetPos SepPos, InpText, %InpSep%, L
  If (SepPos >= 0)
  {
    StringLeft OutLeft, InpText, %SepPos%
    RemChars := StrLen(InpText)-SepPos-1
    StringRight OutRight, InpText, %RemChars%
  }
  Else
  {
    OutLeft  := InpText
    OutRight := ""
  }
}

SplitLast(ByRef OutLeft, ByRef OutRight, InpText, InpSep)
{
  StringGetPos SepPos, InpText, %InpSep%, R
  If (SepPos >= 0)
  {
    StringLeft OutLeft, InpText, %SepPos%
    RemChars := StrLen(InpText)-SepPos-1
    StringRight OutRight, InpText, %RemChars%
  }
  Else
  {
    OutLeft  := ""
    OutRight := InpText
  }
}
