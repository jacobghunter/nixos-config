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

- Ghostty? Resizes better than kitty

# PC

- obsidian and vscode configs
- kitty split focus follows mouse
- compiling vulkan shaders on all games
- vim keys as arrows for hyprland?
- wayle transparent background?
- disable opacity hotkey?
- set default apps for pdf, rdp, etc
- target certain browser windows like bitwarden to open floating?
  - maybe also steam menus?
- configure vscode with a theme and some base extensions?
- discord screenshare weirdness (new screenshare client?)
- nautilus (gtk) theming as dark mode
- fix super+esc menu
- wayle special workspace highlight + swap on click

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

monitor:

```
To match the brightness of an aging/dimming HDR OLED monitor ( DP-1 ) with a secondary SDR monitor ( HDMI-A-1 ), you want to use a combination of physical hardware
  adjustments on the SDR monitor and software SDR-to-HDR scaling on the OLED.

  Here is the best strategy and configuration workflow to calibrate them:

  ### 1. The Calibration Strategy

  • OLED Monitor (DP-1 in HDR Mode): Keep the physical monitor brightness (OSD) at its default HDR profile (usually locked at 100% or "Peak HDR"). In HDR mode,
  changing the monitor's physical hardware brightness controls will degrade the tone-mapping accuracy for games and videos.
  • SDR Monitor (HDMI-A-1): Treat this as your physical baseline. You will adjust this monitor's hardware brightness (via its OSD buttons or  ddcutil ) to match the
  comfortable screen luminance of your OLED.
  • Hyprland  sdrbrightness : This multiplier controls how bright standard SDR content (like browsers, terminals, text editors) is rendered inside the HDR space on
  DP-1 . You tweak this so a white browser window on the OLED matches the same white window on the SDR monitor.
  ──────
  ### 2. Tweak Steps

  Your monitor configuration is defined in your home.nix file:

	monitorv2 {
            output = DP-1
            mode = 3440x1440@174.96
            position = 2560x0
            scale = 1
            bitdepth = 10
            cm = hdr
            sdrbrightness = 2         # <--- Tweak this value
            sdrsaturation = 1.1
            sdr_min_luminance = 0.005
            vrr = 2
	}

  1. Lower the SDR monitor's physical brightness first: Open a blank white window (like  about:blank  in a browser) on both monitors. Adjust the Dell monitor's
  physical brightness down until it matches the overall brightness of the OLED.
  │ [!WARNING]
  │ Because your OLED is dimming due to age, trying to match it by over-boosting  sdrbrightness  (e.g. setting it above  2.5  or  3.0 ) will cause color
  │ clipping—white
  │ areas will lose detail and look washed out. It is always better to bring the SDR monitor's brightness down to meet the OLED.

  2. Fine-tune with  sdrbrightness :
      • If the white window on the OLED is still dimmer than the SDR monitor, increase  sdrbrightness  in your configuration (e.g. try  2.2  or  2.5 ).
      • If the white window on the OLED is too bright/glaring compared to the SDR monitor, lower  sdrbrightness  (e.g., to  1.5  or  1.7 ).
  3. Run  git add .  and rebuild after editing  home.nix  to apply the new value.
```
