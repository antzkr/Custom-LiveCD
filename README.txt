=========================================

Debian 12 MATE LiveCD/USB bootable OS build script
Version 1
July 2023

=========================================

README - DO NOT SKIP!!
This script creates a bootable ISO image of Debian 12 MATE desktop which can be burned to a CD or USB. It's designed for secure work in an isolated environment, such as examining malicious code or cryptocurrency managment offline. However this build was NOT designed for anonymous web-browsing, masking IP locations, deep-web use etc. That is out of scope so I'd recommend using a different OS.

This LiveCD/USB bootable OS runs completely from RAM. So files created during a session will not be saved and irreversibly deleted unless moved to a seperate disk. The purpose of this script is for you to build your own custom LiveCD/USB bootable OS so you don't have to trust anybody else. You built it so you know what's in it. To reduce proprietary code risk (hidden nasties), I tried to keep non-opensource software to a bare minimun. Unfortunately, building a completely opensource LiveCD/USB OS means you probably won't get access to hardware such as wifi, bluetooth, sound, webcam, graphics cards etc so I believe this is the best compromise between useability and security. Debian 12 was chosen for it's rock-solid stability, genuine commitment to opensource philosophy, and no corporate backing (potential backdoors). Ubuntu and it's derivatives (yes, that includes Mint) cannot be trusted.

The MATE desktop environment was chosen as the best balance between lightweight resource use and convenient/attractive graphical user interface. Sensible defaults are in place but can be easily changed if you want to harden the security. Root password is disabled. User account has root privilages (sudo). See here for more details: https://www.debian.org/doc/manuals/securing-debian-manual/index.en.html

There are no hard and fast rules regarding hardware requirements but I would suggest using at least a modern computer in the last 10 or 15 years:
CPU - 1.5 GHz
RAM - 2 GB
Anything less will make the user experience a real struggle. I would recommend at least 4 GB of RAM (ideally 16 GB) especially if you are going to download files.

Please review the Debian 12 LiveCD/USB bootable OS build script carefully. Liberal amount of comments have been added to the script so the purpose of each command can be understood clearly. NEVER run a script blindly without understanding what it could do. Don't trust me. Google around to find out more. Research, research, research.

Note that the build script can only be built from either Debian or Ubuntu-based linux desktop environments. Other linux derivatives such as Arch or Slackware are not supported.

You are welcome to modify the script, add or delete programs as you wish.

=========================================

INSTALLATION
To install, make executable and run script in terminal:
chmod +x debian12-mate-livecd-build-script.sh
sudo ./debian12-mate-livecd-build-script.sh

ISO is saved to your home directory ($HOME/LIVE_BOOT). SHA256 hash is generated if you want to distribute and check autheticity.

Default username: debian12live
Default password: debian12live

Burn to CD/DVD/USB and boot on your machine. UFEI and legacy BIOS are supported.

=========================================

LANGUAGE
US English

LOCALE
en-US

=========================================

INSTALLED SOFTWARE
List of open source programs included in the LiveCD/USB build:

gdebi-core (.deb installer)
nano (terminal text editor)
keepassxc (password manager & password generator)
gnupg (terminal encryption, key management, identity validation)
zulucrypt (encryption)
p7zip-full (archiver)
neofetch (terminal system information)
testdisk (terminal partition scanner, recovery, and file undelete)
vlc (video player)
cheese (webcam)
qtqr (QR code reader and generator)
metadata-cleaner (file metadata remover)
wget (terminal download manager)
gufw (linux firewall)
diceware (terminal passphrase generator)
gparted (disk partition manager)

List of firmware drivers included in the LiveCD/USB build:

firmware-ath9k-htc
firmware-iwlwifi
firmware-realtek
firmware-misc-nonfree
firmware-atheros
firmware-brcm80211
firmware-b43-installer
amd64-microcode
intel-microcode

Generic printer drivers are also included.

=========================================

LEGAL
Please note I am not responsible or liable for any damages or losses arising from your use or inability to use the script and or software used under this script. You are responsible for your use of this script. If you harm someone or get into a dispute with someone else, I will not be involved.

=========================================

