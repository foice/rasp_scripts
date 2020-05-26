# IP address       HW type     Flags       HW address            Mask     Device
# 192.168.0.34     0x1         0x2         2c:f4:32:77:96:b0     *        eth0
cat /proc/net/arp | grep 0x2 > ~arp.dat
while read IP HWtype Flags MACaddr Mask IFACE
do
    # 1590394633 2c:f4:32:77:65:89 192.168.0.75 ESP-776589 *
    hostname=`cat /var/lib/dnsmasq/dnsmasq.leases | grep $MACaddr | cut -f4 -d" "`
    if [ "$hostname" == "*" ] || [ "$hostname" == "" ]; then
    	hostname=`cat known_macs | grep $MACaddr | cut -f4 -d" "`
    fi  
    echo -e "$IP \t $MACaddr \t $hostname "  
done < ~arp.dat

rm ~arp.dat
