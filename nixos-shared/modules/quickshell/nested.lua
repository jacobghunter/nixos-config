-- Add standard user paths to package.path so require("variables") and require("hyprsplit") work
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/hypr/?.lua;" .. os.getenv("HOME") .. "/.config/hypr/?/init.lua"

-- Stub/Override hl.exec_cmd to disable host apps, systemd targets, and C++ plugin loading in the nested session
local real_exec_cmd = hl.exec_cmd
hl.exec_cmd = function(cmd)
    if cmd:find("ags") or cmd:find("hypridle") or cmd:find("hyprlock") or cmd:find("waybar") or cmd:find("wayle") or cmd:find("systemctl") or cmd:find("hyprland%-session") or cmd:find("plugin load") then
        print("[Nested] Ignoring session/systemd/plugin command: " .. cmd)
        return
    end
    print("[Nested] Running command: " .. cmd)
    real_exec_cmd(cmd)
end

-- Stub hl.bind to translate SUPER bindings to ALT inside the nested session
-- This allows you to interact with the sandbox using ALT, while host OS uses SUPER
local real_bind = hl.bind
hl.bind = function(mod, key, handler)
    local new_mod = mod
    if mod == "SUPER" then
        new_mod = "ALT"
    elseif mod == "SUPER_SHIFT" then
        new_mod = "ALT_SHIFT"
    end
    real_bind(new_mod, key, handler)
end

-- Stub require to skip host-specific monitor configs (pc, laptop) which disable WAYLAND-1
local real_require = require
require = function(name)
    if name == "pc" or name == "laptop" then
        print("[Nested] Skipping host-specific monitor config: " .. name)
        return {}
    end
    return real_require(name)
end

-- Load the main Hyprland configuration
local main_config_path = os.getenv("HOME") .. "/.config/hypr/hyprland.lua"
print("[Nested] Loading main configuration from: " .. main_config_path)
dofile(main_config_path)

-- Define a monitor rule for the nested Wayland output to make it 1080p
-- This must be declared using the official hl.monitor function
hl.monitor({
    output = "WAYLAND-1",
    mode = "1920x1080",
    position = "0x0",
    scale = 1
})

-- Launch quickshell on startup using nix run --offline to avoid environment path pollution
hl.on("hyprland.start", function()
    local qml_path = os.getenv("QUICKSHELL_QML") or (os.getenv("HOME") .. "/nixos-config/nixos-shared/modules/quickshell/shell.qml")
    print("[Nested] Launching quickshell with: " .. qml_path)
    real_exec_cmd("nix run --offline nixpkgs#quickshell -- -p " .. qml_path)
end)
