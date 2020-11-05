---
title: "Raspberry Citrix with Dual Monitor"
date: 2020-02-28T10:55:50+01:00
---

Citrix Workspace App is the client component of Citrix
Workspace. It enables access to a full desktop on a
remote host and is available for many different platforms.
A colleague recently mentioned it could be installed
on a Raspberry. So I have not hesitated and
ordered a Raspberry Pi 4 to setup a thin-client for
work from home. I use this Raspberry for nothing but
Citrix, so I try to keep the number of installed packages
at a minimum. Below I will explain how I setup a Citrix
Workspace App on Raspbian on a Raspberry Pi 4 with
two monitors.

## Hardware
- Raspberry Pi 4 Model B 4GB
- 16GB Class 10 SD Card
- 2 x Monitors 1920x1080

Since I wanted to be sure to have enough RAM, I have gone
for the 4GB version. It is definitely not needed for
this setup. The memory usage usually is below 500MB,
so 2G is definitely enough. I use a 16GB SD card since
it was as expensive as a 8GB, Rasbian Lite with all
the packages takes 2.5GB. 4GB or 8GB would have been
enough.

## Install Rasbian Lite
First the Raspbian Buster Lite image is written to the
SD card. It can be downloaded from
[Rasberry downloads][raspi-download].
The SD card may not be `/dev/mmcblk0` on a different
system. The proper device can be found for example with
`fdisk -l`.

```bash
$ sudo dd bs=4M if=raspbian-buster-lite.img of=/dev/mmcblk0 conv=fsync status=progress
```

If `dd` cannot be used to write the image to
the SD card, there is a guide in
[Raspberry documentation][raspi-write-sdcard].

That's it, given everything is connected to the Raspberry.
It can be booted now. Login is `pi` and password is
`raspberry`. First, the system is updated and then
`raspi-config` can be run to do some basic
configuration.

```bash
$ sudo apt update
$ sudo apt dist-upgrade
$ sudo raspi-config
```
In order to use the complete screen, overscan is deactivated.
Since it is not intended to use this raspberry for anything
else than Citrix, it is more convenient to autologin after
boot.

- Deactivate overscan: 7 Advanced -> A2
- Autologin into console: 3 Boot -> B2
- Update timezone: 3 Localization -> I2
- Reboot after configuration

## Setup window manager and browser
For this thin-client there is no desktop environment
with office software, games etc. required. It only
needs a browser to get a Citrix session and Citrix
Workspace App. If only one monitor is used, almost any
window manager can be used. With two monitors it
has shown slightly more difficult, Citrix gets
`_NET_WM_FULLSCREEN_MONITORS` message, which is set
by the window manager.[^1] It appears, many window
managers do not set this variable. Of the low-footprint
window managers I have tried, only xfwm4 and icewm
work out of the box with multiple monitors. dwm, jwm
and fluxbox have worked with one monitor only. So I
have chosen xfwm4, because it looks nicer. To get
a Citrix connection, I do need a browser. I chose
Midori, because it feels light.

```bash
$ sudo apt install xfwm4 xfce4-panel xinit xterm
$ sudo apt install midori
```

Since I do not want to have any transparency, shadows
etc. I deactivated the xfwm4 compositor. The settings
menu can be opened through bash.
```bash
$ xfwm4-tweaks-settings
```

The window manager should be started when autologin
starts bash. So we add the xfce4-panel and xfwm4 to
`.xinitrc`.
```bash
$ cat << EOF > ~/.xinitrc
xfce4-panel &
exec xfwm4
EOF
```

And then `startx` in `.bashprofile`.
```bash
$ cat << EOF > ~/.bash_profile
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec startx
fi
EOF
```

After this we can reboot into xfwm4.
```bash
$ reboot
```

## Setup Citrix workspace
So far we have prepared a minimal Raspbian, with a
window manager and a browser. Now we can download
*Citrix Workspace app for Linux (ARM HF)* from
[Citrix for Linux][citrix-linux]. Make sure to download
the ARM version for Debian.

Assuming Workspace app has been downloaded to Downloads,
it can the be installed with `dpkg`. In case there are
any packages missing, installation will fail and the
missing package will be reported. The missing package 
can be installed with `apt install missing-package` 
and then Workspace app installation with `dpkg` can
be tried again.
```bash
$ sudo dpkg -i Downloads/icaclient_19.12.0.19_armhf.deb
```

Make ssl certificates available to ICAClient.
```bash
$ sudo ln -sf /etc/ssl/certs/* /opt/Citrix/ICAClient/keystore/cacerts/
```

In case the certificate of your companies website
is not trusted, you can add it to your certificates
and update the certificates.
```bash
$ sudo mv certificate.crt /usr/local/share/ca-certificates/
$ sudo update-ca-certificates
```

## Citrx Configuration
For my headset to work on the remote host, I also installed
Pulseaudio plugin and changed the `AllowAudioInput` in
`~/wfclient.ini` to `true`.
```bash
$ sudo apt install xfce4-pulseaudio-plugin
```

`wfclient.ini`:
```
AllowAudioInput=True
```

In different applications I use mouse middle click, e.g. to
close tabs or to open in a new tab. The default Citrix configuration
remaps mouse middle click to `paste` (ctrl + v). I commented this
line with a semicolon.
```
;MouseSendsControlV=True
```

## Backup
Finally, I made a backup of my Raspberry on my notebook.
```bash
$ sudo dd bs=4M if=/dev/mmcblk0 of=raspbian-citrix.img conv=fsync status=progress
```

## Start Citrix
- Get Citrix connection file
- Open downloaded icx file

[^1]: [How to make a session that spans multiple monitors with Linux Receiver](https://support.citrix.com/article/CTX209485)

[raspi-download]: https://www.raspberrypi.org/downloads/raspbian/
[raspi-write-sdcard]: https://www.raspberrypi.org/documentation/installation/installing-images/README.md
[citrix-linux]: https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html

## References
- [autologin with systemd](https://unix.stackexchange.com/questions/42359/how-can-i-autologin-to-desktop-with-systemd)
- [Use multiple monitor and full screen with Citrix receiver on Linux](https://arsenicks.wordpress.com/2019/01/30/use-multiple-monitor-and-full-screen-with-citrix-receiver-on-linux/)
- [Optimize Citrix](https://docs.citrix.com/en-us/receiver/linux/current-release/optimize.html)
- [Configure Citrix](https://docs.citrix.com/en-us/citrix-workspace-app-for-linux/configure-xenapp.html)
- [Raspberry Pi as a Citrix Virtual Apps and Desktops thin client: second helping](https://www.citrix.com/blogs/2018/11/30/raspberry-pi-as-a-citrix-virtual-apps-and-desktops-thin-client-second-helping/)
- [Installing Citrix Receiver (Raspberry Pi)](https://geektechstuff.com/2018/06/24/installing-citrix-receiver-raspberry-pi/)
- [How good is the new Raspberry Pi 4 as a thin client?](https://www.citrix.com/blogs/2019/07/08/how-good-is-the-new-raspberry-pi-4-as-a-thin-client/)
