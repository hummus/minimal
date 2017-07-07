#!/bin/sh
depmod -ae
modprobe e1000
modprobe e1000e

# DHCP network
for DEVICE in /sys/class/net/* ; do
  echo "Found network device ${DEVICE##*/}"
  ip link set ${DEVICE##*/} up
  [ ${DEVICE##*/} != lo ] && udhcpc -b -i ${DEVICE##*/} -s /etc/05_rc.dhcp
done

nohup fio --server & 
dropbear -F
