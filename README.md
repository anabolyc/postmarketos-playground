# Overview

This project automates the building and installation of a customized postmarketOS image for a specific phone models ([Samsung Galaxy S3]https://wiki.postmarketos.org/wiki/Samsung_Galaxy_S_III_(samsung-m0) and [Google Nexus 5](https://wiki.postmarketos.org/wiki/Google_Nexus_5_(lg-hammerhead))). The scripts provided streamline the process of preparing the device for immediate use by pre-configuring WiFi credentials and setting up an auto-start monitoring environment.

# Purpose

Build a postmarketOS image tailored for the Samsung M0 and LG Hammerhead devices.
- Pre-configure WiFi so the device connects to a specified network (wifi-12-private) automatically on boot.
- Auto-start monitoring tools: On login, the device launches a tmux session with two vertically stacked panes showing htop and live system logs, providing instant system monitoring.

## Scripts

### Install pmbootstrap

Pull into the root folder by clonning the code and installing it in the venv (preferrably)

```
git clone https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git
cd pmbootstrap
pip install .
pmbootstrap --version
```

### build.sh

Uses pmbootstrap to prepare the root filesystem. Injects WiFi credentials into NetworkManager so the device connects to the specified SSID on startup. Adds an autologin script for the user pm that launches a tmux session with monitoring tools (htop and journalctl, requires `systemd`). Sets up a systemd service to automatically log in the pm user on tty1 and start the monitoring environment.

### install.sh

Runs pmbootstrap install to flash the prepared postmarketOS image onto the target SD card (Samsung) or internal flash (Google) for the device. With these scripts, you can quickly build and deploy a ready-to-use postmarketOS image for your phone, complete with WiFi and monitoring setup for immediate diagnostics and usage.

### Post install

After image flashed and device booted, ssh keys are already baked into the image, so you only need to figure out the IP address of the device and ssh into it.
- You can either look up IP address in your router settings, as it would lease IP address over DHCP 
- You can connect using USB cable and simply ssh into the device on `172.16.42.1` address and check it from within

```
ssh pm@172.16.42.1
Welcome to postmarketOS! o/

This distribution is based on Alpine Linux.
First time using postmarketOS? Make sure to read the cheatsheet in the wiki:

-> https://postmarketos.org/cheatsheet

You may change this message by editing /etc/motd.

lg-hammerhead:~$ ifconfig 
wlan0     Link encap:Ethernet  HWaddr 2E:F8:6D:D3:9C:A0  
          inet addr:192.168.1.238  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::2cf8:6dff:fed3:9ca0/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:9128 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2780 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:2084965 (1.9 MiB)  TX bytes:1244018 (1.1 MiB)

```

## Workloads

I've created ansible scripts to deploy some workloads in automated way to the devices. In the `playbooks` folder there is a playbook that installs docker and portainer on top of it, both UI app and agent, so it can be managed from another portainer instance.
