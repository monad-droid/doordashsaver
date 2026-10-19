# DoorDash Saver

An [AWTRIX NG](https://blueforcer.github.io/awtrix-ng/) app for the Ulanzi TC001 pixel clock that shows how much money you've saved this month by not ordering DoorDash.

```
 🐷  417.60
 ▔▔▔▔▔▔▔▔▔▔▔  ← month progress bar
```

A pink piggy bank (with a gold coin) on the left, the month-to-date total in green on the right.

## How the number works

```
saved = monthly average ÷ days in this month × today's date
```

With a $681.34 monthly average:

| Date   | Shows  |
|--------|--------|
| Oct 1  | 21.98  |
| Oct 19 | 417.60 |
| Oct 31 | 681.34 |
| Nov 1  | 22.71 (starts over; November has 30 days) |

It runs entirely on the clock. No computer or server needs to stay on.

## Install

1. Flash the clock with AWTRIX NG and connect it to Wi‑Fi ([install guide](https://blueforcer.github.io/awtrix-ng/esp32/getting-started/flashing/)).
2. In the clock's web UI, **set your time zone**. It defaults to Central European Time, which makes the day roll over at the wrong hour. For US Eastern use `EST5EDT,M3.2.0,M11.1.0`.
3. Open **Scripts**, create a script named `DoorDashSaved`, paste in [`DoorDashSaved.be`](DoorDashSaved.be), and save.
4. Press the right button on the clock to skip to it in the rotation.

## Settings

In the web UI under **Apps**, press ⚙ on the `DoorDashSaved` row:

- **Monthly average**: your average monthly DoorDash spend (default 681.34)
- **Number color**: default green
- **Month progress bar**: on/off

## Flashing tips

If the browser installer fails partway through with *"Serial data stream stopped"* or the clock is left black and squealing:

- The squeal is normal while the chip has no working firmware; it stops once an install completes.
- Random dropouts mean the USB link is cutting out. Try a different cable and port, plug straight into the computer (no hub), and keep the clock still.
- Use Chrome, and close any other tab that has the installer open.
- As a fallback, flash from a terminal at a slower speed with [esptool](https://github.com/espressif/esptool), using the full image from the release's `usb-awtrix-ng.zip` (the TC001 is an ESP32 with 4 MB flash):

  ```bash
  esptool.py --chip esp32 --port /dev/cu.usbserial-XXX --baud 115200 erase_flash
  esptool.py --chip esp32 --port /dev/cu.usbserial-XXX --baud 115200 write_flash 0x0 usb-awtrix-ng-4mb.bin
  ```
