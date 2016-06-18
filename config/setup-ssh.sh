#!/bin/bash
trap "" 0 1 2 5 15

for i in `cat /proc/cmdline `
do
    echo $i | grep -q '=' && eval "export $i";
done

mkdir -p /mnt/{hdr,hdp,itool}
umount /mnt/itool > /dev/null 2>&1
rm -Rf /tmp/* > /dev/null 2>&1

WARNING='Anmeldung am System war nicht moeglich!\n\n
Dies koennte mehrere Gruende haben.\n\n
 - Falscher Benutzername\n
 - Falsches Passwort\n
 - Fehlerhafte Konfiguration des Server\n
 - Keine Verbindung zum Server\n\n\n
Moechten Sie es erneut versuchen?'

## Check for some boot parameter
if [ -z "${ITOOL}" ]
then
        export ITOOL="partclone"
fi
## Check for some boot parameter
if [ -z "${STARTCMD}" ]
then
        export STARTCMD="clone"
fi
## Check for some boot parameter
if [ -z "${SERVER}" ]
then
        export SERVER="install"
fi

## if no nic was defined set it to eth0
if [ -z "${NIC}" ]
then
        for i in $( hwinfo --netcard | grep "Device File:"  | gawk -F": " '{ print $2 }' )
        do
                /usr/lib/wicked/bin/wickedd-dhcp4 --test --test-output /tmp/dhcp.ini $i
                if [ -e /tmp/dhcp.ini ]
                then
                        export NIC=$i
                        break
                fi
        done
else
        /usr/lib/wicked/bin/wickedd-dhcp4 --test --test-output /tmp/dhcp.ini $NIC
fi

. /tmp/dhcp.ini
IPADDR=${IPADDR/\/*/}

if [ -z "${HOSTNAME}" ]
then
        export HOSTNAME=`ldapsearch -x -h ldap -LLL aRecord=$IPADDR relativeDomainName | grep -i relativeDomainName: | sed 's/relativeDomainName: //i'`
        echo "HOSTNAME='${HOSTNAME}'" >> /tmp/dhcp.ini
fi

if [ -z "${DHCPCHADDR}" ]
then
        DHCPCHADDR=$( cat /sys/class/net/${NIC}/address )
        echo "DHCPCHADDR='${DHCPCHADDR}'" >> /tmp/dhcp.ini
fi

if [ -z "${SLEEP}" ]
then
        export SLEEP=1
fi


export HOSTNAME=${HOSTNAME%%.*}

if [ "$MODUS" = "AUTO" ]
then
    echo "username=register" >  /tmp/credentials
    echo "password=register" >> /tmp/credentials 
    echo "register" > /tmp/username
    echo "register" > /tmp/userpassword
    chmod 400 /tmp/userpassword
    chmod 400 /tmp/credentials
    echo "mount -t cifs -o username="register",password="register",netbiosname=${HOSTNAME} //$SERVER/itool /mnt/itool" > /tmp/login
    mount -t cifs -o credentials=/tmp/credentials //install/itool /mnt/itool
    sleep $SLEEP
    if [ $? -eq 0 ] && [ -d /mnt/itool/config/ ] && [ -d /mnt/itool/images/ ]
    then
        bash ${CDEBUG} /root/${STARTCMD}.sh
        exit 0
    else
    	dialog  --backtitle "${STARTCMD}" --title "Anmeldung" --yesno "$WARNING" 15 60
    	if [ $? -ne 0 ]
    	then
    	    clear
    	    exit 0
	else
	    export MODUS=""
	    /root/login
	    exit 0
    	fi
    fi
else
    while test -e /tmp
    do
        dialog --backtitle "${STARTCMD}" --title "Anmeldung" --cancel-label "Beenden" --inputbox "Bitte geben Sie Ihren Benutzernamen ein:\n" 10 60 2> /tmp/username
        
        if [ $? -eq 1 ]
        then
		clear
		exit 0
        else
    	USERNAME=$(cat /tmp/username)
	USERNAME=$(echo $USERNAME | tr '[:upper:]' '[:lower:]' 2>/dev/null)
        
    	if [ ! "$USERNAME" ]
    	then
    		dialog --backtitle "${STARTCMD}" --title "Anmeldung" --msgbox "Der Benutzername $USERNAME ist ungueltig!" 15 60
    	elif [ "$USERNAME" = "root" -o "$USERNAME" = "administrator" ]
    	then
    		dialog --backtitle "${STARTCMD}" --title "Anmeldung" --msgbox "Die Anmeldung an cloneTool als $USERNAME ist nicht möglich!" 15 60
    	else
    	    dialog --backtitle "${STARTCMD}" --title "Anmeldung" --no-cancel \
		   --insecure --passwordbox "Bitte geben Sie das Passwort fuer $USERNAME ein:\n" 10 60 2> /tmp/userpassword

	    echo -n "username=" > /tmp/credentials; cat /tmp/username >> /tmp/credentials;
	    echo >> /tmp/credentials;
	    echo -n "password=" >>/tmp/credentials; cat /tmp/userpassword >> /tmp/credentials;
	    chmod 400 /tmp/credentials
	    chmod 400 /tmp/userpassword
    	    
    	    mount -t cifs -o credentials=/tmp/credentials //install/itool /mnt/itool
    	    if [ $? -eq 0 ] && [ -d /mnt/itool/config/ ] && [ -d /mnt/itool/images/ ]
    	    then
    		/bin/bash ${CDEBUG} /root/${STARTCMD}.sh
    		exit 0
    	    else
    		umount /mnt/itool
    		sleep $SLEEP
    		dialog --backtitle "${STARTCMD}" --title "Anmeldung" --yesno "$WARNING" 15 60
    	    
    		if [ $? -ne 0 ]
    		then
			clear
			exit 0	
    		fi
    	    fi
    	fi
        fi
    done
fi

exit
###############################################################################
# Script:       clone.sh
# Copyright (c) 2010 Peter Varkoly, Fuerth, Germany.
# All rights reserved.
#
# Authos:               Peter Varkoly
#
# Description:          Cloning tool for cloning more partitions
#
                                IVERSION="3.5"

                                IBUILD="09.10.2015"
#
###############################################################################

ABOUT="OpenSchoolServer-CloneTool\n\n
Ein Werkzeug zum sichern und wiederherstellen von Computern.\n\n
Version: ${IVERSION}\n
Autor  : Peter Varkoly\n
Datum  : ${IBUILD}\n

";

milestone()
{
	if [ -z "$CDEBUG" ]; then
		return
	fi
	echo -n "Milestone $1";
	read
}

backup_image()
{
	dialog --colors --backtitle  "OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}" \
		--title "\Zb\Z1Partition: $DESC" --nocancel \
	        --menu  "Backup des alten Images." 10 50 4 "Yes" "Vorhandenes Image speichern" "No" "Vorhandenes Image ueberschreiben" 2> /tmp/itool.input
	if [ $? -ne 0 ]; then
		return
	fi
	BACKUP=$(cat /tmp/itool.input)
	if [ $BACKUP = "Yes" ]; then
		backupname="$(ls --full-time /mnt/itool/images/$HW/$PARTITION.img | gawk '{print $6"-"$7}' | sed s/\.000000000// )-$PARTITION.img"
		mv /mnt/itool/images/$HW/$PARTITION.img /mnt/itool/images/$HW/$backupname
	        dialog --colors --backtitle  "OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}" \
			--title "\Zb\Z1Partition: $DESC" --nocancel \
			--msgbox "Das vorhande Abbild wurde unter folgendem Pfad gespeichert:\n/mnt/itool/images/$HW/$backupname" 6 70
	fi
	milestone "End backup_image"
}
#########################
# The image save cmd
# saveimage /dev/$PARTITON /mnt/itool [ partclone|partimage|dd|dd_rescue ] [ cleanup ]
########################
saveimage ()
{
	local TOOL=$ITOOL
	#Clean up the partition if neccessary
        PART=${1##/dev/}
        if [ "${CLEANUP}_${PART}" = "1" ]; then
            echo "Clean Up $PART"
            mkdir -p /mnt/$PART
            mount /dev/$PART /mnt/$PART
            cont=$( df | gawk "/$PART / { print \$4-10 }" )
            count=$(( count/64 ))
            dd if=/dev/zero of=/mnt/$PART/null bs=65536 count=$count
            rm /mnt/$PART/null
            umount /mnt/$PART
        fi
	test -e $2 && rm -f $2
	if [ "$3" ]; then
		TOOL=$3
	fi
        case $TOOL in
                partclone)
			FSTYPE=$( grep $1 /tmp/prts.fs | gawk -F : '{ print $2 }' )
			partclone.$FSTYPE -c -s $1 -O $2
		;;
                partimage)
                        partimage -z1 -f3 -V0 -o -d --batch save $1 $2
                ;;
                dd)
			echo "#################################################"
			echo "#    Das erstellen des Images wurde gestartet.  #"
			echo "# Das kann sehr viel Zeit in Anschpruch nehmen. #"
			echo "#################################################"
                        dd if=$1 bs=65536 | gzip > $2
			sync
                ;;
                dd_rescue)
			echo "#################################################"
			echo "#    Das erstellen des Images wurde gestartet.  #"
			echo "# Das kann sehr viel Zeit in Anschpruch nehmen. #"
			echo "#################################################"
                        dd_rescue -y 0 -f -a $1 /dev/stdout | gzip > $2
			sync
                ;;
        esac
	echo $TOOL > $2.tool
	milestone "End saveimge $1,$2,$3,$TOOL"
}

#########################
# The image restore cmd
# restore /dev/$PARTITON /mnt/itool [ partclone|partimage|dd|dd_rescue ] 
########################
restore ()
{
	local TOOL=$ITOOL
	if [ "$3" ]; then
		TOOL=$3
	elif [ -e $2.tool ]; then
		TOOL=$( cat $2.tool )
	fi
        case $TOOL in
                partclone)
			if [ "$MULTICAST" ]; then
				udp-receiver --nokbd 2> /dev/null | partclone.restore -O $1
			else
				partclone.restore -s $2 -O $1
			fi
		;;
                partimage)
			if [ "$MULTICAST" ]; then
				udp-receiver --nokbd 2> /dev/null | gunzip | partimage -f3 --batch restore $1 stdin
			else
				partimage -f3 --batch restore $1 $2
			fi
                ;;
                dd)
			if [ "$MULTICAST" ]; then
                        	udp-receiver --nokbd 2> /dev/null | gunzip | dd of=$1 bs=65536
			else
				echo "#################################################"
				echo "# Das Zurückspielen des Images wurde gestartet. #"
				echo "# Das kann sehr viel Zeit in Anschpruch nehmen. #"
				echo "# Bitte warten bis das Hauptmenü wieder kommt!  #"
				echo "#################################################"
                        	cat $2 | gunzip | dd of=$1 bs=65536
			fi
                ;;
                dd_rescue)
			if [ "$MULTICAST" ]; then
				udp-receiver --nokbd 2> /dev/null | gunzip | /bin/dd_rescue /dev/stdin $1
			else
				cat $2 | gunzip | dd_rescue /dev/stdin $1
			fi
                ;;
        esac
	milestone "End restore $1,$2,$3,$TOOL"
}

#########################
# Some helper commands
#########################
cls ()
{
    echo -en "\033c"
}

restart()
{
	umount /mnt/itool
	sleep 2
	exit 0
}

################################
# helpme  <What>
################################
helpme ()
{
        case $1 in
                Restore)
                        HELP="Alle Systemimage und die Daten-Partitionen werden wiederhergestellt bzw. neu formatiert.\n"
                ;;
                Partition)
                        HELP="Ausgewaehlte Systemimage und Daten-Partitionen werden wiederhergestellt bzw. neu formatiert.\n"
                ;;
                Clone)
                        HELP="Die Partitionierung und ausgewaehlte Partitionen des Clients werden auf den Server gespeichert.\n"
                ;;
                Manual)
                        HELP="Partimage wird gestartet und Sie koennen manuell beliebige Partitionen archivieren.\n"
                        HELP="${HELP}Den, fuer die Speicherung von Images, vorgesehenen Bereich auf dem Server findent Sie unter /mnt/itool/images/manual."
                ;;
                Partimage)
                        HELP="Partimage wird gestartet und Sie koennen manuell beliebige Partitionen archivieren.\n"
                        HELP="${HELP}Den, fuer die Speicherung von Images, vorgesehenen Bereich auf dem Server findent Sie unter /mnt/itool/images/manual."
                ;;
                *)
                        HELP="No help for this section";
                ;;
        esac
        dialog --colors --backtitle "CloneTool - ${IVERSION} ${HWDESC}" --title "\Zb\Z1Help for $1" --msgbox "${HELP}" 10 70
}

#####################################
# manual backup restore of partitions
#####################################
man_part()
{
   [ -e /tmp/disklist ]   && rm -f /tmp/disklist
   [ -e /tmp/partitions ] && rm -f /tmp/partitions
   for i in $HDs
   do
      parted -m -s /dev/$i print >> /tmp/disklist
      echo '/^[0-9]/ { printf("\"%s%i\" \"%s\t%s\t%s\" ","'$i'",$1,$4,$7,$6) }' > /tmp/partitions.awk
      gawk -F : -f /tmp/partitions.awk /tmp/disklist >> /tmp/partitions
   done
   echo -n 'dialog --colors --backtitle "CloneTool - '${IVERSION}'" --title "Manuelles Backup/Restore einer Partition" --menu  "Zur Verfuegung stehende Partitionen:" 20 50 8 ' > /tmp/command
   cat /tmp/partitions >> /tmp/command
   echo ' 2> /tmp/itool.input' >> /tmp/command
   . /tmp/command
   if [ $? -ne 0 ]; then
        return
   fi
   PARTITION=$(cat /tmp/itool.input)
   for HD in $HDs 
   do
   	if [  grep $HD /tmp/itool.input ]; then
		break;
	fi
   done

   dialog --colors --backtitle "CloneTool - ${IVERSION}" --title "\Zb\Z1Manuelles Backup/Restore der Partition $PARTITION" \
          --menu "Bitte waehlen Sie den gewuenschten modus" 20 50 4 "Backup" "Partition speichern" "Restore" "Partition wiederherstellen" 2> /tmp/itool.input
   if [ $? -ne 0 ]; then
        return
   fi
   MODE=$(cat /tmp/itool.input)

   if [ $MODE = "Backup" ]; then
        dialog --colors --backtitle "CloneTool - ${IVERSION}" --title "\Zb\Z1Manuelles Backup der Partition $PARTITION" \
               --inputbox "Bitte geben Sie einen Namen fuer das Image ein:\nDer Name darf nur folgende Zeichen erhalten a-Z1-9_." 10 60 2> /tmp/itool.input
        if [ $? -ne 0 ]; then
                return
        fi
        NAME=$( cat /tmp/itool.input | sed 's/[^a-zA-Z1-9_]//' )
        # make it sure the directory do exists
        mkdir -p /mnt/itool/images/manual/
	#Ask for backup mode
	dialog --colors --backtitle "CloneTool - ${IVERSION}" --title "\Zb\Z1Manuelles Backup der Partition $PARTITION nach $NAME" \
		--nocancel --radiolist "Zu verwendende Imaging Tool waehlen!" 10 80 4 \
		partclone "Partclone: für fast alle Filesysteme" off \
		partimage "Partimage: für ext2 ext3 und ntfs" off \
		dd_rescue "Auch für fehlerhaften Partitionen geeignet" off \
		dd	  "dd"        off \
		2> /tmp/itool.input
	TOOL=$(cat /tmp/itool.input)
	#Ask for mbr
	dialog --colors --backtitle "CloneTool - ${IVERSION}" --title "\Zb\Z1Manuelles Backup der Partition $PARTITION nach $NAME" \
		--nocancel --radiolist "Partitionierung speichern?" 10 80 4 \
		yes "Ja" on \
		no  "Nein" off \
		2> /tmp/itool.input
	MBR=$(cat /tmp/itool.input)
	if [ $MBR = "yes" ]; then
		dd of=/mnt/itool/images/manual/$NAME.parting if=/dev/$HD count=2048 bs=512 > /dev/null 2>&1
	fi
        saveimage $PARTITION  /mnt/itool/images/manual/$NAME.img $TOOL
        chmod 775 /mnt/itool/images/manual/$NAME.img
        sleep $SLEEP
   else
        rm /tmp/manual
        touch /tmp/manual
        for i in /mnt/itool/images/manual/*img
        do
            n=`basename $i .img`
            test $n = '*img' && break
            echo -n "\"$n\" " >> /tmp/manual
            ls -lh --time-style=long-iso  $i | gawk 'NF==8 { printf("\"%s %s %s\" ",$6,$7,$5) }' >> /tmp/manual
        done

        SIZE=$(ls -l /tmp/manual | gawk '{ print $5 }')
        if [ $SIZE -eq 0 ]; then
            dialog --colors --backtitle "CloneTool - ${IVERSION}" --title "\Zb\Z1Warnung" --msgbox "Es sind keine manuell erstellten Images auf dem Server vorhanden!" 10 70
            return
        fi
        echo -n 'dialog --colors --backtitle "CloneTool - '${IVERSION}'" --title "Manuelles Backup/Restore einer Partition" --menu  "Zur Verfuegung stehende Images:" 20 70 8 ' > /tmp/command
        cat /tmp/manual >> /tmp/command
        echo ' 2> /tmp/itool.input' >> /tmp/command
        . /tmp/command
        if [ $? -ne 0 ]; then
                return
        fi
        NAME=$(cat /tmp/itool.input)
	if [ -e /mnt/itool/images/manual/$NAME.parting ]; then
		#Ask for mbr
		dialog --colors --backtitle "CloneTool - ${IVERSION}" --title "\Zb\Z1Manuelles Backup der Partition $PARTITION nach $NAME" \
			--nocancel --radiolist "Partitionierung wiederherstellen?" 10 80 4 \
			yes "Ja" on \
			no  "Nein" off \
			2> /tmp/itool.input
		MBR=$(cat /tmp/itool.input)
		if [ $MBR = "yes" ]; then
			dd if=/mnt/itool/images/manual/$NAME.parting of=/dev/$HD count=2048 bs=512 > /dev/null 2>&1
		fi
	fi 
        dialog --colors --backtitle "CloneTool - ${IVERSION}" --title "\Zb\Z1Manuelles Backup einer Partition" \
               --infobox "Partimage wird gestartet. Bitte warten!" 10 60
	restore $PARTITION /mnt/itool/images/manual/$NAME.img
   fi
}

select_partitions()
{
    # This funciton get the list of the avaiable partitions and starts an
    # checklist dialog to select the partitions to clone or to restore.
    # This will be saved into the file /tmp/partitions
    [ -e /tmp/disklist ]   && rm -f /tmp/disklist
    [ -e /tmp/parts  ]     && rm -f /tmp/parts
    [ -e /tmp/partitions ] && rm -f /tmp/partitions
    for i in $HDs
    do
       parted -m -s /dev/$i print > /tmp/disklist
       sed -i /type=05/d    /tmp/disklist
       sed -i /linux-swap/d /tmp/disklist
       echo '/^[0-9]/ { printf("%s%i:%s\t%s\t%s\n","'$i'",$1,$4,$7,$6) }' > /tmp/partitions.awk
       gawk -F : -f /tmp/partitions.awk /tmp/disklist >> /tmp/parts
    done 
    IFS=$'\n'
    for i in `cat /tmp/parts`
    do
        part=$( echo "$i" | gawk -F : '{ print $1 }' )
	desc=$( get_ldap $part DESC )
	if [ "$desc" ]; then
	    echo -n "$part \"$desc\" on " >> /tmp/partitions
	else
    	    echo $i | gawk -F : '{ printf("%s \"%s\" on ",$1,$2) }' >> /tmp/partitions
	fi
    done
    unset IFS
    echo -n "dialog --colors --backtitle \"OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}\" --title \"Zur Verfuegung stehende Partitionen\" --checklist \"Waehlen Sie die zu bearbeitende Partitionen\" 18 60 8 " > /tmp/command
    cat /tmp/partitions >> /tmp/command
    echo ' 2> /tmp/partitions' >> /tmp/command
    . /tmp/command
    if [ $? -ne 0 ]; then
         return 1
    fi
    sed -i 's#"##g'     /tmp/partitions
    sleep $SLEEP
    milestone "End select_partitions"
    return 0
}

save_hw_info()
{
    if [ ! -e /mnt/itool/hwinfo/$HOSTNAME ]; then 
	mkdir -p /mnt/itool/hwinfo/$HOSTNAME
	let i=100
        hw_items="bios cdrom chipcard cpu disk gfxcard keyboard memory monitor mouse netcard printer sound storage-ctrl"
        for hwitem in $hw_items
        do
	    echo $(($i/14)) | dialog --colors --sleep 1 --backtitle "OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}" --title "\Zb\Z1Status" --gauge "Hardwarekonfiguration wird gespeichert: $hwitem"  10 60
            hwinfo --$hwitem > /mnt/itool/hwinfo/$HOSTNAME/$hwitem
	    i=$((i+100))
        done
    fi
}

# Get oss sysconfig value
get_sysconfig()
{
   ldapsearch -x -LLL configurationKey=$1 | grep 'configurationValue: ' | sed 's/configurationValue: //'
}

# Get the necessary configuration values from ldap
# get_ldap Partition Variable
get_ldap()
{
    RES=$( ldapsearch -x -o ldif-wrap=no -LLL -b $HOSTDN -s base "configurationValue=PART_$1_$2*" | grep -i "configurationValue: PART_$1_$2=" | sed "s/configurationValue://" )
    if [ -z "$RES" ]; then
        RES=$( ldapsearch -x -o ldif-wrap=no -LLL -b $HWDN -s base "configurationValue=PART_$1_$2*" | grep -i "configurationValue: PART_$1_$2=" | sed "s/configurationValue://" )
    fi
    if [ "$RES" = "${RES/: /}" ]; then
        echo "${RES/ PART_$1_$2=/}"
        return
    fi
    echo "${RES/: /}" | base64 -d | sed "s/PART_$1_$2=//"
}

# Add the necessary configuration values to ldap
# add_ldap Partition Variable "Value"
add_ldap()
{
    echo "dn: $HWDN" > /tmp/ldap_modify
    IFS=$'\n'
    OLD=$( get_ldap $1 $2 )
    for OLD in $( get_ldap $1 $2 )
    do 
        echo "delete: configurationValue"          >> /tmp/ldap_modify
        echo "configurationValue: PART_$1_$2=$OLD" >> /tmp/ldap_modify
        echo "-" >> /tmp/ldap_modify
    done
    if [ "$3" ]; then
	echo "add: configurationValue" 		>> /tmp/ldap_modify
	echo "configurationValue: PART_$1_$2=$3" 	>> /tmp/ldap_modify
    fi

    ldapmodify -x -D $BINDDN -y /tmp/userpassword -f /tmp/ldap_modify
    unset IFS
}

get_info()
{
    # Get the description of the partitions
    echo -n "dialog --colors --backtitle \"OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}\" --title \"Beschreibung der Partitionen\" " >  /tmp/getdescriptions
    echo -n "--form \"Geben Sie eine kurze Beschreibung fuer die Partitionen\" 20 60 10 " 			>> /tmp/getdescriptions 
    let j=1
    for i in `cat /tmp/partitions`
    do
        desc=$( get_ldap $i DESC )
        if [ "$desc" ]; then
            echo -n "$i $j 1 \"$desc\" $j 10 40 40 " >> /tmp/getdescriptions
        else
	    echo -n "$j:" > /tmp/myparts
    	    grep "${i}:" /tmp/parts >> /tmp/myparts
    	    gawk -F : '{ printf("\"%s\" %i 1 \"%s\" %i 10 40 40 ",$2,$1,$3,$1) }' /tmp/myparts   >> /tmp/getdescriptions
	fi
	j=$((j+1))
    done
    echo -n " 2> /tmp/descriptions" >> /tmp/getdescriptions
    . /tmp/getdescriptions
    if [ $? -ne 0 ]; then
         return 1
    fi

    sleep $SLEEP

    let i=1
    for PARTITION in `cat /tmp/partitions`
    do
        DESC=`gawk "NR==$i { print }" /tmp/descriptions`
	add_ldap $PARTITION DESC "$DESC"
	OS=$( get_ldap $PARTITION OS )
	WinBoot="off"; Win10="off"; Win7="off"; Win8="off"; Linux="off"; Data="off";
	case $OS in
	    WinBoot) WinBoot="on";;
	    Win10) Win10="on";;
	    Win7)  Win7="on";;
	    Win8)  Win8="on";;
	    Linux) Linux="on";;
	    Data) Data="on";;
	esac    

        dialog --colors --backtitle "OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}" \
		--title "\Zb\Z1Partition: $DESC" --nocancel \
		--radiolist "Waehlen Sie das Betriebsystem:" 18 60 8 \
		Win10    "Windows 10"           $Win10 \
		Win7     "Windows 7"            $Win7 \
		WinBoot  "Windows Bootpartition" $WinBoot \
		Win8     "Windows 8"            $Win8 \
		Linux    "Linux"                $Linux \
		Data     "Partition fuer Daten" $Data 2> /tmp/out
	OS=`cat /tmp/out`
	add_ldap $PARTITION OS $OS
        sleep $SLEEP
	
	case $OS in
	    WinBoot)
	        add_ldap $PARTITION JOIN "no"
		if [ -e /mnt/itool/images/$HW/$PARTITION.img ]; then
			backup_image /mnt/itool/images/$HW/$PARTITION.img
		fi
	    ;;
	    Win*)
		JOIN=$( get_ldap $PARTITION JOIN )
		Simple="off"; Domain="off"; Workgroup="off"; No="off";
		case $JOIN in
		    Simple)     Simple="on";;
		    Domain)     Domain="on";;
		    Workgroup)  Workgroup="on";;
		    no)         No="on";;
		esac
		dialog --colors --backtitle "OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}" \
			--title "\Zb\Z1Partition: $DESC" --nocancel \
			--radiolist "Windows Anmeldung:" 11 60 4 \
			Simple    "Windows Domainenmitglied ohne Sysprep"  $Simple \
			Domain    "Windows Domainenmitglied"               $Domain \
			no	  "Keine Aufnahme"                         $No 2> /tmp/out
	        JOIN=`cat /tmp/out`
	        add_ldap $PARTITION JOIN $JOIN
		sleep $SLEEP

#		if [ "$JOIN" = "Domain" ]; then 
#			ProductID=$( get_ldap $PARTITION ProductID )
#			dialog --colors --backtitle "OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}" \
#				--title "\Zb\Z1Partition: $DESC" --nocancel \
#				--inputbox "Geben Sie die Product-ID (Windows-Seriennummer) ein" 10 60 "$ProductID" 2> /tmp/out
#			ProductID=`cat /tmp/out`
#			add_ldap $PARTITION ProductID $ProductID
#			sleep $SLEEP
#		fi
		if [ -e /mnt/itool/images/$HW/$PARTITION.img ]; then
			backup_image /mnt/itool/images/$HW/$PARTITION.img
		fi
	    ;;
	    Data)
		FORMAT=$( get_ldap $PARTITION FORMAT )
		msdos="off"; vfat="off"; ntfs="off"; ext2="off"; ext3="off"; swap="off"; clone="off"; no="off"; 
		case $FORMAT in
		    msdos)	msdos="on";;
		    vfat)	vfat="on";;
		    ntfs)	ntfs="on";;
		    ext2)	ext2="on";;
		    ext3)	ext3="on";;
		    swap)	swap="on";;
		    clone)	clone="on";;
		    no)         no="on";;
		esac
	        dialog --colors --backtitle "OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}" \
			--title "\Zb\Z1Partition: $DESC" --nocancel \
	        	--radiolist "Formatierung der Datenpartition" 16 60 9 \
			msdos "Formatieren: Windows FAT 16"    $msdos \
			vfat  "Formatieren: Windows FAT 32"    $vfat  \
			ntfs  "Formatieren: Windows NTFS"      $ntfs \
			ext2  "Formatieren: Linux ext2"        $ext2 \
			ext3  "Formatieren: Linux ext3"        $ext3 \
			swap  "Formatieren: Linux swap"        $swap \
			clone "1 zu 1 Kopie"                   $clone \
			no    "Nicht formatieren" $no 2> /tmp/out
	        FORMAT=`cat /tmp/out`
	        add_ldap $PARTITION FORMAT $FORMAT
		if [ FORMAT = "clone" -a  -e /mnt/itool/images/$HW/$PARTITION.img ]; then
			backup_image /mnt/itool/images/$HW/$PARTITION.img
		fi
	        sleep $SLEEP
	    ;;
	esac
	#Which tool we want to use
	partclone="off"; partimage="off"; dd="off"; dd_rescue="off";
	TOOL=$( get_ldap $PARTITION ITOOL)
	case $TOOL in
	    partclone)	partclone="on";;
	    partimage)	partimage="on";;
	    dd)		dd="on";;
	    dd_rescue)	dd_rescue="on";;
	    *)
		partclone="on";;
	esac
        dialog --colors --backtitle "OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}" \
                --title "\Zb\Z1Partition: $DESC" --nocancel \
                --radiolist "Waehlen Sie das Imagingtool fuer die Partition:" 18 60 8 \
                partclone "Partclone"         $partclone \
                partimage "Partimage"         $partimage \
                dd    	  "dd 1 zu 1 Kopie"   $dd \
                dd_rescue "dd_rescue"         $dd_rescue  2> /tmp/out
	TOOL=`cat /tmp/out`
	add_ldap $PARTITION ITOOL $TOOL
        cp /tmp/out /mnt/itool/images/$HW/$PARTITION.tool
        sleep $SLEEP

	i=$((i+1))
    done

    return 0

}

clone()
{    
    #Save the master boot record and the partition settings of the drivers
    mkdir -p /mnt/itool/images/$HW/$PARTITION-Unattended/

    if [ ! -d /mnt/itool/images/$HW/$PARTITION-Unattended/ ]
    then
        dialog --colors --backtitle "CloneTool - ${IVERSION} ${HWDESC}" --title "\Zb\Z1Error" --msgbox "Der angemeldete Benutzer hat keine Rechte in /srv/itool/images." 10 70
	return
    fi

    for HD in $HDs 
    do
        dd of=/mnt/itool/images/$HW/$HD.mbr if=/dev/$HD count=2048 bs=512 > /dev/null 2>&1
	PTTYPE=$(  parted -m -s /dev/$HD print | gawk -F : 'NR==2 { print  $6 }' )
	case $PTTYPE in
	    gpt)
	      parted -m -s /dev/$HD unit s print > /mnt/itool/images/$HW/$HD.parted
	      ;;
	    *)
	      sfdisk -d /dev/$HD > /mnt/itool/images/$HW/$HD.sfdisk
	      ;;
	esac    
    done

    #Now we save the selected partitions
    for PARTITION in `cat /tmp/partitions`
    do
	OS=$( get_ldap $PARTITION OS )
	JOIN=$( get_ldap $PARTITION JOIN)
	if [ "$OS" = "Data" ]; then
	    FORMAT=$( get_ldap $PARTITION FORMAT)
	    if [ $FORMAT = 'clone' ]; then
	        CTOOL=$( get_ldap $PARTITION ITOOL)
            	saveimage /dev/$PARTITION /mnt/itool/images/$HW/$PARTITION.img $CTOOL
	    fi
	else
	    if [ "${OS:0:3}" = "Win" -a "$JOIN" != "no" ]; then
	    	mkdir /mnt/$PARTITION
		mount /dev/$PARTITION /mnt/$PARTITION
		if [ -e /mnt/$PARTITION/script/ ]
		then
			rm -r /mnt/$PARTITION/script/
		fi
		mkdir /mnt/$PARTITION/script/
#		cp "/mnt/itool/config/${OS}SimpleJoin.bat" /mnt/$PARTITION/script/domainjoin.bat
#		sed -i s/OLDNAME/${HOSTNAME}/ /mnt/$PARTITION/script/domainjoin.bat
		cp /mnt/itool/config/domainjoin.bat /mnt/$PARTITION/script/domainjoin.bat
		cp /mnt/itool/config/domainjoin.ps1 /mnt/$PARTITION/script/domainjoin.ps1
		sed -i s/HOSTNAME/${HOSTNAME}/      /mnt/$PARTITION/script/domainjoin.ps1
		sed -i s/WORKGROUP/${WORKGROUP}/    /mnt/$PARTITION/script/domainjoin.ps1
		umount /mnt/$PARTITION
	    fi
	    CTOOL=$( get_ldap $PARTITION ITOOL)
            saveimage /dev/$PARTITION /mnt/itool/images/$HW/$PARTITION.img $CTOOL
	    chmod 775 /mnt/itool/images/$HW/$PARTITION.img
	fi
	sleep $SLEEP
        milestone "End clone $PARTITION"
	make_autoconfig
	sleep $SLEEP
    done
}

# Functions for restore
## Get the list of the partitions

get_cloned_partitions()
{
    ldapsearch -x -b $HWDN -s base | grep 'configurationValue: PART_' | sed 's/configurationValue: PART_//' | grep '_DESC=' | sed 's/_DESC=.*//' > /tmp/partitions
}

mbr()
{
    for HD in $HDs 
    do
        dd if=/mnt/itool/images/$HW/$HD.mbr of=/dev/$HD count=2048 bs=512 > /dev/null 2>&1
    done
}

initialize_disks()
{
    for HD in $HDs 
    do
        echo "dd if=/mnt/itool/images/$HW/$HD.mbr of=/dev/$HD count=2048 bs=512"
        dd if=/mnt/itool/images/$HW/$HD.mbr of=/dev/$HD count=2048 bs=512
	sleep 5
	if [ -e /mnt/itool/images/$HW/$HD.sfdisk ]
	then
		echo "sfdisk --force /dev/$HD < /mnt/itool/images/$HW/$HD.sfdisk"
		sfdisk --force /dev/$HD < /mnt/itool/images/$HW/$HD.sfdisk
	fi
    done
    #Activate swap partitions
    for i in $( fdisk -l | grep -i 'Linux swap' | gawk '{ print $1}' )
    do
        mkswap $i
    done
    milestone "End initialize_disks $PARTITION"
}

select_partitions_to_restore()
{
    get_cloned_partitions

    # This funcitons get the list of the avaiable partitions
    echo -n "dialog --colors --backtitle \"OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}\" --title \"Zur Verfuegung stehende Partitionen\" --checklist \"Waehlen Sie die zu bearbeitende Partitionen\" 18 60 8 " > /tmp/command
    for PARTITION in `cat /tmp/partitions`
    do
    	DESC=$( get_ldap $PARTITION DESC )
	echo -n "$PARTITION '$DESC' on " >> /tmp/command
    done
    echo -n " 2> /tmp/partitions"  >> /tmp/command
    . /tmp/command
    if [ $? -ne 0 ]; then
         rm /tmp/partitions
    fi
    sed -i 's#"##g'     /tmp/partitions
}

make_autoconfig()
{
	OS=$( get_ldap $PARTITION OS)
	mkdir -p /mnt/$PARTITION
	case $OS in
	    Win*)
		mount -o rw /dev/$PARTITION /mnt/$PARTITION

		sleep 1
		MOUNTED=$( mount | grep /mnt/$PARTITION )
		if [ -z "$MOUNTED" ]; then # We need the Presslufthammer!
		    /usr/bin/ntfs-3g -o force,rw /dev/$PARTITION /mnt/$PARTITION
		fi
	        # If we do not have to join the domain do nothing else until the post script
		JOIN=$( get_ldap $PARTITION JOIN)
		if [ "$JOIN" = "no" ]; then
		    continue
		fi
	        ProductID=$( get_ldap $PARTITION ProductID)
		if [ -e /mnt/itool/config/${OS}${JOIN}.xml ]; then
		    cp /mnt/itool/config/${OS}${JOIN}.xml /mnt/$PARTITION/Windows/Panther/Unattend.xml
		    sed -i "s/HOSTNAME/$HOSTNAME/"        /mnt/$PARTITION/Windows/Panther/Unattend.xml
#		    sed -i "s/PRODUCTID/$ProductID/"      /mnt/$PARTITION/Windows/Panther/Unattend.xml
		    sed -i "s/WORKGROUP/$WORKGROUP/"      /mnt/$PARTITION/Windows/Panther/Unattend.xml
		    #cp /mnt/itool/config/${OS}${JOIN}.xml /mnt/$PARTITION/Unattend.xml
		    #sed -i "s/HOSTNAME/$HOSTNAME/"        /mnt/$PARTITION/Unattend.xml
		    #sed -i "s/PRODUCTID/$ProductID/"      /mnt/$PARTITION/Unattend.xml
		    #sed -i "s/WORKGROUP/$WORKGROUP/"      /mnt/$PARTITION/Unattend.xml
		fi
		cp /mnt/itool/config/domainjoin.bat /mnt/$PARTITION/script/domainjoin.bat
		cp /mnt/itool/config/domainjoin.ps1 /mnt/$PARTITION/script/domainjoin.ps1
		sed -i s/HOSTNAME/${HOSTNAME}/      /mnt/$PARTITION/script/domainjoin.ps1
		sed -i s/WORKGROUP/${WORKGROUP}/    /mnt/$PARTITION/script/domainjoin.ps1
	    ;;
	    Linux|Data)
		mount -o rw /dev/$PARTITION /mnt/$PARTITION
	    ;;
	    *)
	    ;;
	esac
	# If an postscript for this partition exist we have to execute it
	if [ -e /mnt/itool/images/$HW/$PARTITION-postscript.sh ]; then
	    . /mnt/itool/images/$HW/$PARTITION-postscript.sh
	fi
        milestone "End  make_autoconfig $PARTITION"
	umount /dev/$PARTITION
}

restore_partitions()
{
     for PARTITION in `cat /tmp/partitions`
     do
	OS=$( get_ldap $PARTITION OS)
	if [ $OS = 'Data' ]; then 
	    	FORMAT=$( get_ldap $PARTITION FORMAT)
		case $FORMAT in
			msdos|vfat|ntfs|ext2|ext3)
		    		/sbin/mkfs.$FORMAT /dev/$PARTITION
			;;
			swap)
				/sbin/mkswap /dev/$PARTITION
			;;
			clone)
				restore /dev/$PARTITION /mnt/itool/images/$HW/$PARTITION.img
			;;
		esac
	elif [ -e /mnt/itool/images/$HW/$PARTITION.img ]; then
		restore /dev/$PARTITION /mnt/itool/images/$HW/$PARTITION.img
	else
		dialog --colors  --backtitle "OpenSchoolServer-CloneTool - ${IVERSION} ${HWDESC}" \
			--title "\Zb\Z1Ein Fehler ist aufgetreten:" \
			--msgbox "Die Imagedatei existiert nicht:\n //install/itool/images/$HW/$PARTITION.img" 17 60
	fi
	sleep $SLEEP
        milestone "End  restore_partitions $PARTITION"
	cls
	make_autoconfig
	sleep $SLEEP
     done
}

####################################################
#
# Now we start the cloning programm
#
###################################################

## Set some variables
if [ -z "$SLEEP" ]; then
        SLEEP=1
fi

. /tmp/dhcp.ini

MAC=$( echo $DHCPCHADDR | gawk '{ print toupper($1) }' )
MACN=$( echo $MAC | sed "s/:/-/g")

echo "MAC      $MAC"
echo "MACN     $MACN"
echo "HOSTNAME $HOSTNAME"

## Get the DN of the Workstation
HOSTDN=`ldapsearch -x -LLL "(dhcpHWAddress=ethernet $MAC)" dn | sed 's/dn: //'| sed '/^$/d' | sed 's/^ //' | gawk '{ printf("%s",$1) }'`
echo "HOSTDN $HOSTDN"

# Check if I'm Master
MASTER=$(ldapsearch -LLL -x "(&(dhcpHWAddress=ethernet $MAC)(configurationValue=MASTER=yes))" dn)
echo "MASTER $MASTER"

# Get my conf value if not defined by the kernel parameter
if  [ -z "$HW" ]; then           
    HW=$(ldapsearch -LLL -x "(dhcpHWAddress=ethernet $MAC)" configurationValue | grep 'configurationValue: HW=' | sed 's/configurationValue: HW=//')
fi

echo "HW $HW"

#Get my configuration description
HWDESC=$(ldapsearch -x -LLL configurationKey=$HW description | grep 'description:' | sed 's/description: //')
echo "HWDESC $HWDESC"

## Get the DN of the HW configuration
HWDN=`ldapsearch -x -LLL configurationKey=$HW dn | sed 's/dn: //'| sed '/^$/d' | sed 's/^ //' | gawk '{ printf("%s",$1) }'`
echo "HWDN $HWDN"

## Get the list of the harddisks
HDs=`sfdisk -s | grep -v loop | gawk -F: ' /dev/ { print $1 }' | sed 's#/dev/##g'` 
echo "HDs $HDs"

## Get the WORKGROUP
WORKGROUP=$( ldapsearch -x -LLL configurationkey=SCHOOL_WORKGROUP configurationValue | grep 'configurationValue:' | sed 's/configurationValue: //')
echo "WORKGROUP $WORKGROUP"

# Activating DMA mode
echo -n "" > /tmp/prts.fs
for i in $HDs
do
   hdparm -d1 /dev/$i > /dev/null 2>&1
   parted -m -s /dev/$i print > /tmp/prts
   echo '/^[0-9]/ { printf("/dev/%s%i:%s\n","'$i'",$1,$5) }' > /tmp/prts.awk
   gawk -F : -f /tmp/prts.awk /tmp/prts >> /tmp/prts.fs
done
echo "SLEEP $SLEEP"
sleep $SLEEP

# Is hostname defined we save the hardware configuration
if [ "$HOSTNAME" ]; then
    save_hw_info
fi

if [ "$MODUS" = "AUTO" ]; then
    # we only have to repair the MBR
    if [ "$PARTITIONS" = "MBR" ]; then
        mbr
        restart
    fi
    IFS=","
    for i in $PARTITIONS
    do
	[ "$i" = "MBR" ] && continue
    	echo $i >> /tmp/partitions
    done
    unset IFS
    initialize_disks
    restore_partitions
    restart
fi

# Get Username and Password
USERNAME=`cat /tmp/username`
## Get the BINDDN
BINDDN=`ldapsearch -x -LLL uid=$USERNAME dn | sed 's/dn: //'| sed '/^$/d' | sed 's/^ //' | gawk '{ printf("%s",$1) }'`
echo "BINDDN $BINDDN"

