sudo mount -t cifs //192.168.1.118/"$1"/ /mnt/"$1"/ --verbose -o username="$2",iocharset=utf8,sec=ntlm,noserverino,uid=1000,gid=1000



