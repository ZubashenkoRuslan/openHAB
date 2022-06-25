# Wemos D1 mini:
1. Flash the Wemos D1 mini with tools from #Useful links
2. Go to IP on Browser 
	User: admin
	Pass: <pass from firmware>
3. Config -> NONE to change if default flash tool used
4. Hardware -> 
	GPIO → LED: -> GPIO-2 (LED displays WIFI connection status)
	Submit
5. Tools -> Advanced
	Rules -> checked
	MQTT Retain Msg -> checked
	Use NTP -> checked
	NTP Hostname -> pool.ntp.org
	Timezone Offset -> 120 minutes
	Enable Serial port -> unchecked
	Submit
6.  Controllers -> Add
	Protocol -> Home Assistant (openHAB) MQTT
	Setup settings.
		Note: LWT Connect Message, LWT Disconnect Message, Enabled -> checked!!!
		
	http://192.168.4.1/setup
	WIFI password: configesp


# Useful links:
	ESPEasy Firmware: https://github.com/letscontrolit/ESPEasy
	Firmware App NodeMCU PyFlasher: https://github.com/marcelstoer/nodemcu-pyflasher/releases
	Wemos COM drivers: https://www.wemos.cc/en/latest/ch340_driver.html
	
	
