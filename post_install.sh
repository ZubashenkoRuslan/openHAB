#!/bin/bash

# To fix errors like 
# "syntax error near unexpected token `$'{\r''" run
# sed -i 's/\r//' setup.sh
# or change line endings to Unix(LF)

############## WSL only:
# wsl
# cd /tmp 
# wget --content-disposition "https://gist.githubusercontent.com/djfdyuruiry/6720faa3f9fc59bfdf6284ee1f41f950/raw/952347f805045ba0e6ef7868b18f4a9a8dd2e47a/install-sg.sh" 
# chmod +x /tmp/install-sg.sh 
# /tmp/install-sg.sh && rm /tmp/install-sg.sh 
# exit 

# wsl --shutdown 
# wsl genie -s
# cd /mnt/d/openhab/configs_scripts/
##############

# To execute, run
# cd /tmp
# wget --content-disposition "https://raw.githubusercontent.com/ZubashenkoRuslan/openHAB/main/post_install.sh"
# chmod +x /tmp/post_install.sh 
# sudo /tmp/post_install.sh 
# sudo rm /tmp/post_install.sh


function test_colors() {
	for code in {0..255}; 
	do 
		echo -e "\e[38;05;${code}m $code: Test"; 
	done
}

# write text colorCode{0:256} indent{0:int} echo_empty_line{0:1}
function write(){
	local text=$1;
	local code=${2:-39};
	local indent=${3:-0}	
	local echo_empty_line=${4:-1}
	
	local resetcolorcode=255;
	local prefix=''
	local char=' '
	
	if [ "$echo_empty_line" == "1" ]
	then
	   echo '';
	fi
	
	for (( i = 0; i < "$indent"; ++i ))
    do
		prefix="$prefix$char"
    done
	echo -e "\e[38;5;${code}m$prefix$text \e[38;5;${resetcolorcode}m";
	
}

function write_file(){
	local input=$1
	while IFS= read -r line 
		do
		  write "$line" 222 10 0
		done < "$input"
}

function install_samba(){
	write "apt-get update:"
	apt-get update -y

	write "apt-get install samba samba-common-bin:"
	apt-get install samba samba-common-bin -y

	read -p "smb user : " smbuser
	sudo smbpasswd -a $smbuser
	
	share_root "$smbuser" '/' 'RootFolder'
}

function share_root(){
	local userName=$1
	local path=$2
	local folderAlias=${3:-$path}
	local comment=${4:-$folderAlias}
	
	write "Share [root]"
	sudo echo "

[$folderAlias]
comment=$comment
path=$path
browseable=Yes
writeable=Yes
only guest=no
public=no
guest account = $userName
create mask=0777
directory mask=0777" >> /etc/samba/smb.conf

	write 'Test Parameters:' 14 
	samba-tool testparm
	write 'sudo service smbd restart'
	sudo service smbd restart
}

function install_mosquitto(){
	sudo apt-get update
	sudo apt-get install mosquitto mosquitto-clients -y
	sudo systemctl enable mosquitto
	sudo systemctl start mosquitto
	
	# Possible error, no problem:
	ufw allow 1883/tcp	
	ufw allow 5266/tcp	
	
	read -p "Mosquitto 1883 user name : " mosUser
	sudo mosquitto_passwd -c /etc/mosquitto/1883_pass $mosUser
	read -p "Mosquitto 5266 user name : " mosUser
	sudo mosquitto_passwd -c /etc/mosquitto/5266_pass $mosUser
	echo "
per_listener_settings true

listener 1883
allow_anonymous false
password_file /etc/mosquitto/1883_pass

listener 5266
allow_anonymous false
password_file /etc/mosquitto/5266_pass"  >> /etc/mosquitto/mosquitto.conf;
	
	# systemctl restart mosquitto
	write "Reload mosquitto config:"
	ps aux | grep 'mosquit+' | awk '{print $2}' | xargs sudo kill -HUP
	sudo systemctl restart mosquitto
}

#############################################################################################
function main(){
#test_colors

write 'Share Folders:'
install_samba

write 'Install MQTT:'
install_mosquitto
}

main