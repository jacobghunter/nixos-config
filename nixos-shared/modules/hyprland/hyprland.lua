---@module 'hl'

-- #######################################################################################
-- HYPRLAND LUA CONFIGURATION
-- #######################################################################################

--################
--## PLUGINS   ###
--################

-- Add your plugins folder to the Lua package path
package.path = package.path .. ";/home/jacob/.config/hypr/?.lua;/home/jacob/.config/hypr/plugins/?/init.lua;/home/jacob/.config/hypr/plugins/?.lua"

-- Load and setup the split-monitor-workspaces plugin natively
local smw = require("split-monitor-workspaces")
smw.setup({
    workspace_count = 10,
    keep_focused = false,
    enable_notifications = false,
    enable_persistent_workspaces = true,
})

--######################
--## IMPORT NIX VARS ###
--######################

local vars = require("nix-vars")

--##################
--## MY PROGRAMS ###
--##################

-- You can change these to use vars.terminal etc., if you added them to your nix-vars.lua
local terminal = "kitty"
local fileManager = "nautilus"
local menu = "rofi -show drun -show-icons"
local browser = "firefox"
local notes = "obsidian"
local editor = "code"
local editor_alt = "subl"
local colorPicker = "hyprpicker"

--############################
--## ENVIRONMENT VARIABLES ###
--############################

-- Firefox
hl.env("MOZ_ENABLE_WAYLAND", 1)

-- QT
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", 1)
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", 1)
hl.env("QT_STYLE_OVERRIDE", "kvantum")

-- Toolkit Backend Variables
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- XDG Specifications
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Gnome toolkit
hl.env("GTK_THEME", "Adwaita:dark")

--####################
--## LOOK AND FEEL ###
--####################

hl.config({
    general = {
        gaps_in = 2.5,
        gaps_out = 5,
        border_size = vars.borderSize, -- Injected from Nix
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
        col = {
            active_border = { colors = vars.activeBorderColors, angle = vars.activeBorderAngle },
            inactive_border = vars.inactiveBorder,
        },
    },
})

hl.config({
    decoration = {
        rounding = vars.rounding, -- Injected from Nix
        rounding_power = 2,
        active_opacity = 0.9,
        inactive_opacity = 0.85,
        blur = {
            enabled = true,
            size = 4,
            passes = 3,
            new_optimizations = true,
            vibrancy = 0.1696,
            ignore_opacity = true,
            xray = true,
        },
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 0,
        initial_workspace_tracking = 1,
        animate_manual_resizes = true,
    },
})

--############
--## INPUT ###
--############

hl.config({
    input = {
        kb_layout = "us",
        kb_options = "caps:super",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.config({
    gestures = {
        gesture = { 3, "horizontal", "workspace" },
    },
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

--##################
--## KEYBINDINGS ###
--##################

local mainMod = "SUPER"

-- --- Row 1 (Numbers) ---
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- --- Row 2 (Q W E R T Y U I O P) ---
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(notes))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(colorPicker .. " | wl-copy"))

-- --- Row 3 (A S D F G H J K L) ---
hl.bind(mainMod .. " + A", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("/home/jacob/.config/hypr/scripts/toggle_special.sh"))
hl.bind(mainMod .. " + CTRL + A", hl.dsp.exec_cmd("/home/jacob/.config/hypr/scripts/toggle_workspace_special.sh"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("systemctl suspend"))

-- --- Row 4 (Z X C V B N M) ---
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | tofi -c ~/.config/tofi/configV | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + M", hl.dsp.exit())

-- --- Special Keys & Mouse ---
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("wlogout"))
hl.bind("CTRL + Escape", hl.dsp.exec_cmd("killall waybar || waybar"))
hl.bind(mainMod .. " + space", hl.dsp.window.float())
hl.bind(mainMod .. " + SHIFT + space", hl.dsp.window.center())

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move window position with mainMod + SHIFT + arrow keys
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Switch workspaces with mainMod + mouse side buttons (back/forward)
hl.bind(mainMod .. " + mouse:275", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:276", hl.dsp.focus({ workspace = "e+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize windows with mainMod + CTRL + arrow keys (Fixed by passing dispatch direct to exec)
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 30 0"), { repeat_bind = true })
hl.bind(mainMod .. " + CTRL + Left", hl.dsp.exec_cmd("hyprctl dispatch resizeactive -30 0"), { repeat_bind = true })
hl.bind(mainMod .. " + CTRL + Up", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -30"), { repeat_bind = true })
hl.bind(mainMod .. " + CTRL + Down", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 30"), { repeat_bind = true })

-- Screenshot 
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("SUPER + ALT + Print", hl.dsp.exec_cmd("hyprshot -m output"))

-- Volume and Media Control (Fixed repeat flags)
hl.bind(mainMod .. " + F11", hl.dsp.exec_cmd("/home/jacob/.config/hypr/scripts/toggle_audio.sh"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeat_bind = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeat_bind = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeat_bind = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeat_bind = true })

--#############################
--## WINDOWS AND WORKSPACES ###
--#############################

-- GNOME Calendar Rules (Fixed syntax)
hl.window_rule({
    match = { class = "org.gnome.Calendar" },
    float = true,
    center = true,
    size = "800 650",
})

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("ags")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprlock")
end)