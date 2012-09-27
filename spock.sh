#!/bin/bash

function check_boot_part_manual()
{
	exit 0
}

function check_boot_part()
{
	exit 0
}


dialog --backtitle "SPOCK v1.0" --title Welcome --textbox welcome.msg 10 40

#ustalenie jakie dyski i partycje beda przenoszone na VM

tmp=$(fdisk -l | grep '^/' | sed 's/\*//' | awk '{print $1"-"$2"-"$3"-"$4"-"$5"-"$6 } ')
cmd=""
for i in $tmp; do
	item=$(echo $i | awk 'BEGIN {FS="-"} {print $6 }')
	tag=$(echo $i | awk 'BEGIN {FS="-"} {print $1}')
	if ! [ $item == 'Extended' ]; then cmd="$cmd $tag ${item} 0" ; fi
done
while ! [ -f /tmp/partitions ] ;
do
	dialog --backtitle "SPOCK v1.0" --title Partitions --checklist "Chosse partitions to migrate" 10 60 10 $cmd 2> /tmp/partitions
	size=$(ls -l /tmp/partitions | awk '{print $5}')
	if [ $size -lt 5 ]; then rm /tmp/partitions; fi
done

dialog --backtitle "SPOCK v1.0" --title "MBR Grub" --yesno "Do you wish to select manualy the partition with /boot?" 5 60
yesno=$?

if [ $yesno -eq 0 ];
then
	ok=1;
	while [ $ok -eq 1 ];
	do
		while ! [ -f /tmp/grubver ] ;
		do
			dialog --backtitle "SPOCK v1.0" --title "MBR Grub" --radiolist "Chosse bootloader" 10 60 5 grub "version 1" 0 grub2 "vesion 2" 0 2> /tmp/grubver
			size=$(ls -l /tmp/grubver | awk '{print $5}')
			if [ $size -lt 3 ]; then rm /tmp/grubver; fi
		done
		cmd=""
		for i in `cat /tmp/partitions | sed 's/"//g'`; do
			item=$i
			tag=$i
			cmd="$cmd $tag $item 0"
		done

		while ! [ -f /tmp/bootpart ] ;
		do
			dialog --backtitle "SPOCK v1.0" --title "/boot location" --radiolist "Chosse partition with /boot" 10 60 5 $cmd 2> /tmp/bootpart
			size=$(ls -l /tmp/bootpart | awk '{print $5}')
			if [ $size -lt 5 ]; then rm /tmp/bootpart; fi
		done
		ok=$(check_boot_part_manual)
	done
fi

error=1

while [ $error -eq 1 ];
do
	dialog --backtitle "SPOCK v1.0" --title "Remote Server" --inputbox "Input hostname or IP of remote server" 10 50 2> /tmp/hostname

	dialog --backtitle "SPOCK v1.0" --title "Remote Server" --inputbox "Input login" 10 50 2> /tmp/login

	dialog --backtitle "SPOCK v1.0" --title "Remote Server" --inputbox "Destination dir for operations" 10 50 2> /tmp/mountpoint

	dialog --backtitle "SPOCK v1.0" --title "Remote Server" --passwordbox "Input password to remote server" 10 50 2> /tmp/password

	dialog --backtitle "SPOCK v1.0" --title "Remote Server" --msgbox "SPOCK will create RSA keys to nopassword login. After operation the old configuration will be restored" 10 50

	servername=$(strings /tmp/hostname)
	username=$(strings /tmp/login)
	mountpoint=$(strings /tmp/mountpoint)
	password=$(strings /tmp/password)

	echo $password | sshfs ${username}@${servername}: /mnt/home -o password_stdin -o CheckHostIP="no" -o uid=0 -o gid=0 -o umask=7077

	ssh-keygen -t rsa -b 4096 -f ~/.ssh/spock -N ""
	if ! [ -d /mnt/home/.ssh ]; then mkdir /mnt/home/.ssh; chmod 0700 /mnt/home/.ssh; fi
	cp ~/.ssh/spock.pub /mnt/home/.ssh/
	if ! [ -f /mnt/home/.ssh/authorized_keys ]; then touch /mnt/home/.ssh/authorized_keys ; fi
	cp /mnt/home/.ssh/authorized_keys /mnt/home/.ssh/authorized_keys_old
	cat ~/.ssh/spock.pub >> /mnt/home/.ssh/authorized_keys

	echo $password | sshfs ${username}@${servername}:${mountpoint} /mnt/remote -o password_stdin -o CheckHostIP="no" -o uid=0 -o gid=0 -o umask=7077

	error=$?

done


dialog --backtitle "SPOCK v1.0" --title "Processors" --inputbox "Number of CPUs for VM" 10 50 2> /tmp/procnum

dialog --backtitle "SPOCK v1.0" --title "Memory" --inputbox "Memory in MB for VM" 10 50 2> /tmp/memory


