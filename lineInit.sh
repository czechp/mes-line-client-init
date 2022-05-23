#!/usr/bin/bash


function show_statement(){
	echo ""
	echo $1
	echo "--------------------------------------"
}

clear

show_statement "Script to set configuration for Raspberry Pi to work as OPC/RFID Reader in MES System"
show_statement "Created by PCzech"
read -p "Push some button to start or CTRL+C to terminate"

function push_some_button(){
	read -p "Push some button to proceed ..."
}


function network_configuration(){

	read -p "Enter Ip Address  for RPI: " IP_ADDRESS

	echo "" > /etc/dhcpcd.conf
	set_in_dhcpcd_conf "hostname"
	set_in_dhcpcd_conf "clientid"
	set_in_dhcpcd_conf "persistent"
	set_in_dhcpcd_conf "option rapid_commit"
	set_in_dhcpcd_conf "option domain_name_servers, domain_name, domain_search, host_name"
	set_in_dhcpcd_conf "option classless_static_routes"
	set_in_dhcpcd_conf "option interface_mtu"
	set_in_dhcpcd_conf "require dhcp_server_identifier"
	set_in_dhcpcd_conf "slaac private "
	set_in_dhcpcd_conf "interface eth0"
	set_in_dhcpcd_conf "static ip_address=${IP_ADDRESS}/16"
	set_in_dhcpcd_conf "static routers=192.168.0.249"
	set_in_dhcpcd_conf "static domain_name_servers=192.168.6.52"


	show_statement "Network configured"
	push_some_button
}

function set_in_dhcpcd_conf(){
	echo $1 >> /etc/dhcpcd.conf
}

function node_js_configuration(){
	cd "/home/pi"
	show_statement "Downloading  NODE JS ... "
	rm -R node*
	NODE_URL=https://nodejs.org/dist/v14.18.1/node-v14.18.1-linux-armv7l.tar.xz
	wget ${NODE_URL}
	show_statement "Extracting NODE JS ... "
	NODE_ARCHIVE_NAME=$(ls | grep node*tar.xz)
	tar -xf ${NODE_ARCHIVE_NAME}
	rm -R ${NODE_ARCHIVE_NAME}
	show_statement "Installing  NODE JS ..."
	NODE_DIRECTORY_NAME=$(ls | grep node*)
	cd "/home/pi/${NODE_DIRECTORY_NAME}"
	cp -R * /usr/local
	RESULT=$(node -v)
	if [ ${RESULT:0:1} == "v" ]
	then
		show_statement "NODE JS installed successfully"
		show_statement "Your  NODE JS version is: ${RESULT}"
	else
		show_statement "Error during installing  NODE JS"
	fi
	cd /home/pi
	rm -R node*
	push_some_button
}

function make_mes_station(){
	MES_DIRECTORY="/home/pi/Programming/OpcRfidReader"
	if [ -d ${MES_DIRECTORY} ]
	then
		echo "Purging ${MES_DIRECTORY} directory ... "
		cd ${MES_DIRECTORY}
		rm -r ${MES_DIRECTORY}
	fi

	show_statement "Creating ${MES_DIRECTORY} directory ... "
	mkdir -p ${MES_DIRECTORY}

	cd ${MES_DIRECTORY}

	show_statement "Downloading project ..."
	git clone someGitLink .

	clear
	show_statement "Project already downloaded"
	show_statement "Installing node modules"
	sudo npm install
	clear
	show_statement "Project installed successfully"
	push_some_button
}


function set_mes_autostart(){

	echo "#!/bin/sh -e" > /etc/rc.local
	echo "#" >> /etc/rc.local
	echo "# rc.local" >> /etc/rc.local
	echo "#" >> /etc/rc.local

	echo "node /home/pi/Programming/OpcRfidReader/index.js &" >> /etc/rc.local
	echo "exit 0" >> /etc/rc.local
	show_statement "MES APP set to autostart"
	push_some_button
}

function reboot_device(){
	sudo reboot
}



clear

read -p "Do you want to configure network? (y/n)" COMMAND

if [ "${COMMAND}" == "y" ]
then
	network_configuration
fi

clear
read -p "Do you want to install  NODE JS? (y/n)" COMMAND
if [ "${COMMAND}" == "y" ]
then
	node_js_configuration
fi

clear
read -p "Do  you want to transform RPI to MES station? (y/n)" COMMAND

if [ "${COMMAND}" == "y" ]
then
	make_mes_station
fi

clear
read -p "Do you want to set MES app to autostart? (y/n)" COMMAND
if [ "${COMMAND}" == "y" ]
then
	set_mes_autostart
fi

clear
read -p "Script finised. Do you want to reboot device?(y/n)"
if [ "${COMMAND}" == "y" ]
then
	reboot_device
fi
