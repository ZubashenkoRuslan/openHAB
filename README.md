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
	watch -n 5 '(vcgencmd measure_temp | sed s/temp=//g | cut -c 1-4 ) | xargs -0 mosquitto_pub -t /sensors/temperature/in -u 'mosU' -P 'mosP' -p 1883 -q 1 -m $1'
	let i=0; while [ $i -le 5 ]; do vcgencmd measure_clock arm; vcgencmd measure_temp; sleep 5; ((i++)); done & ./cpuburn-a53
	let i=0; while [ $i -le 5 ]; do vcgencmd measure_clock arm; vcgencmd measure_temp | xargs -0 mosquitto_pub -t /sensors/temperature/in -u 'mosU' -P 'mosP' -p 1883 -q 1 -m $1; sleep 5; ((i++)); done & ./cpuburn-a53

# mosquitto:
	mosquitto_pub -t sensors/temperature -u 'mosUsr2' -P 'mosPwd2' -p 5266 -m 12 -q 1 -r 10	
	mosquitto_sub -u 'mosUsr2' -P 'mosPwd2' -p 5266  -t sensors/temperature -q 1
	watch 'vcgencmd measure_temp | xargs -0 mosquitto_pub -t /sensors/temperature/in -u 'mosU' -P 'mosP' -p 1883 -q 1 -m $1'



## Addind MQTT binding to the openHAB:
1. [PaperUI -> Add-ons](http://openhabian:8080/paperui/index.html#/extensions) -> BINDINGS tab;
2. Search *MQTT Binding*, install
3. [Inbox](http://openhabian:8080/paperui/index.html#/inbox/search) -> press '+' -> MQTT Binding -> Add Manually -> MQTT Broker
	Broker Hostname/IP
	Broker Port
	Username
	Password
4. Press '✔' on the top of the page to save settings
5. Should be like this:
	
	![](https://raw.githubusercontent.com/ZubashenkoRuslan/openHAB/main/img/mqtt_broker_added.png)

## Add Thing:
1. [Inbox](http://openhabian:8080/paperui/index.html#/inbox/search) -> press '➕' -> MQTT Binding -> Add Manually -> Generic MQTT Thing
2. Bridge Selection -> configured MQTT Broker - mqtt:broker:0a10a09e -> ✔
3. openHAB-conf/items/demo.items: 
	```
	Switch TestMQTT "Test item" {channel="mqtt:topic:72beba7e:testlight1"}
	Dimmer TestDimm "Test Dimmer" {channel="mqtt:topic:72beba7e:testdimm1"}
	```
4. openHAB-conf/sitemaps/demo.sitemap:
	```
	sitemap demo label="Demo Label" {
	    Frame label="First frame" icon="./icons/my_light.svg" {
		Switch item=TestMQTT
	    }
	    Frame label="Second frame" {
		Slider item=TestDimm
	    }
	}
	```
5. Check changes [here](http://openhabian:8080/basicui/app?sitemap=demo)
6. Go to [things](http://openhabian:8080/paperui/index.html#/configuration/things) -> Test MQTT thing -> Channels -> ➕
7. 
