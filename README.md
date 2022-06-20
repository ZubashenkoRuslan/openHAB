## openHAB

1. Download openhab image from https://github.com/openhab/openhabian/releases
2. RaspberryPiImagerForWindows_1.7.2 or balenaEtcher-Portable-1.7.9 -> write image to sd card
3. Go to "boot"->openhabian.conf -> wifi_ssid="wifi_name", wifi_psk="wifi_password"
	hostname=openhab
	username=openhabian
	userpw=openhabian
4. Run RasPi, wait while ping openhabian -t

5. Shared Folders: 
sudo apt-get install samba samba-common-bin
sudo vim /etc/samba/smb.conf

Check:
wins support = yes

Add:
[root]
  comment=Root
  path=/
  browseable=Yes
  writeable=Yes
  only guest=no
  public=no
  create mask=0777
  directory mask=0777

sudo smbpasswd -a qa
samba-tool testparm
sudo service smbd restart

	# ip addr | grep eth0 | grep inet
	
6. Install MQTT:
	### System has not been booted with systemd as init system (PID 1). Can't operate. 
	### WSL SOLUTION:
	https://askubuntu.com/questions/1379425/system-has-not-been-booted-with-systemd-as-init-system-pid-1-cant-operate
	1. Run:
	sudo -b unshare --pid --fork --mount-proc /lib/systemd/systemd --system-unit=basic.target
	2. Wait a few seconds for Systemd to start up, then:
	sudo -E nsenter --all -t $(pgrep -xo systemd) runuser -P -l $USER -c "exec $SHELL"
	3. exiting all WSL instances completely, then doing (terminal):
	wsl --shutdown
	
	
	
	sudo su

	apt-get update
	apt-get install mosquitto -y
	systemctl enable mosquitto
	systemctl start mosquitto
	
	Possible error, no problem:
	ufw allow 1883/tcp	
	
	sudo mosquitto_passwd -c /etc/mosquitto/passwd mosUser
	
	echo "
per_listener_settings true

listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd"  >> /etc/mosquitto/mosquitto.conf;
	
	##	OR:
	sudo vim /etc/mosquitto/mosquitto.conf

	# Mosquitto PID (f.e.: 1483):
	sudo ps ax | grep mosq
	sudo kill -HUP 1483
	systemctl restart mosquitto



## OPENNAB-CLI Commands:

openhab-cli backup
openhab-cli restore <archive file>

# Temperature monitoring:
watch -c -d -n 1  -- 'vcgencmd measure_temp'

# mosquitto:
mosquitto_pub -t sensors/temperature -u 'mosUsr2' -P 'mosPwd2' -p 5266 -m 12 -q 1 -r 10
mosquitto_sub -u 'mosUsr2' -P 'mosPwd2' -p 5266  -t sensors/temperature -q 1


