# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Use /tmp/$USER as $HOME, symlink configs.
if [ -z $OLD_HOME ]; then
    export OLD_HOME=$HOME
    export HOME=/tmp/$USER
    mkdir -p $HOME
    find $OLD_HOME -type f -exec sh -c '
        path=`echo "$@" | sed "s|$OLD_HOME||g"`
        mkdir -p `dirname ${HOME}${path}`
        ln -s ${OLD_HOME}${path} ${HOME}${path}' _ {} \;
fi

cd $HOME


# Disable Mic listening, enable mic in Pulse
amixer -q set 'Mic' 0
amixer -q set Capture toggle 100

# Change keyboard
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Ctrl>Shift_L', '<Ctrl>>Shift_R', '<Shift>Control_L', '<Shift>Control_R']"
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"

# Disable sticky edges
dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-capture-mouse false

# Disable shortcut keys hint
dconf write /org/compiz/profiles/unity/plugins/unityshell/shortcut-overlay false


## Disable online search
#gsettings set com.canonical.Unity.Lenses remote-content-search 'none'
#
## Disable /dev/sda from unity
#blocked_devices=$(
#    for i in `ls /dev/disk/by-uuid/*`; do
#        if [[ `readlink $i` == *"/sda"* ]] ; then
#            named=false
#            for j in `ls /dev/disk/by-label/*`; do
#                if [[ `readlink $j` == *"/sda"* ]] ; then
#                     if [[ `readlink $i` == `readlink $j` ]] ; then
#                          echo -en "'`basename $i`-`basename $j`', "
#                          named=true
#                     fi
#                fi
#            done
#            if [ "$named" = false ] ; then
#                 echo -en "'`basename $i`-', "
#            fi
#        fi
#    done
#)
#blocked_devices=` echo $blocked_devices | sed 's/,$//'`
#gsettings set com.canonical.Unity.Devices blacklist "[ $blocked_devices ]"

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
