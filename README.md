#  LTSP5 readonly patch and Cookbook

This patch allow you to create readonly users. And allow you to edit default configs in user's home directory.
Any changes made by user will not be saved in its home directory.

## Readonly patch

* Copy `readonly.patch` to `/opt/ltsp/i386/usr/share/ldm/rc.d/`

* Apply patch
```bash
cd /opt/ltsp/i386/usr/share/ldm/rc.d/
patch < readonly.patch
```

* Install aufs-tools in `ltsp-chroot`
```bash
apt-get -y update
apt-get -y install aufs-tools
```

* Update your image
```bash
ltsp-update-image
```

* Create user and add it to `readonly` group
```bash
useradd -m -s /bin/bash user
passwd user
usermod -a -G readonly user
```

* Remove write permissions from user's home directory.
```bash
chown -R root:root /home/user
chmod -R o-w /home/user
```

## Cookbook

* vim:

```bash
apt-get -y install vim
```

* skype:

```bash
add-apt-repository -y "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
apt-get -y update
apt-get -y install skype
```

* hide sata disks from nautilus:

```bash
echo 'ENV{ID_ATA_SATA}=="1" ENV{UDISKS_IGNORE}="1"' >> /etc/udev/rules.d/99-hide-partitions.rules
```

* install Remmina from PPA and FreeRDP:

```bash
apt-add-repository -y ppa:remmina-ppa-team/remmina-next
apt-get -y update
apt-get -y install remmina remmina-plugin-rdp libfreerdp-plugins-standard
apt-get -y install freerdp-x11
```

* install chromium with paperflash:

```bash
sudo apt-get install chromium-browser
sudo apt-get install pepperflashplugin-nonfree
sudo update-pepperflashplugin-nonfree --install
```

* install paperflash without chrome:

```bash
add-apt-repository -y ppa:skunk/pepper-flash
add-apt-repository -y ppa:nilarimogard/webupd8
apt-get -y update
apt-get -y install pepflashplugin-installer freshplayerplugin
mkdir -p /opt/google/chrome/PepperFlash
ln -s /usr/lib/pepflashplugin-installer/libpepflashplayer.so /opt/google/chrome/PepperFlash
```

* install russian language:

```bash
apt-get -y install `check-language-support -l ru`
```

* install ssh:

```bash
apt-get -y install openssh-server
```

* install x11vnc:

```bash
apt-get -y install x11vnc

cat > /usr/bin/x11vncd <<EOT
#!/bin/bash
x11vncd () {
     XAUTH=\`ls -1td /var/run/ldm-xauth-* | head -n1 | sed 's|$|/Xauthority|'\`
     logger -f /var/log/x11vnc "Starting with \$XAUTH"
     /usr/bin/x11vnc -display :7 -rfbauth /etc/x11vnc.pass -logfile /var/log/x11vnc -xauth \$XAUTH 
     sleep 1
     x11vncd
}
x11vncd
EOT

cat > /etc/init.d/x11vnc <<EOT
#!/bin/sh

### BEGIN INIT INFO
# Provides:x11vnc
# Required-Start:\$remote_fs \$syslog
# Required-Stop:\$remote_fs \$syslog
# Default-Start:2 3 4 5
# Default-Stop:0 1 6
# Short-Description:Start X11VNC
# Description:Start VNC server X11VNC at boot
### END INIT INFO

case "\$1" in
        start) 
                start-stop-daemon --start --oknodo --pidfile /var/run/x11vnc.pid --background --nicelevel 15 --make-pidfile --exec /usr/bin/x11vncd
        ;;
        stop)  
                logger -f /var/log/x11vnc "Stopping"
                start-stop-daemon --stop --oknodo --pidfile /var/run/x11vnc.pid
        ;;
        restart)
                logger -f /var/log/x11vnc "Restarting"
                \$0 stop
                \$0 start
        ;;
        status)
                PID=\`cat /var/run/x11vnc.pid\`
                if [ -e /proc/\$PID ]; then
                        echo "Process \$PID is running"
                else   
                        echo "No process matching"
                fi
        ;;
        *)
                echo "Usage: \$0 start|stop|restart|status"
                exit 1
        ;;
esac
exit 0
EOT

chmod +x /usr/bin/x11vncd
chmod 755 /etc/init.d/x11vnc
update-rc.d x11vnc defaults
x11vnc -storepasswd /etc/x11vnc.pass
```
* fix xscreensaver autostart
```bash
cat > /etc/xdg/autostart/xscreensaver.desktop <<EOT
[Desktop Entry]
Type=Application
Exec=/usr/bin/xscreensaver -nosplash
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=xscreenasaver
Name=xscreensaver
Comment[en_US]=
Comment=
EOT
```
