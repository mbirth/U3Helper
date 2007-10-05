#Include mb_TextTools.ahk

RegDeleteX(RegRoot, RegSub)
{
  RegDelete %RegRoot%, %RegSub%
  StartRDX:
  SplitLast(RegSub, RegKey, RegSub, "\")
  if (RegCount(RegRoot, RegSub) = 0 and InStr(RegSub, "\") != 0)
  {
    RegDelete %RegRoot%, %RegSub%
    Goto StartRDX
  }
  Return true
}

RegCount(RegRoot, RegSub)
{
  Ct = 0
  Loop %RegRoot%, %RegSub%, 1, 0
  {
    Ct++
  }
  Return Ct
}
