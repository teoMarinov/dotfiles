# Archinstall

Before installing run `rfkill` to see if there's a softblock on the wifi and run `rfkill unblock wifi`
If you need to format your disk run `lsblk` to see all partitions then `gdisk /dev/[name_of_disk]` press `x` then `z` then `y` `y` and you are done.
Run `pacman -Syu`

To connect to the internet:

```
iwctl

[iwd] device list
[iwd] wlan0 set-property Powered on
[iwd] station wlan0 get-networks
[iwd] station wlan0 connect [NAME]
[iwd] exit
```

After installing run `nmtui` to connect to the wifi

```
Setup installation

cd ~
sudo pacman -S git
git clone https://github.com/teoMarinov/dotfiles.git
cd dotfiles
chmod +x install.sh sync_device_names.sh

./install.sh
```
