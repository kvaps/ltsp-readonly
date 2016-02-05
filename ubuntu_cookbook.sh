#!/bin/bash

# fix syncing
sed -i '/^CMDLINE_LINUX_DEFAULT.*[^pci=noacpi]"$/ s/"$/ pci=noacpi"/g' /opt/ltsp/amd64/etc/ltsp/update-kernels.conf

# vim
apt-get -y install vim

# skype
sudo add-apt-repository -y "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
sudo apt-get -y update
sudo apt-get -y install skype

# disable amazon and online search
apt-get -y remove unity-lens-shopping

# hide sata disks from nautilus
echo 'ENV{ID_ATA_SATA}=="1" ENV{UDISKS_IGNORE}="1"' >> /etc/udev/rules.d/99-hide-partitions.rules

# enable unity-panel-service
cat > /etc/xdg/autostart/unity-panel-service.desktop <<EOT
[Desktop Entry]
Type=Application
Exec=/usr/lib/unity/unity-panel-service
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=gnome-panel
Name=gnome-panel
Comment[en_US]=
Comment=
EOT

# install russian language
apt-get -y install `check-language-support -l ru`

# install ssh
apt-get -y install openssh-server

# install x11vnc
apt-get -y install x11vnc
cat > /etc/init.d/x11vnc <<EOT
#!/bin/sh

### BEGIN INIT INFO
# Provides:x11vnc
# Required-Start:$remote_fs $syslog
# Required-Stop:$remote_fs $syslog
# Default-Start:2 3 4 5
# Default-Stop:0 1 6
# Short-Description:Start X11VNC
# Description:Start VNC server X11VNC at boot
### END INIT INFO

case "$1" in
        start) 
                sleep 6
                XAUTH=`find /var/run/ldm-xauth* -type f -name Xauthority`
                logger -f /var/log/x11vnc "Starting with $XAUTH"
                start-stop-daemon --start --oknodo --pidfile /var/run/x11vnc.pid --background --nicelevel 15 --make-pidfile --exec /usr/bin/x11vnc -- -display :7 -loop -rfbauth /etc/x11vnc.pass -logfile /var/log/x11vnc -xauth $XAUTH
        ;;
        stop)  
                logger -f /var/log/x11vnc "Stopping"
                start-stop-daemon --stop --oknodo --pidfile /var/run/x11vnc.pid
        ;;
        restart)
                logger -f /var/log/x11vnc "Restarting"
                $0 stop
                $0 start
        ;;
        condrestart)
                PID=`cat /var/run/x11vnc.pid`
                RUNNING=`ps h --ppid $PID`
                if [ "$RUNNING" == "" ]; then
                        logger -f /var/log/x11vnc "No process matching /var/run/x11vnc.pid"
                        echo "No process matching /var/run/x11vnc.pid"
                        $0 restart
                else   
                        logger -f /var/log/x11vnc "Process matching /var/run/x11vnc.pid exists"
                        echo "Process matching /var/run/x11vnc.pid exists - no action taken"
                fi
        ;;
        *)
                echo "Usage: $0 start|stop|restart|condrestart"
                exit 1
        ;;
esac

exit 0
EOT

chmod 755 /etc/init.d/x11vnc
update-rc.d x11vnc defaults
x11vnc -storepasswd /etc/x11vnc.pass
