; BEGIN: borrowed from http://www.autohotkey.com/forum/viewtopic.php?p=54838#54838
EnumProcesses( byref r_pid_list )
{
   if A_OSVersion in WIN_95,WIN_98,WIN_ME
   {
      Tooltip, This Windows version (%A_OSVersion%) doesn't support PID listing.
      return, false
   }
   
   pid_list_size := 4*1000
   VarSetCapacity( pid_list, pid_list_size )
   
   status := DllCall( "psapi.dll\EnumProcesses", "uint", &pid_list, "uint", pid_list_size, "uint*", pid_list_actual )
   if ( ErrorLevel or !status )
      return, false
   
   total := pid_list_actual//4
   
   r_pid_list= 
   address := &pid_list
   loop, %total%
   {
      r_pid_list := r_pid_list "|" ( *( address )+( *( address+1 ) << 8 )+( *( address+2 ) << 16 )+( *( address+3 ) << 24 ) )
      address += 4
   }
   
   StringTrimLeft, r_pid_list, r_pid_list, 1
   
   return, total
}

GetModuleFileNameEx( p_pid )
{
   if A_OSVersion in WIN_95,WIN_98,WIN_ME
   {
      ToolTip, This Windows version (%A_OSVersion%) doesn't support process details.
      return
   }

   h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", p_pid )
   if ( ErrorLevel or h_process = 0 )
      return
   
   name_size = 255
   VarSetCapacity( name, name_size )
   
   result := DllCall( "psapi.dll\GetModuleFileNameExA", "uint", h_process, "uint", 0, "str", name, "uint", name_size )
   
   DllCall( "CloseHandle", h_process )
   
   return, name
}
; END: borrowed from http://www.autohotkey.com/forum/viewtopic.php?p=54838#54838
