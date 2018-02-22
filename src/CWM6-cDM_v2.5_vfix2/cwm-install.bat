@echo off
@echo ----------------------------------------------------------------------
@echo   CWM-based Recovery v6.0.3.2
@echo     cray_Doze Mod for Xperia v1.3
@echo       with btmgr scripts v1.0
@echo   installer package version 2.5
@echo   by @cray_Doze
@echo   vfix2 by CUBE
@echo ----------------------------------------------------------------------
@echo;
@echo ----------------------------------------------------------------------
@echo   Support devices
@echo     *(japanese locked models)
@echo       - arc/acro/ray/NX/acroHD/ GX /SX/AX/VL/Z/UL/A
@echo     *(same or similar global locked models)
@echo       - arc/----/ray/S /acroS /TX/T/--/  V  /Z/ZL/ZR
@echo ----------------------------------------------------------------------
pause
@echo ----------------------------------------------------------------------
@echo   Summary
@echo     - btmgr scripts v1.0
@echo       + You can customize the key into recovery.
@echo         (/system/btmgr/etc/action.cfg)
@echo       + You can use my or other's recovery as you like.
@echo         (/system/btmgr/etc/bootrecovery.cfg and action.cfg)
@echo         (need other's recovery.tar or like to put it to /recovery/???)
@echo     - CWM-based Recovery v6.0.3.2
@echo     - [UP!] cray_Doze mod v1.3
@echo       + add power off menu
@echo       + add choose default recovery's font menu
@echo           (settings-^>choose default recovery's font)
@echo       + add choose default confirm menu
@echo           (settings-^>choose default confirm)
@echo       + [UP!] add choose default nandroid progress menu
@echo                 add bar-only mode(default)
@echo               (settings-^>choose default nandroid progress)
@echo       + add support 2011 models
@echo       + add power off menu
@echo       + return from key test with power button
@echo       + support "mount USB storage" on datamedia type device(e.g. Z)
@echo       + change from "reboot recovery" to "reboot CWM Recovery" 
@echo       + support TIMEZONE(depend on persist.sys.timezone)
@echo ----------------------------------------------------------------------
pause
@echo;
@echo ----------------------------------------------------------------------
@echo   Thanks
@echo     Koush for recovery sources
@echo     CyanogenMod and FreeXperia team for related sources and environ.
@echo     DooMLoRD (I referred to some files in his ramdisk.)
@echo     goro_tsukiyama and nao3shogun for debug
@echo     huhka_com (I referred to runme.bat in his rootkit.)
@echo ----------------------------------------------------------------------
@echo;
@echo ----------------------------------------------------------------------
@echo  [*]Requirements for PC:
@echo      (1) usb driver installed
@echo  [*]Requirements for mobile:
@echo      (1) rooted
@echo      (2) busybox installed
@echo      (3) USB debugging' enabled
@echo ----------------------------------------------------------------------
@echo;
@echo ----------------------------------------------------------------------
@echo  * Start installation.("ctrl-c" to stop process)
@echo ----------------------------------------------------------------------
pause
@echo connect device
@files\adb kill-server & if errorlevel 1 goto EXECERROR
@files\adb wait-for-device & if errorlevel 1 goto EXECERROR
@files\adb push files\cwm-install.sh /data/local/tmp/ & if errorlevel 1 goto PUSHERROR
@files\adb push files\install-pkg.tar.gz /data/local/tmp/ & if errorlevel 1 goto PUSHERROR
@files\adb push files\zoneinfo.dat /data/local/tmp/ & if errorlevel 1 goto PUSHERROR
@files\adb push files\zoneinfo.idx /data/local/tmp/ & if errorlevel 1 goto PUSHERROR
@files\adb shell chmod 755 /data/local/tmp/cwm-install.sh & if errorlevel 1 goto CHMODERROR
for /f %%i in ('files\adb shell su -c /data/local/tmp/cwm-install.sh') do set RESULT=%%i
@files\adb pull /data/local/tmp/cwm-install.log
@files\adb shell "rm /data/local/tmp/cwm-install.sh"
@files\adb shell "rm /data/local/tmp/install-pkg.tar"
@files\adb shell "rm /data/local/tmp/zoneinfo.dat"
@files\adb shell "rm /data/local/tmp/zoneinfo.idx"
if not "%RESULT%" equ "SUCCESS" goto INSTALLERROR
@echo;
@echo ----------------------------------------------------------------------
@echo CWM installation was successful.
@echo ----------------------------------------------------------------------
@echo How to enter CWM Recovery
@echo  Press any button when blue LED lights, while booting device.)
@echo ----------------------------------------------------------------------
@pause
@echo;
@echo ----------------------------------------------------------------------
@echo * Caution!
@echo ----------------------------------------------------------------------
@echo If you cannot charge with usb or cradle in the power-off state,
@echo  apply "fix charger zip" below with CWM Recovery.)
@echo;
@echo for Z      : http://www.mediafire.com/?wj9de7434h73nmq
@echo for AX/VL  : http://www.mediafire.com/?oahak7c937hbztp
@echo for GX/SX  : http://www.mediafire.com/?1sevjchhaiamofe
@echo for acroHD : http://www.mediafire.com/?g1955hvx715r57u
@echo;
@pause
@exit

:EXECERROR
@echo ----------------------------------------------------------------------
@echo An error has occurred in execute adb. Stop processing.
@pause
exit

:PUSHERROR
@echo ----------------------------------------------------------------------
@echo An error has occurred in adb push. Stop processing.
@pause
exit

:CHMODERROR
@echo ----------------------------------------------------------------------
@echo  An error has occurred in adb shell chmod. Stop processing.)
@pause
exit

:INSTALLERROR
@echo ----------------------------------------------------------------------
@echo An error has occurred in cwm-install.sh. Stop processing.
@pause
@echo ----------------------------------------------------------------------
@type cwm-install.log
@pause
exit
