# Pistorm'X with bus arbitration for DMA enabled peripherals
While discussing with a fellow PiStorm user on the AmigaFrance Forum, I discovered that peripherals that use Direct Memory Access (DMA) on the Amiga 2000 do not work with the actual PiStorm CPU boards. Having never used a "big box" Amiga myself I did not know about this fact.

Looking at the schematic of the A2000, I believe the CPU board need to support bus arbitration signals (BR, BG, BGACK) in order to float the address and data buses when other devices need them. On the PiStorm'X-68K logic, I used these signals, but as a bus master device in a reverse way to shut the real 68000 when the PiStorm emulator is active. However this means that the signals are available to the CPLD and the logic can be changed to behave like a CPU supporting DMA requests.

The files in this directory are an attempt to add the support of bus arbitration signals to the first PiStorm'X CPU board (not the ones in the Beta directory).
- They are not tested since I don't own an Amiga 2000. If you want to test it yourself on your system, feel free. If you have a spare/unused/broken one and want to make a donation to help the project, I'd be very happy.
- BR, BG, BGACK need to be connected as explained below on the first PiStorm'X board : if not, BR will be floating which will produce unexpected results
- The real 68000 need to be removed from the system/NOT installed on the PiStorm'X. Since the bus arbitrations are used in a normal "CPU way" this leaves now way to shut it down like the PiStorm'X 68K does. Il you install both the real 68K an the PiStorm they will use the bus at the same time, this will not work, and will probably break them.

When this is proven to work, I believe it will be great to build an A2000 CPU board with support to both the DMA devices and the real 68000.

# Experimental status
Pistorm'X is experimental, not yet well tested, and might not work with all system revisions and Pi or 68k software or provide the same performance or feature than the original. That it works for me does not mean that it will work for you. For this reason you are welcome to assemble your own and share test reports in the Discord channel named "beta-testing-pistormx".

Pistorm'X-DMA is even more experimental and untested.

# Making it
The first Pistorm'X board require a few modifications and a new firmware
- Connect the pin in _BG = CPU pin 11 to the solder jumper pad next to FC2 = CPU pin 26
- Connect the pin in _BGACK = CPU pin 12 to the solder jumper pad next to FC1 = CPU pin 27
- Connect the pin in _BR = CPU pin 13 to the solder jumper pad next to FC0 = CPU pin 28
- Pins in FC0 = CPU pin 28, FC1 = CPU pin 27 and FC2 = CPU pin 26 are still not required. If you install them you need to be careful NOT to connect them to the nearby jumper pad.

A board already modded for the PiStorm'X-68K will not need any modification.

Build the firmware using the same settings as the Pistorm'X and flash it on the CPLD using xsvfduino, xc3sprog or your preferred method.
