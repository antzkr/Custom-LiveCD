#!/bin/bash


# v7
#########################################################################
#
# Script to build a bootable live environment using Debian 12 x64 base & Ubuntu Mate as the desktop
# Credit to Will Haley for inspiring this script: https://www.willhaley.com/blog/custom-debian-live-environment/
#
#########################################################################



# Export home directory variable (user not root account directory)
PATH1="$(getent passwd $SUDO_USER | cut -d: -f6)"
export PATH1


# Install prerequisite programs
sudo apt install debootstrap squashfs-tools xorriso isolinux syslinux-efi grub-efi-amd64-bin grub-efi-ia32-bin mtools dosfstools -y


# Create workspace for building live environment
mkdir -p $PATH1/LIVE_BOOT


# Bootstrap debian 12
sudo debootstrap --arch=amd64 --variant=minbase bookworm $PATH1/LIVE_BOOT/chroot http://ftp.us.debian.org/debian/


# Chroot into live environment
sudo chroot $PATH1/LIVE_BOOT/chroot /bin/bash <<"EOT"

# Update sources.list
cat <<'EOF' > /etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/ bookworm-security contrib main non-free non-free-firmware
EOF

# Mount system directories to avoid installation errors
mount none -t proc /proc && mount none -t sysfs /sys && mount none -t devpts /dev/pts

# Exit script gracefully if errors encountered
trap 'umount /proc; umount /sys; umount /dev/pts; exit' ERR EXIT

apt update

# Essential programs for livecd debian environment
apt install linux-image-amd64 live-boot systemd-sysv -y

# Install programs according to your preference here (mate desktop with 3rd party firmware)
DEBIAN_FRONTEND=noninteractive apt install mate-desktop-environment-core task-mate-desktop mate-desktop-environment-extras caja-extensions-common sudo gdebi-core nano keepassxc gnupg dmsetup zulumount-gui zulucrypt-gui zip unzip neofetch testdisk vlc cheese apt-utils firmware-amd-graphics firmware-ath9k-htc firmware-iwlwifi firmware-realtek firmware-misc-nonfree firmware-atheros firmware-brcm80211 firmware-b43-installer printer-driver-all cups p7zip-full amd64-microcode intel-microcode gparted locales-all qtqr metadata-cleaner wget exfatprogs ntfs-3g xfsprogs xfsdump lvm2 cryptsetup dosfstools mtools gufw diceware diceware-doc -y

# Setup live user with password, home directory & sudo access (no root account)
adduser debian12live --disabled-password --comment "Debian12Mate-Live"
echo "debian12live:debian12live" | chpasswd
usermod -aG sudo debian12live

# Add network hostname
echo "debian12mate-live" > /etc/hostname
sed -i '1s/^/127.0.0.1	debian12mate-live\n/' /etc/hosts

# Setup lightdm & user autologin (mate desktop)
touch /usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf
cat <<'EOF' > /usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf
[SeatDefaults]
greeter-session=lightdm-gtk-greeter
autologin-user=debian12live
EOF

# Set locale to US English
locale-gen en_US.UTF-8

# Upgrade debian environment
apt update && apt upgrade -y

# Install Librewolf & dependencies (privacy focused browser)
distro=$(if echo " bookworm focal impish jammy uma una vanessa" | grep -q " $(lsb_release -sc) "; then echo $(lsb_release -sc); else echo focal; fi)
wget -O- https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf.gpg

sudo tee /etc/apt/sources.list.d/librewolf.sources << EOF > /dev/null
Types: deb
URIs: https://deb.librewolf.net
Suites: $distro
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/librewolf.gpg
EOF

apt update && apt install curl dirmngr ca-certificates software-properties-common apt-transport-https librewolf -y

# Remove programs if necessary (-y flag can be dangerous)
apt remove libreoffice-impress libreoffice-math libreoffice-draw transmission-common synaptic imagemagick gimp -y

# Set desktop wallpaper manually by priority
echo 5 | update-alternatives --config desktop-background

# Clean up left over libraries & installations
apt autoclean -y && apt autoremove -y

# Unmount system directories
umount /proc && umount /sys && umount /dev/pts

# Delete bash history
echo > /root/.bash_history

echo $$
EOT


# Directories that will contain files for the live environment files plus scratch files
mkdir -p $PATH1/LIVE_BOOT/{staging/{EFI/BOOT,boot/grub/x86_64-efi,isolinux,live},tmp}


# Compress filesystem (if you need to make further changes later on to chroot you need to delete 'filesystem.squashfs' and run this command again)
sudo mksquashfs $PATH1/LIVE_BOOT/chroot $PATH1/LIVE_BOOT/staging/live/filesystem.squashfs -e boot
cp $PATH1/LIVE_BOOT/chroot/boot/vmlinuz-* $PATH1/LIVE_BOOT/staging/live/vmlinuz
cp $PATH1/LIVE_BOOT/chroot/boot/initrd.img-* $PATH1/LIVE_BOOT/staging/live/initrd


# Bootloader menu (BIOS/legacy mode)
cat <<'EOF' >$PATH1/LIVE_BOOT/staging/isolinux/isolinux.cfg
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT linux
TIMEOUT 600
MENU RESOLUTION 640 480
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL linux
  MENU LABEL Debian 12 Live [BIOS/ISOLINUX]
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live

LABEL linux
  MENU LABEL Debian 12 Live [BIOS/ISOLINUX] (nomodeset)
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live nomodeset
EOF


# Bootloader menu (EFI mode)
cat <<'EOF' > $PATH1/LIVE_BOOT/staging/boot/grub/grub.cfg
insmod part_gpt
insmod part_msdos
insmod fat
insmod iso9660

insmod all_video
insmod font

set default="0"
set timeout=30

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "Debian 12 Live [EFI/GRUB]" {
    search --no-floppy --set=root --label DEB12LIVE
    linux ($root)/live/vmlinuz boot=live
    initrd ($root)/live/initrd
}

menuentry "Debian 12 Live [EFI/GRUB] (nomodeset)" {
    search --no-floppy --set=root --label DEB12LIVE
    linux ($root)/live/vmlinuz boot=live nomodeset
    initrd ($root)/live/initrd
}
EOF
#
#
cp $PATH1/LIVE_BOOT/staging/boot/grub/grub.cfg $PATH1/LIVE_BOOT/staging/EFI/BOOT/


# Boot configuration
cat <<'EOF' >$PATH1/LIVE_BOOT/tmp/grub-embed.cfg
if ! [ -d "$cmdpath" ]; then
    # On some firmware, GRUB has a wrong cmdpath when booted from an optical disc.
    # https://gitlab.archlinux.org/archlinux/archiso/-/issues/183
    if regexp --set=1:isodevice '^(\([^)]+\))\/?[Ee][Ff][Ii]\/[Bb][Oo][Oo][Tt]\/?$' "$cmdpath"; then
        cmdpath="${isodevice}/EFI/BOOT"
    fi
fi
configfile "${cmdpath}/grub.cfg"
EOF


# Copy bootloader files into workspace
cp /usr/lib/ISOLINUX/isolinux.bin "$PATH1/LIVE_BOOT/staging/isolinux/"
cp /usr/lib/syslinux/modules/bios/* "$PATH1/LIVE_BOOT/staging/isolinux/"
cp -r /usr/lib/grub/x86_64-efi/* "$PATH1/LIVE_BOOT/staging/boot/grub/x86_64-efi/"


# Generate EFI bootable grub images
grub-mkstandalone -O i386-efi --modules="part_gpt part_msdos fat iso9660" --locales="" --themes="" --fonts="" --output="$PATH1/LIVE_BOOT/staging/EFI/BOOT/BOOTIA32.EFI" "boot/grub/grub.cfg=$PATH1/LIVE_BOOT/tmp/grub-embed.cfg"
grub-mkstandalone -O x86_64-efi --modules="part_gpt part_msdos fat iso9660" --locales="" --themes="" --fonts="" --output="$PATH1/LIVE_BOOT/staging/EFI/BOOT/BOOTx64.EFI" "boot/grub/grub.cfg=$PATH1/LIVE_BOOT/tmp/grub-embed.cfg"


# FAT16 UEFI boot disk image containing the EFI bootloaders
(cd $PATH1/LIVE_BOOT/staging && dd if=/dev/zero of=efiboot.img bs=1M count=20 && mkfs.vfat efiboot.img && mmd -i efiboot.img ::/EFI ::/EFI/BOOT && mcopy -vi efiboot.img $PATH1/LIVE_BOOT/staging/EFI/BOOT/BOOTIA32.EFI $PATH1/LIVE_BOOT/staging/EFI/BOOT/BOOTx64.EFI $PATH1/LIVE_BOOT/staging/boot/grub/grub.cfg ::/EFI/BOOT/)


# Generate the bootable .iso disc image file (for further changes to chroot run this command again)
xorriso -as mkisofs -iso-level 3 -o "$PATH1/LIVE_BOOT/debian12mate-custom-livecd.iso" -full-iso9660-filenames -volid "DEB12MATE-LIVE" --mbr-force-bootable -partition_offset 16 -joliet -joliet-long -rational-rock -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -eltorito-boot isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table --eltorito-catalog isolinux/isolinux.cat -eltorito-alt-boot -e --interval:appended_partition_2:all:: -no-emul-boot -isohybrid-gpt-basdat -append_partition 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B $PATH1/LIVE_BOOT/staging/efiboot.img "$PATH1/LIVE_BOOT/staging"

echo "Generating iso hash, please wait....."

# Generate SHA256 hash of bootable iso
cd $PATH1/LIVE_BOOT
sudo sha256sum debian12mate-custom-livecd.iso > debian12mate-custom-livecd.sha256sum


# Set full permissions on iso & hash
sudo chmod 777 debian12mate-custom-livecd.iso
sudo chmod 777 debian12mate-custom-livecd.sha256sum


echo -e "\nDebian 12 Mate LiveCD build completed.\nSHA256 hash can also be found in the target directory $PATH1\n\nDefault username is: debian12live\nDefault password is: debian12live\n\nPlease change password at next session login"
