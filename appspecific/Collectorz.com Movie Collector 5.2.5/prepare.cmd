@echo off
setlocal
set TARGPATH=Movie Collector
echo U3 device is: %U3_DEVICE_PATH% (%U3_DEVICE_VENDOR% [%U3_DEVICE_VENDOR_ID%] - %U3_DEVICE_PRODUCT%)
echo U3 serial no: %U3_DEVICE_SERIAL%
echo U3 documents: %U3_DEVICE_DOCUMENT_PATH%
echo Personal dir: %U3_DEVICE_DOCUMENT_PATH%\%TARGPATH%
echo.
if not exist "%U3_DEVICE_DOCUMENT_PATH%\%TARGPATH%" (
  echo Creating personal directory ...
  mkdir "%U3_DEVICE_DOCUMENT_PATH%\%TARGPATH%"
  echo Copying example files ...
  xcopy "%U3_DEVICE_EXEC_PATH%\example.mvc" "%U3_DEVICE_DOCUMENT_PATH%\%TARGPATH%\" /e /c /h /k /y
  xcopy "%U3_DEVICE_EXEC_PATH%\Images" "%U3_DEVICE_DOCUMENT_PATH%\%TARGPATH%\Images" /e /c /h /k /y
)
echo All done. Cleaning up...
del "%U3_DEVICE_EXEC_PATH%\example.mvc"
rmdir /s /q "%U3_DEVICE_EXEC_PATH%\Images"
echo Exiting...
exit 0
