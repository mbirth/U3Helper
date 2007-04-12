U3Helper
(c)2006-2007 by Markus Birth <mbirth@webwriters.de>

Some words for the manifest.u3i:

If your app doesn't store anything inside %USERPROFILE% or such, then just call it directly
inside the <appStart> - such as:

  <appStart workingdir="%U3_APP_DATA_PATH%" cmd="%U3_HOST_EXEC_PATH%\WebMon.exe">-prefs "%U3_APP_DATA_PATH%\WebMon.ini" -pages "%U3_APP_DATA_PATH%\pages\WebPages.dat"</appStart>

BUT: If you app DOES store some stuff inside %USERPROFILE% (mostly noticeable if there appears something under
     C:\Documents and Settings\<Username>\Application Data\<somewhat>\<something>), call it as follows:

  <appStart workingdir="%U3_APP_DATA_PATH%" cmd="%U3_HOST_EXEC_PATH%\U3Helper.exe">appstart</appStart>

This way, the environment variables %USERPROFILE% and a bunch of other related will be set to point to the
data directory on the U3-stick and therefore those app will store its data there instead of on the host system.




Take a look at the U3Helperex.ini as there are all supported settings mentioned. You'll get the idea of the expected
format.

U3Helper Forum: http://vanilla.birth-online.de/3/
U3Helper English info: http://www.autohotkey.com/forum/topic11839.html
U3Helper German info: http://blog.birth-online.de/archives/164-Programme-U3-faehig-machen.html
