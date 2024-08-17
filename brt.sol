 I want to add my solution for Wayland using the device quirks of libinput, see https://wayland.freedesktop.org/libinput/doc/latest/device-quirks.html#device-quirks. I have Fedora 38 with the default GNOME environment, laptop MSI Modern 14 C7M-081CZ.

The previous answers inspired it, so just to be complete, you can list your devices using sudo libinput list-devices whose output will output something containing

Device:           Video Bus
Kernel:           /dev/input/event7
Group:            1
Seat:             seat0, default
Capabilities:     keyboard 
Tap-to-click:     n/a
Tap-and-drag:     n/a
Tap drag lock:    n/a
Left-handed:      n/a
Nat.scrolling:    n/a
Middle emulation: n/a
Calibration:      n/a
Scroll methods:   none
Click methods:    none
Disable-w-typing: n/a
Disable-w-trackpointing: n/a
Accel profiles:   n/a
Rotation:         0.0
You can also watch all events using sudo libinput debug-events. The actual brightness buttons will output as

 event2   KEYBOARD_KEY            +13.879s  KEY_BRIGHTNESSDOWN (224) pressed
 event2   KEYBOARD_KEY            +13.925s  KEY_BRIGHTNESSDOWN (224) released
 event2   KEYBOARD_KEY            +14.324s  KEY_BRIGHTNESSUP (225) pressed
 event2   KEYBOARD_KEY            +14.368s  KEY_BRIGHTNESSUP (225) released
The 'fake' ones would look similar but have a different event number.

I have the libinput quirks files in /usr/share/libinput/ so I have created a new one:

[tomtom@fedora libinput]$ cat 10-generic-keyboard_video.quirks 
[Video Bus Spooky Ghost]
MatchName=*Video Bus*
AttrEventCode=-EV_KEY:0xE0;-EV_KEY:0xE1;
Not sure if a restart is needed or how to make it work immediately.

If set up correctly, the quirks associated with the specific event will be printed using libinput quirks list /dev/input/event<number>:

[tomtom@fedora libinput]$ libinput quirks list /dev/input/event3
AttrEventCode=-KEY_BRIGHTNESSDOWN;-KEY_BRIGHTNESSUP;
In the opposite case, sudo libinput list-devices would print a warning/error at the beginning of its output.      
  Found on `https://askubuntu.com/questions/777754/brightness-randomly-up-and-down-on-msi-laptop`
