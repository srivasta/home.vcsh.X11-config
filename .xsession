#!/bin/zsh
# $XConsortium: xinitrc.cpp,v 1.4 91/08/22 11:41:34 rws Exp $
#This is what we have added to our .xinitrc files in our group:
#
#     xmodmap -e 'keysym BackSpace = Delete'  #remap the backspace key
#
#which makes the backspace key to result in the same code as the delete key;
#and in our .login files we have
#
#     stty erase '^?'
#
#to ensure that the delete key is the erase "function".
#
#This seems to be working fine for us.  The backspace key is in the natural
#place for "delete" on a Sun type 5 keyboard (AT 101 like) so everything works
#comfortably in a "regular" window and no "stupid" help command is issued
#in emacs when the backspace key is hit by force of habit.
#If we need the original backspace "code" we just type Ctrl-h.
#
# ssh -X 192.168.1.20 "x2x -north -to :0.0"
#
# Xephyr :1 -ac -screen 1650x1024 &
# DISPLAY=:1 FVWM_USERDIR=~/tmp/fvwm /usr/bin/fvwm2 &
#

# set -x

#nxhost+
# Merge in defaults and keymaps
umask 022
export default_dir=${default_dir:=$HOME}
export ZDOTDIR=${ZDOTDIR:=$default_dir/etc/shells/zsh}
export default_bashdir=${default_bashdir:=$default_dir/etc/shells/bash}


# This makes X work when I su to root.
if [ -z "$XAUTHORITY" ]; then
        XAUTHORITY=$default_dir/.Xauthority
        export XAUTHORITY
fi

#sudo setkeycodes e02c 159
#sudo setkeycodes e025 179
#sudo setkeycodes e026 180

XAPPLRESDIR=$default_dir/etc/X11/app-defaults/
export XAPPLRESDIR

export userresources=$default_dir/etc/X11/Xresources
if [ -e $default_dir/etc/X11/xmodmap-$(uname -n) ]; then
  export usermodmap=$default_dir/etc/X11/xmodmap-$(uname -n)
fi


export sysresources=/usr/lib/X11/xdm/.Xresources
export sysmodmap=/usr/lib/X11/.Xmodmap

export JAVA_HOME=/usr/lib/jvm/java-6-sun
# load common variables
if [ -n "$BASH_VERSION" ]; then
	if test -f "$default_bashdir/bash_vars" ; then
		. "$default_bashdir/bash_vars"
	fi
elif [ -n "$ZSH_VERSION" ]; then
  if [ -f $ZDOTDIR/variables ]; then
		source $ZDOTDIR/variables
	fi
fi


if [ ! $DISPLAY ] || [ $DISPLAY = ":0.0" ]; then
     DISPLAY=$(hostname):0
fi

if [ -f "$sysresources" ]; then
    xrdb -merge "$sysresources"
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f $userresources ]; then
    xrdb -merge $userresources
fi

if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

for i in ${XAPPLRESDIR}*; do xrdb -merge $i; done

if [ -e "$default_dir/etc/X11/xbindkeysrc-$(uname -n)" ]; then
    export userbindings=$default_dir/etc/X11/xbindkeysrc-$(uname -n)
    xbindkeys -f $userbindings
fi

setxkbmap -option terminate:ctrl_alt_bksp

##
## # set +x
## # would ssh-agent die at termination?
if [ -x /usr/bin/ssh-agent ] ; then
  if [ -z ${SSH_AGENT_PID} ] ; then
    if test -f $default_dir/lib/.sec/ssh-agent-info && \
        kill -0 $(cat $default_dir/lib/.sec/ssh-agent-info) 2>/dev/null; then
        SSH_AGENT_PID=$(cat $default_dir/lib/.sec/ssh-agent.pid)
        SSH_AUTH_SOCK=$(cat $default_dir/lib/.sec/ssh-agent.info)
    else
        unset SSH_AUTH_SOCK
        unset SSH_AGENT_PID
        rm $default_dir/lib/.sec/ssh-agent.pid
        rm $default_dir/lib/.sec/ssh-agent.info
        #eval $(ssh-agent -a $default_dir/var/run/agent-$$ )
        eval $(ssh-agent)
        echo $SSH_AUTH_SOCK > $default_dir/lib/.sec/ssh-agent.info
        echo $SSH_AGENT_PID > $default_dir/lib/.sec/ssh-agent.pid
    fi
    export SSH_AUTH_SOCK
    export SSH_AGENT_PID
  fi
fi

ssh-add -D
ssh-add </dev/null
#ssh-add /home/srivasta/.ssh/id_dsa </dev/null
#ssh-add /home/srivasta/.ssh/id_rsa </dev/null

if [ -x /usr/bin/gpg-agent ] ; then
  if test -f $default_dir/lib/.sec/gpg-agent-info && \
    kill -0 $(cut -d: -f 2 $default_dir/lib/.sec/gpg-agent-info) 2>/dev/null; then
      GPG_AGENT_INFO=$(cat $default_dir/lib/.sec/gpg-agent-info)
  else
    eval $(gpg-agent --daemon)
    echo $GPG_AGENT_INFO >$default_dir/lib/.sec/gpg-agent-info
  fi
  export GPG_AGENT_INFO
fi

# if [[ -x /usr/bin/gpg-agent ]]; then
#     if [[ -r "${GNUPGHOME}/gpg-agent-info" ]] &&                            \
#         if kill -0 $(grep GPG_AGENT_INFO "${GNUPGHOME}/gpg-agent-info"  |   \
#                   cut -d: -f 2 ); then
#         . "${GNUPGHOME}/gpg-agent-info"
#     else
#         ssh-add -D 2>/dev/null || true
#         eval $(gpg-agent --daemon --enable-ssh-support                     \
#                  --write-env-file "${GNUPGHOME}/gpg-agent-info")
#     fi
#     export GPG_AGENT_INFO
#     export SSH_AUTH_SOCK
#     export SSH_AGENT_PID
# fi


# As root, invoke ssh with:
# ssh -C -o "CompressionLevel 9" -L 119:news.iglou.com:119 iglou.com
# and use the local nntp server
xset -c b 95 s default &

#xset -p /usr/lib/X11/fonts/100dpi/
#xset +fp /usr/X11R6/lib/X11/fonts/misc/
#xset +fp /usr/X11R6/lib/X11/fonts/tex/
#xset +fp /usr/lib/X11/fonts/100dpi/

### xfontsel -pattern "-*-*-*-*-*-tt-*-*-*-*-*-*-*-*"

#if [ -d /usr/local/share/emacs/fonts/ ]; then
#   xset fp+ /usr/local/share/emacs/fonts/
#fi
#if [ -d /usr/share/fonts/truetype -a -x /usr/bin/X11/xfstt ]; then
#   xset fp+ unix/:7101
#fi
#xset fp rehash
#if [ -x /etc/init.d/xprint ]; then
#  export XPSERVERLIST="$(/etc/init.d/xprint get_xpserverlist)"
#fi

#xwrits +clock multiply=5:1.4 +iconified +idle  +beep +breakclock +lock &

## xautolock -notify 10 -bell 35 -corners +--0 -cornerdelay 5 &
## xautolock -disable&
## nice xautolock -time 3 -bell 35 -corners ++++ -cornerdelay 5 -cornersize 50 -locker 'gnome-screensaver-command -a' &

#xearth -pos 42.22.41 -77.75 #-orbit 51.6 234.8
##xearth -label -grid -pos orbit,1,41.67 -fork
#tvtwm -s &
#xvtdl  &
#nice xcb -l v -geometry 200x500-0+365 &

#nice sunclock -placement SE -clock -mapgeom -10+180 -clockgeom +1262+795 &
#nice sunclock -placement SE -clock -mapgeom -10+180 -clockgeom +1140+780 &
#nice wmbattery -g +963+548 &
#nice sunclock -placement SE -clock -mapgeom -10+180 -clockgeom +1320+945 -setfont 'menu|-bitstream-bitstream vera sans mono-medium-r-normal--17-120-100-100-m-*-*-*' -setfont 'coord|-bitstream-bitstream vera sans mono-medium-r-normal--17-120-100-100-m-*-*-*' -setfont 'mapstrip|-bitstream-bitstream vera sans mono-medium-r-normal--17-120-100-100-m-*-*-*' -setfont 'clockstrip|6x13' -setfont 'city|6x13' &
# nice sunclock -placement SE -clock -mapgeom -10+180 -clockgeom -0+945 -setfont 'menu|-bitstream-bitstream vera sans mono-medium-r-normal--17-120-100-100-m-*-*-*' -setfont 'coord|-bitstream-bitstream vera sans mono-medium-r-normal--17-120-100-100-m-*-*-*' -setfont 'mapstrip|-bitstream-bitstream vera sans mono-medium-r-normal--17-120-100-100-m-*-*-*' -setfont 'clockstrip|6x13' -setfont 'city|6x13' &

nice -n 19 gkrellm -g -1+171  > /dev/null 2>&1  &
#nice wmbattery -g +1535+975 &
#nice gkrellm -g +1450+190  > /dev/null 2>&1 &
#nice wmbattery -g +1400+975 &
#nice gkrellm -g -0+0  > /dev/null 2>&1 &

#xscreensaver-command -exit
#xscreensaver &

# 229 BRANDON LN
# WOODBURY, TN 37190-5239
#Lat:   35.83781   35:50:15.73N
#Lon: -086.07752   86:04:38.67W
# FIPS County..: TN015
# Tract........: TN015960100
# BlockGroup...: TN0159601002
# FIPS Place...:
# FIPS MCD.....: TN92472
# MSA..........:



#
# Mobile, Mobile Regional Airport
# 30-41-18N    088-14-44W (dms)
# Station Elevation (Ha): 66 Meters
#
# 11350 Howell's Ferry Road,
# Semmes AL 36575-6600
#       Decimal Degrees Deg:Min:Sec
# Lat:   30.75627778     30:45:22.6N
# Lon: -088.31158333     88:18:41.7W
#
#

##    Amherst, MA
##    0 Amherst
##    1 25015 Hampshire
##    2 MA Massachusetts
##    3 US United States
##    F 45 Populated place
##    L 42 22 25 N  72 31 15 W
##    P 17773
##    E 320
##    Z 01002 01003 01004 01059


nice pland -k &
#xicon &
#nice xbattbar &

# Get the dctrl icon in place
#if [ `hostname` == "glaurung" ]; then
#    xauth extract - glaurung:0 | ssh tiamat /usr/bin/X11/xauth merge -
#    ssh tiamat 'DISPLAY=glaurung:0 dctrl -cw -iconic & '
#fi

#nice xmultibiff -geometry 370x20 -bg Gray17 -fg CornSilk -mail ~/var/spool/mail/{important,admin,gcif,gcifcases,digital,debian.spool,consult,bcast} &
#nice xwalld &

#export TZ=$(cat /etc/timezone)
export LC_ALL="en_US.UTF-8"
export LC_TYPE="en_US.UTF-8"
export FVWM_USERDIR=$default_dir/etc/X11/fvwm

(nautilus -q && nice nautilus --no-desktop) &
# Start some shelltools and the window manager
if test -x /usr/bin/fvwm2; then
    #fvwm2 -f "FvwmM4 -m4prog /usr/bin/m4 .fvwm2rc" &
    #TZ=$(cat /etc/timezone) /usr/bin/fvwm2 &
    /usr/bin/fvwm2 &
elif [ -x /usr/bin/fvwm ]; then
   # LC_ALL="en_US.UTF-8" TZ=$(cat /etc/timezone) /usr/bin/fvwm &
   /usr/bin/fvwm &
elif [ -x /usr/bin/X11/twm ]; then
   #LC_ALL="en_US.UTF-8" TZ=$(cat /etc/timezone) /usr/bin/X11/twm &
   /usr/bin/X11/twm &
fi

# xcompmgr -c -C -F -f &
# transset-df 0.5
# xkeycaps -kbd ms104 &

uxterm -name console -geometry \=78x5+2748+176 &
uxterm  -iconic +ai -ut -T Work1 -fg Snow -bd GoldenRod -bg Black -geometry \=122x52+915+170 &
#emacs --iconic --geometry =93x77+0+0 --xrm "*Page:0 2 2" --title Primary&
#emacs --daemon --no-splash --title Primary&

# exec /usr/bin/gnome-session --session=fvwm &
# gnome-panel &
exec uxterm -ut -T login -n login -bg Black -fg LightSteelBlue -geometry 80x24+10+93 -ls -xrm "*Desk:1"
