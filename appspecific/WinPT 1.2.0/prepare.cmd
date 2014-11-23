@echo off
echo U3 device is: %U3_DEVICE_PATH% (%U3_DEVICE_VENDOR% [%U3_DEVICE_VENDOR_ID%] - %U3_DEVICE_PRODUCT%)
echo U3 serial no: %U3_DEVICE_SERIAL%
echo U3 documents: %U3_DEVICE_DOCUMENT_PATH%
echo.
if not exist "%U3_DEVICE_DOCUMENT_PATH%\GnuPG Keyrings" (
  echo Creating keyring directory ...
  mkdir "%U3_DEVICE_DOCUMENT_PATH%\GnuPG Keyrings"
  echo Copying default GnuPG settings ...
  copy "%U3_DEVICE_EXEC_PATH%\gpg.conf" "%U3_DEVICE_DOCUMENT_PATH%\GnuPG Keyrings\"
  echo Copying list of keyservers ...
  copy "%U3_DEVICE_EXEC_PATH%\keyserver.conf" "%U3_DEVICE_DOCUMENT_PATH%\GnuPG Keyrings\"
)
echo All done. Cleaning up...
del "%U3_DEVICE_EXEC_PATH%\gpg.conf"
del "%U3_DEVICE_EXEC_PATH%\keyserver.conf"
echo Exiting...
exit 0
