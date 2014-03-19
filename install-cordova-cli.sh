#!/bin/bash

green="\e[0;32m"
endColor="\e[0m"
echo -e "${green}"
echo "During the installation process you'll need to accept multiple licences."
echo "You should definitely know what you accept. However, in case you have" 
echo "installed packages using this script before or for some other reason"
echo "already have read the licences to be accepted during the installation"
echo "you can allow the script to accept the licences for you automatically."
echo "Do you want the script to accept licences for you, when needed? [y/n]"
echo -e "${endColor}"
read a
if [[ $a == "Y" || $a == "y" ]]; then
  echo "The script WILL accept the Google SDK Terms and Conditions for you."
  export accept=true
else
  echo "The script WILL NOT accept the Google SDK Terms and Conditions for you."
  export accept=false
fi

# Add PPA repositories offering e.g. Android SDK and ADB

echo -e "${green}"
echo "Super user rights are needed to install necessary software."
echo "If you want to know what the script does with your super user"
echo "rights, reading the script through is recommended. Press CTRL^C to abort"
echo -e "the script, or type your password to continue installation.${endColor}"
sudo add-apt-repository -y ppa:upubuntu-com/sdk &&
sudo add-apt-repository -y ppa:nilarimogard/webupd8 &&
sudo apt-get update &&

# Install NodeJS and its package management system
sudo apt-get -y install nodejs npm curl git &&
# Install cordova using NodeJS package management
sudo npm install -gf cordova &&

# The following lines update cordova
sudo npm cache clean -f &&
sudo npm install -g n &&
sudo n stable &&

# Install necessary Android-related packages
sudo apt-get -y install openjdk-6-jdk android-sdk ant \
android-tools-adb android-tools-fastboot;
sudo apt-get clean && sudo apt-get autoclean;

echo 'export PATH=${PATH}:${HOME}/android-sdk-linux/tools/' >> ~/.bashrc
export PATH=${PATH}:${HOME}/android-sdk-linux/tools/ &&
echo 'export JAVA_HOME=/usr/lib/jvm/default-java/' >> .bashrc
export JAVA_HOME=/usr/lib/jvm/default-java/
source ${HOME}/.bashrc &&

if [[ $accept == "true" ]]; then 
  echo "y" | android update sdk --filter 1,2,3,4,26,27,28,37,38,52,53,58 --no-ui 
  echo "y" | android update sdk --filter 1,2,3,5,17,18,19,20,21 --no-ui 
else
  android update sdk --filter 1,2,3,4,26,27,28,37,38,52,53,58 --no-ui
  android update sdk --filter 1,2,3,5,17,18,19,20,21 --no-ui
fi

# Let's create HelloWorld using basic cordova project creation commands
cd ~ && mkdir cordova-projects && cd cordova-projects
cordova create hello com.example.hello HelloWorld &&
cd hello &&
cordova platform add android && sleep 15 &&
cordova build && sleep 15 &&

# Now we need an Android Virtual Machine to emulate the HelloWorld
echo "no" | android create avd -n 'Default' -t 'android-17' -b x86

sleep 30 && cordova emulate android;
echo "Wait for the Android Virtual Device to boot";
echo -e "${green}"
echo "To learn about Cordova CLI, see the official documentation"
echo "at http://cordova.apache.org/docs/en/2.9.0/guide_cli_index.md.html."
echo ""
echo "To run cordova commands, the new ~/.bashrc needs to be loaded."
echo "The easiest way to do this is to open a new terminal window."
echo -e "${endColor}"