import Astal from "gi://Astal?version=3.0"
import Gtk from "gi://Gtk?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import Wp from "gi://AstalWp"
import Network from "gi://AstalNetwork"
// import { bind } from "astal" // This needs to be imported differently if using pure GJS without NPM

// Helper for binding since 'astal' NPM package isn't available
function bindProp(obj, prop) {
    // In pure GJS/Astal, bind() is usually available on the object itself via GObject binding or Astal's helper
    // Astal v3 exposes a 'Binding' class but the simple 'bind()' syntax is from the NPM wrapper.
    // For pure GJS, we use GObject signals or Astal's built-in binding if exposed.
    // Let's use standard GObject signal connection for now as a fallback.
    return {
        subscribe: (callback) => {
            const id = obj.connect(`notify::${prop}`, () => callback(obj[prop]))
            callback(obj[prop]) // Initial value
            return () => obj.disconnect(id)
        },
        as: (transform) => ({
             subscribe: (callback) => {
                 const id = obj.connect(`notify::${prop}`, () => callback(transform(obj[prop])))
                 callback(transform(obj[prop]))
                 return () => obj.disconnect(id)
             }
        })
    }
}

// Volume Widget
function Volume() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker
    if (!speaker) return new Gtk.Box({})

    const box = new Gtk.Box({
        className: "volume",
    })
    
    const icon = new Gtk.Image()
    bindProp(speaker, "volume-icon").subscribe(iconName => icon.iconName = iconName)

    const slider = new Gtk.Scale({
        hexpand: true,
        drawValue: false,
        orientation: Gtk.Orientation.HORIZONTAL,
    })
    
    bindProp(speaker, "volume").subscribe(v => slider.set_value(v))
    slider.connect("value-changed", () => speaker.volume = slider.get_value())

    box.add(icon)
    box.add(slider)
    
    return box
}

// Wifi Widget
function Wifi() {
    const network = Network.get_default()
    const wifi = network.wifi
    if (!wifi) return new Gtk.Box({})

    const box = new Gtk.Box({
        className: "wifi",
    })

    const icon = new Gtk.Image()
    bindProp(wifi, "icon-name").subscribe(iconName => icon.iconName = iconName)

    const label = new Gtk.Label()
    bindProp(wifi, "ssid").subscribe(ssid => label.label = String(ssid))

    const toggle = new Gtk.Switch()
    bindProp(wifi, "enabled").subscribe(enabled => toggle.set_active(enabled))
    toggle.connect("notify::active", () => wifi.enabled = toggle.get_active())

    box.add(icon)
    box.add(label)
    box.add(toggle)

    return box
}

export default function QuickSettings(app) {
    const win = new Astal.Window({
        name: "quicksettings",
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
        exclusivity: Astal.Exclusivity.NORMAL,
        keymode: Astal.Keymode.ON_DEMAND,
        application: app,
        visible: false,
    })

    const container = new Gtk.Box({
        vertical: true,
        className: "qs-container",
    })

    container.add(Wifi())
    container.add(Volume())

    win.add(container)

    return win
}
