account default              
host smtp.gmail.com          
port 587                     
from "mrXyZt@gmail.com"   
tls on                       
tls_starttls on              
tls_trust_file /etc/ssl/certs/ca-certificates.crt
auth on                     
user "username1970"       
password "password123"       
logfile ~/.msmtp.log
# for encrypted passwords see
# https://wiki.archlinux.org/index.php/Msmtp#Password_management

