#!/bin/bash
set -e

# bwrap (bubblewrap) is required.

qutebrowser="/usr/bin/qutebrowser"

if ! command -v bwrap >/dev/null; then
    exec "$qutebrowser"
fi

mkdir -p "$XDG_RUNTIME_DIR"/qutebrowser/

flags=(
    # env:
    --clearenv
    # basic
    --setenv PATH /usr/bin --setenv USER "$USER" --setenv HOME ~
    # x11
    --setenv DISPLAY "$DISPLAY"
    # fcitx
    --setenv DBUS_SESSION_BUS_ADDRESS "$DBUS_SESSION_BUS_ADDRESS"
    --setenv QT_IM_MODULE "$QT_IM_MODULE" --setenv GTK_IM_MODULE "$GTK_IM_MODULE" --setenv XMODIFIERS "$XMODIFIERS"
    # app
    --setenv SANDBOXED_QUTEBROWSER 1
    # app
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
    # lib and bin
    --ro-bind /usr /usr --ro-bind /lib64 /lib64 --ro-bind /bin /bin
    # proc, sys, dev
    --proc /proc
    --ro-bind /sys /sys
    --dev /dev
    # for webgl
    --dev-bind /dev/dri/ /dev/dri/
    # font and network
    --ro-bind /etc/fonts/ /etc/fonts/ --ro-bind /etc/resolv.conf /etc/resolv.conf
    # fcitx and network
    --ro-bind /run/user/"$UID"/bus /run/user/"$UID"/bus --ro-bind /run/systemd/resolve/ /run/systemd/resolve/
    # x11
    --ro-bind ~/.Xauthority ~/.Xauthority
    # sound (pulseaudio)
    --ro-bind /run/user/"$UID"/pulse /run/user/"$UID"/pulse
    # it throws warning. so add it.
    --ro-bind /run/dbus/system_bus_socket /run/dbus/system_bus_socket
    # app
    --bind "$XDG_RUNTIME_DIR"/qutebrowser/ "$XDG_RUNTIME_DIR"/qutebrowser/
    # bind ~/.config/qutebrowser as rw is required, otherwise quickmark will fail.
    --bind ~/.config/qutebrowser/ ~/.config/qutebrowser/
    --ro-bind ~/.config/qutebrowser/config.py ~/.config/qutebrowser/config.py
    --ro-bind ~/.config/qutebrowser/userscripts/ ~/.config/qutebrowser/userscripts/
    # if rc.py is available, then mount it.
    --ro-bind ~/.config/qutebrowser/rc.py ~/.config/qutebrowser/rc.py
    # use separate history.
    --bind ~/.local/share/qutebrowser-box/ ~/.local/share/qutebrowser/
    # app
    --bind ~/Downloads/ ~/Downloads/
    # app
    --ro-bind ~/html/ ~/html/
    --ro-bind ~/.vimrc ~/.vimrc --ro-bind ~/vimfiles/ ~/vimfiles/
)

exec bwrap "${flags[@]}" -- "$qutebrowser" "$@"
