import Astal from "gi://Astal?version=3.0"
import Gtk from "gi://Gtk?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import QuickSettings from "./widget/QuickSettings.js"

const App = new Astal.Application({
    instance_name: "ags",
})

App.connect("activate", () => {
    try {
        const css_provider = new Gtk.CssProvider()
        css_provider.load_from_path("./style.css")
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        QuickSettings(App)
    } catch (e) {
        logError(e)
    }
})

App.run(null)