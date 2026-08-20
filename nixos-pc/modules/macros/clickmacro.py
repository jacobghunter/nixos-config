"""Press middle click to toggle spamming left/right clicks and space.

Press middle click again to stop.
"""
import select
import sys
import time

from evdev import InputDevice, UInput, ecodes

DEFAULT_DEVICE = (
    "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse"
)
DEVICE = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_DEVICE
# Seconds between each button activation.
SPAM_INTERVAL = float(sys.argv[2]) if len(sys.argv) > 2 else 0.05
PULSE_HOLD = 0.01  # Seconds a synthetic press stays "down".

TRIGGER_BUTTON = ecodes.BTN_MIDDLE
SPAM_CODES = [ecodes.BTN_LEFT, ecodes.BTN_RIGHT, ecodes.KEY_SPACE]


def pulse(ui: UInput, code: int) -> None:
    ui.write(ecodes.EV_KEY, code, 1)
    ui.syn()
    time.sleep(PULSE_HOLD)
    ui.write(ecodes.EV_KEY, code, 0)
    ui.syn()


def trigger_pressed_again(dev: InputDevice) -> bool:
    r, _, _ = select.select([dev.fd], [], [], 0)
    if not r:
        return False
    for ev in dev.read():
        is_trigger = ev.type == ecodes.EV_KEY and ev.code == TRIGGER_BUTTON
        if is_trigger and ev.value == 1:
            return True
    return False


def main() -> None:
    dev = InputDevice(DEVICE)
    caps = {ecodes.EV_KEY: SPAM_CODES}
    with UInput(caps, name="click-macro-virtual-mouse") as ui:
        for event in dev.read_loop():
            is_toggle_press = (
                event.type == ecodes.EV_KEY
                and event.code == TRIGGER_BUTTON
                and event.value == 1
            )
            if not is_toggle_press:
                continue

            while not trigger_pressed_again(dev):
                for code in SPAM_CODES:
                    pulse(ui, code)
                    time.sleep(SPAM_INTERVAL)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
