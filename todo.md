- theme zellij and neovim?
- outline special workspace differently

- set up server as binary cache
  - have laptop send things to be built there?
  - let PC build its own stuff

# Shell

- copy last command output?

# Repo management

- move all the shared/modules to shared/graphical/modules and put neovim in its own modules folder

# Apps

- ~~Ghostty? Resizes better than kitty~~

# Hyprland

- ~~Fix mouse forward and back to stick to the same monitor~~
- have 1-3 on monitor 1 and 4-6 on monitor 2 instead of 1-5 and 6-10
- configure it so the laptop config isnt bad
- tweak hyprglass
- install more plugins from here: https://github.com/szymon420699/awesome-hyprland-420

# PC

- obsidian and vscode configs
  - configure vscode with a theme and some base extensions? (nix linting via nixd too)
- compiling vulkan shaders on all games
- vim keys as arrows for hyprland?
- wayle transparent background?
- disable opacity hotkey?
- set default apps for pdf, rdp, etc
- target certain browser windows like bitwarden to open floating?
  - maybe also steam menus?
- nautilus (gtk) theming as dark mode
- fix super+esc menu
- wayle special workspace highlight + swap on click
- KDE connect for easy sending of files/text? for laptop, phone, and pc

# Books

- calibre backups to server and sync for pc/laptop?

kef swap to usb:

```
The Local API Bypass

If waiting 20 minutes for standby isn't viable and you want to bypass the phone app entirely, you can force the switch over your local network using the speakers' REST API.

The easiest way to do this is with the pykefcontrol Python library. You can drop a quick script into your environment and bind it to a hyprland.conf shortcut or a ZMK macro, allowing you to instantly swap to the USB-C feed without moving your hands from the keyboard.

First, assign a static IP to your speakers in your router, then use a script like this:
Python

from pykefcontrol.kef_connector import KefConnector

# Replace with your speaker's reserved IP address
speaker = KefConnector("192.168.1.X") 

# Instantly forces the input switch
speaker.source = "usb" 

Want me to map out how to package pykefcontrol into a Nix flake?
```