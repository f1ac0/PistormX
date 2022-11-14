# Pistorm'X together with a 68000 chip ?!
Installing a fast Amiga accelerator breaks compatibility with original games and demos. Users of these devices such as the Pistorm are forced to rely on WHDload, or to have another Amiga on their desk to have access to these many legacy softwares.

The Pistorm'X-68k is now the solution to boot either the Pistorm or the original 68000 CPU inside one single machine.

Power on and boot using the Pistorm. Maintain a long reset and the Amiga will now boot using the 68k.

The Pistorm'X was created in 2021 as a replacement CPU board for the Pistorm, using less components, a cheaper PCB, easier to assemble, and freeing a GPIO pin on the Pi. Since they were more robust and lower profile, I used the same female pins as my A500-IDE-RAM board to attach the board to the host motherboard. I also broke out a few unused signals on solder jumpers. Along with a new firmware, these make it possible to modify existing Pistorm'X boards to host the DIP 68000/68010 !

To make room for the huge clock counter required to time the long reset, the double write buffering has been removed from this firmware, which is base on the "4 states cycle".

# Experimental status
Pistorm'X is experimental, not yet well tested, and might not work with all system revisions and Pi or 68k software or provide the same performance or feature than the original. That it works for me does not mean that it will work for you. For this reason you are welcome to assemble your own and share test reports in the Discord channel named "beta-testing-pistormx".

Pistorm'X-68k is even more experimental. Few things still need some additional work :
- EMU68 actually need a reset after cold power on ;
- when no SD-card installed the bus is requested instead of leaving the 68K do its business
- New boards layouts should follow after all quirks have been removed

# Making it
The Pistorm'X board require a few modifications and a new firmware ! Do not plug a 68k unless these mods have been completed !
- Install the Pi socket as high as possible : it is possible to gain 1 to 2 millimetres this way, otherwise the USB port touching the top of the 68000 will prevent to seat the Pi correctly and may lead to bad contacts problems.
- Install a pulldown on _BG = CPU pin 11 through a ~20K resistor to GND = CPU pin 16 or 53
- Install a pullup on E = CPU pin 20 through a 100~200K resistor to VCC = CPU pin 14
- Connect the pin in _BG = CPU pin 11 to the solder jumper pad next to FC2 = CPU pin 26
- Connect the pin in _BGACK = CPU pin 12 to the solder jumper pad next to FC1 = CPU pin 27
- Connect the pin in _BR = CPU pin 13 to the solder jumper pad next to FC0 = CPU pin 28
- Install a pin in the BERR hole = CPU pin 22 : it is not used by the Pistorm however the 68k require the pullup provided by the motherboard.
- Pins in FC0 = CPU pin 28, FC1 = CPU pin 27 and FC2 = CPU pin 26 are still not required. If you install them you need to be careful NOT to connect them to the nearby jumper pad.

Build the firmware using the same settings as the Pistorm'X and flash it on the CPLD using xsvfduino, xc3sprog or your preferred method. However I recommend to install a 68K only after it has been updated and modified successfully.

# Using it
When the Pi is installed with a suitable emulator, the system should cold-boot using the Pistorm. Maintain the reset during at least 10 seconds to toggle to the 68000. Long reset again to go back to the Pistorm.
