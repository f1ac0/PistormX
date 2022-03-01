# Pistorm'X firmwares for the original Pistorm CPU board
If you don't know about Pistorm, the MC68000 CPU replacement using a raspberry Pi, see here : https://github.com/captain-amygdala/pistorm

The Pistorm'X is a simplified CPU board, where all the logic is integrated inside a single XC94144XL-10TQ100 CPLD with 5V compatible IOs. See here : https://github.com/f1ac0/PistormX

It has major differences in the logic implementation to accommodate a slower CPLD, especially getting rid of the 200MHz clock, freeing one GPIO for future use.

Here you can find adapted Pistorm'X firmwares to be used on the original Pistorm CPU board with external buffer chips :
- basic : mostly similar to the features of original Pistorm firmware.
- skip s5s6 : skip s5 and s6 states when not in peripheral bus cycle.

Provided .svf files are built for the EPM240 CPLD.
Do not burn Altera bitstream on Xilinx device or vice versa ! Use with caution it could burn your Pi, your Amiga, your house.

# Experimental status
Actually even if they succeed the buptest and boot both Musashi and EMU68, they are unstable on my board. For example in amigaTestKit, testing the RTC clock does crash : maybe it has something to do with peripheral cycles.

Pistorm'X is experimental, not yet well tested, and might not work with all system revisions and Pi or 68k software or provide the same performance or feature than the original. That it works for me does not mean that it will work for you. For this reason you are welcome to assemble your own and share test reports in the Discord channel named "beta-testing-pistormx".

# Making it
Clone the Pistorm repo and replace the verilog file in the rtl subdirectory.

Build from the command line, replacing the path and version of your Quartus installation :
```
~/Quartus/17.0/quartus/bin/quartus_sh --flow compile pistorm
~/Quartus/17.0/quartus/bin/quartus_cpf -c -q 100KHz -g 3.3 -n p output_files/pistorm.pof pistorm.svf
```
If you choose to build it from the interface, make sure to set the correct 100KHz frequency in the programmer/svf options.

# Programming the CPLD from the Pi
Replace EPM240_bitstream.svf with the new .svf file, then run flash.sh as you usually do.

# Using it
See the official Pistorm documentation.

