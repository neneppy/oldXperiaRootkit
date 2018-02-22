@echo --- Xperia rootkit 2014/07/19 ---
@echo;
@echo waiting for device...
@adb wait-for-device
@adb push files\getroot /data/local/tmp/
@adb push files\su /data/local/tmp/
@adb push files\Superuser.apk /data/local/tmp/
@adb push files\busybox /data/local/tmp/
@adb push files\00stop_ric /data/local/tmp/
@adb push files\99SuperSUDaemon /data/local/tmp/
@adb push files\install-recovery.sh /data/local/tmp/
@adb push files\ric_disabler_mod.ko /data/local/tmp/
@adb push files\copymodulecrc /data/local/tmp/
@adb push files\saferic /data/local/tmp/
@adb push files\install_tool.sh /data/local/tmp/
@adb shell "chmod 0755 /data/local/tmp/getroot"
@adb shell "chmod 0755 /data/local/tmp/busybox"
@adb shell "chmod 0644 /data/local/tmp/ric_disabler_mod.ko"
@adb shell "chmod 0755 /data/local/tmp/copymodulecrc"
@adb shell "chmod 0755 /data/local/tmp/install_tool.sh"

@echo;
@echo getroot start.
@adb shell "/data/local/tmp/getroot /data/local/tmp/install_tool.sh"

@echo;
@echo waiting for device...
@adb wait-for-device

@echo;
@echo removing temporary files...
@adb shell "rm /data/local/tmp/getroot"
@adb shell "rm /data/local/tmp/su"
@adb shell "rm /data/local/tmp/Superuser.apk"
@adb shell "rm /data/local/tmp/busybox"
@adb shell "rm /data/local/tmp/00stop_ric"
@adb shell "rm /data/local/tmp/99SuperSUDaemon"
@adb shell "rm /data/local/tmp/install-recovery.sh"
@adb shell "rm /data/local/tmp/ric_disabler_mod.ko"
@adb shell "rm /data/local/tmp/copymodulecrc"
@adb shell "rm /data/local/tmp/saferic"
@adb shell "rm /data/local/tmp/install_tool.sh"

@echo;
@echo --- all finished ---
@pause
