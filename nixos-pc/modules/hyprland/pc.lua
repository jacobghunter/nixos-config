local hs = require("hyprsplit")
hs.monitor_priority({"DP-1", "HDMI-A-1"})

hl.monitor({
    output = "HDMI-A-1",
    mode = "2560x1440@59.95",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DP-1",
    mode = "3440x1440@174.96",
    position = "2560x0",
    scale = 1,
    bitdepth = 10,
    cm = "hdr",
    sdrbrightness = 2,
    sdrsaturation = 1.1,
    sdr_min_luminance = 0.005,
    vrr = 2,
})

hl.config({
    render = {
        direct_scanout = false,
    },
})

