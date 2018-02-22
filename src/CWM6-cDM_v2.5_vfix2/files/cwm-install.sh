#!/system/bin/sh

LOGFILE=/data/local/tmp/cwm-install.log

ECHOL(){
  _DATETIME=`date +"%Y%m%d %H%M%S"`
  echo "${_DATETIME}: $*" >> ${LOGFILE}
  return 0
}
EXECL(){
  _DATETIME=`date +"%Y%m%d %H%M%S"`
  echo "${_DATETIME}: $*" >> ${LOGFILE}
  $* 2>> ${LOGFILE}
  _RET=$?
  echo "${_DATETIME}: RET=${_RET}" >> ${LOGFILE}
  return ${_RET}
}

if [ -e "${LOGFILE}" ]; then
  rm ${LOGFILE}
fi
touch ${LOGFILE}

if [ "`getprop init.svc.ric`" = "running" ]; then
  RICPATH=$(busybox ps | egrep '/system/bin/ric|/sbin/ric' | grep -v grep | awk '{print $4}')
  if [ "${RICPATH}" = "/system/bin/ric" ]; then
    EXECL busybox mount -o remount,rw /system;chmod 644 /system/bin/ric;mount -o remount,ro /system
  elif [ "${RICPATH}" = "/sbin/ric" ]; then
    EXECL busybox mount -o remount,rw /;chmod 644 /sbin/ric;mount -o remount,ro /
  fi
  EXECL busybox kill -9 $(busybox ps | egrep '/system/bin/ric|/sbin/ric' | grep -v grep | awk '{print $1}')
fi
EXECL busybox mount -o remount,rw /system
if [ $? -ne 0 ]; then
  exit 1
fi

CHARGEMON=/system/bin/chargemon
CHARGER=/system/bin/charger
INSTALLPKG=/data/local/tmp/install-pkg.tar.gz

# /system/btmgr
EXECL cd /system
EXECL gzip -d ${INSTALLPKG}
if [ $? -ne 0 ]; then
  exit 1
fi
EXECL tar xf ${INSTALLPKG%.*}
if [ $? -ne 0 ]; then
  exit 1
fi

# for /system/bin/charger
if [ "`dd bs=1 count=3 if=${CHARGEMON} skip=1`" = "ELF" ]; then
  EXECL cp -p ${CHARGEMON} ${CHARGEMON}.bin.org
  if [ $? -ne 0 ]; then
    exit 1
  fi
  EXECL cp -p ${CHARGEMON} ${CHARGER}
  if [ $? -ne 0 ]; then
    exit 1
  fi
elif [ -e "${CHARGEMON}.bin.org" -a "`dd bs=1 count=3 if=${CHARGEMON}.bin.org skip=1`" = "ELF" ]; then
  EXECL cp -p ${CHARGEMON}.bin.org ${CHARGER}
  if [ $? -ne 0 ]; then
    exit 1
  fi
elif [ -e "${CHARGEMON}.stock" -a "`dd bs=1 count=3 if=${CHARGEMON}.stock skip=1`" = "ELF" ]; then
  EXECL cp -p ${CHARGEMON}.stock ${CHARGER}
  if [ $? -ne 0 ]; then
    exit 1
  fi
elif [ -e "${CHARGEMON}.org" -a "`dd bs=1 count=3 if=${CHARGEMON}.org skip=1`" = "ELF" ]; then
  EXECL cp -p ${CHARGEMON}.org ${CHARGER}
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# /system/bin/chargemon
EXECL cp -p /system/btmgr/bin/chargemon ${CHARGEMON}
if [ $? -ne 0 ]; then
  exit 1
fi

# rm /system/bin/recovery.tar (if exist)
if [ -f "/system/bin/recovery.tar" ]; then
  EXECL busybox rm -f /system/bin/recovery.tar
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# add zoneinfo files (if not exist)
if [ ! -e /system/usr/share/zoneinfo/zoneinfo.dat ]; then
  EXECL chown root.root /data/local/tmp/zoneinfo.dat
  EXECL chmod 0644 /data/local/tmp/zoneinfo.dat
  EXECL cp -p /data/local/tmp/zoneinfo.dat /system/usr/share/zoneinfo/zoneinfo.dat
fi
if [ ! -e /system/usr/share/zoneinfo/zoneinfo.idx ]; then
  EXECL chown root.root /data/local/tmp/zoneinfo.idx
  EXECL chmod 0644 /data/local/tmp/zoneinfo.idx
  EXECL cp -p /data/local/tmp/zoneinfo.idx /system/usr/share/zoneinfo/zoneinfo.idx
fi

echo "SUCCESS"
exit 0
