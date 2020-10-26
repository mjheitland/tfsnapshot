#!/bin/bash
#yum install httpd -y
#echo "Subnet: ${subnets}" >> /var/www/html/index.html
#service httpd start
#chkconfig httpd on

# mount EBS volume as /data
lsblk --output NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT,LABEL # list all attached volumes
file -s /dev/xvdf # to check if there is already a file system installed
yum install -y xfsprogs # install fs tools
mkfs -t xfs /dev/xvdf # to create a file system
file -s /dev/xvdf # to check if there is already a file system installed
mkdir /data # create mount folder /data
mount /dev/xvdf /data # mount EBS volume
cat /proc/mounts # to list mounted devices
cd /data
df -H . # check disk size
echo 'hello world!' > hello_world.txt

# change /etc/fstab to allow auto-mount of EBS volume
cp /etc/fstab /etc/fstab.orig # back up original auto-mount file “fstab”
# Next three lines to the same as: vim /etc/fstab # add the following line: UUID=<UUID from last command>  /data  xfs  defaults,nofail  0  2
vol_block_id=`blkid|grep -oP '/dev/xvdf:.*UUID="\K[0-9a-f-]+'`
sed -i '$ a UUID=vol_block_id  /data  xfs  defaults,nofail  0  2' /etc/fstab
sed -i 's|vol_block_id|'$vol_block_id'|g' /etc/fstab
