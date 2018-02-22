#!/system/bin/sh

echo

# check ric
RICTYPE=0

if [ -e /sys/kernel/security/sony_ric ]; then
	/data/local/tmp/copymodulecrc /system/lib/modules/scsi_wait_scan.ko /data/local/tmp/ric_disabler_mod.ko
	insmod /data/local/tmp/ric_disabler_mod.ko
	RICTYPE=3
elif [ -e /sbin/ric ]; then
	/data/local/tmp/busybox pkill /sbin/ric
	mount -o remount,rw /
	rm /sbin/ric
	mount -o remount,ro /
	/data/local/tmp/busybox pkill /sbin/ric
	RICTYPE=2
elif [ -e /system/bin/ric ]; then
	/system/bin/stop ric
	/data/local/tmp/busybox pkill /system/bin/ric
	mount -o remount,rw /system
	rm /system/bin/ric
	/data/local/tmp/busybox pkill /system/bin/ric
	/data/local/tmp/busybox cp /data/local/tmp/saferic /system/bin/ric
	chown root.root /system/bin/ric
	chmod 0755 /system/bin/ric
	mount -o remount,ro /system
	RICTYPE=1
fi

echo "rictype=$RICTYPE"

# mount rw
mount -o remount,rw /system

# delete old su
if [ -e /system/bin/su ]; then
	rm /system/bin/su
fi
if [ -e /system/xbin/su ]; then
	rm /system/xbin/su
fi
if [ -e /system/bin/.ext/.su ]; then
	rm /system/bin/.ext/.su
fi
if [ -e /system/bin/install-recovery.sh ]; then
	rm /system/bin/install-recovery.sh
fi
if [ -e /system/etc/install-recovery.sh ]; then
	rm /system/etc/install-recovery.sh
fi
if [ -e /system/xbin/daemonsu ]; then
	rm /system/xbin/daemonsu
fi
if [ -e /system/xbin/sugote ]; then
	rm /system/xbin/sugote
fi
if [ -e /system/xbin/sugote-mksh ]; then
	rm /system/xbin/sugote-mksh
fi
if [ -e /system/app/Superuser.apk ]; then
	rm /system/app/Superuser.apk
fi
if [ -e /system/app/SuperSU.apk ]; then
	rm /system/app/SuperSU.apk
fi
if [ -e /system/etc/init.d/99SuperSUDaemon ]; then
	rm /system/etc/init.d/99SuperSUDaemon
fi
if [ -e /system/etc/.installed_su_daemon ]; then
	rm /system/etc/.installed_su_daemon
fi

# copy files
dd if=/data/local/tmp/su of=/system/xbin/su
chown root.root /system/xbin/su
chmod 06755 /system/xbin/su
ln -s /system/xbin/su /system/bin/su

dd if=/data/local/tmp/su of=/system/xbin/daemonsu
chown root.root /system/xbin/daemonsu
chmod 0755 /system/xbin/daemonsu

dd if=/data/local/tmp/Superuser.apk of=/system/app/SuperSU.apk
chown root.root /system/app/SuperSU.apk
chmod 0644 /system/app/SuperSU.apk

dd if=/data/local/tmp/busybox of=/system/xbin/busybox
chown root.shell /system/xbin/busybox
chmod 0755 /system/xbin/busybox
/system/xbin/busybox --install -s /system/xbin

# make init.d
if [ ! -e /system/etc/init.d ]; then
	/system/bin/mkdir /system/etc/init.d
fi
chown root.root /system/etc/init.d
chmod 0755 /system/etc/init.d
if [ -e /system/etc/init.qcom.post_boot.sh ]; then
	if grep "/system/xbin/busybox run-parts /system/etc/init.d" /system/etc/init.qcom.post_boot.sh > /dev/null; then
		:
	else
		echo "/system/xbin/busybox run-parts /system/etc/init.d" >> /system/etc/init.qcom.post_boot.sh
	fi
elif [ -e /system/etc/hw_config.sh ]; then
	if grep "/system/xbin/busybox run-parts /system/etc/init.d" /system/etc/hw_config.sh > /dev/null; then
		:
	else
		echo "/system/xbin/busybox run-parts /system/etc/init.d" >> /system/etc/hw_config.sh
	fi
fi

# make SuperSUDaemon
dd if=/data/local/tmp/99SuperSUDaemon of=/system/etc/init.d/99SuperSUDaemon
chown root.root /system/etc/init.d/99SuperSUDaemon
chmod 0755 /system/etc/init.d/99SuperSUDaemon

dd if=/data/local/tmp/install-recovery.sh of=/system/etc/install-recovery.sh
chown root.root /system/etc/install-recovery.sh
chmod 0755 /system/etc/install-recovery.sh
ln -s /system/etc/install-recovery.sh /system/bin/install-recovery.sh

echo 1 > /system/etc/.installed_su_daemon
chown root.root /system/etc/.installed_su_daemon
chmod 0644 /system/etc/.installed_su_daemon

# make ric-disable script
case $RICTYPE in
1)
	;;
2)
	dd if=/data/local/tmp/00stop_ric of=/system/etc/init.d/00stop_ric
	chown root.root /system/etc/init.d/00stop_ric
	chmod 0755 /system/etc/init.d/00stop_ric
	;;
3)
	dd if=/data/local/tmp/ric_disabler_mod.ko of=/system/xbin/ric_disabler_mod.ko
	chown root.root /system/xbin/ric_disabler_mod.ko
	chmod 0644 /system/xbin/ric_disabler_mod.ko

	echo "#!/system/bin/sh" > /system/etc/init.d/00stop_ric
	echo "" >> /system/etc/init.d/00stop_ric
	echo "insmod /system/xbin/ric_disabler_mod.ko" >> /system/etc/init.d/00stop_ric
	chown root.root /system/etc/init.d/00stop_ric
	chmod 0755 /system/etc/init.d/00stop_ric
	;;
esac

# mount ro
mount -o remount,ro /system
