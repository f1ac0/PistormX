# PiStorm'X Work in progress

NOT ALL DESIGNS IN THIS DIRECTORY ARE TESTED.

If you don't know about PiStorm, the MC68000 CPU replacement using a raspberry Pi, see here : https://github.com/captain-amygdala/pistorm. This PiStorm'X is a simplified CPU board, where all the logic is integrated inside a single CPLD.

# Experimental status
These boards are either experimental, not finished, not yet tested, and might not work for you, have bugs with some system revisions and Pi or 68k software, or have less performance or feature than the original. For this reason you will find here source files only, not fabrication files or ready to use binaries. If you have enough development skills to use them and know what you are doing, you may assemble your own and share test reports in the discord channel named "beta-testing-pistormx". And for this same reason these boards or derivatives must not be sold to end users.

I publish my work under the CC-BY-NC-SA license. You may build a board for you but will not sell or buy it commercially because it is experimental. You must keep the original author's name, source repository (https://github.com/f1ac0/PistormX) and licensing conditions even if you modify the product.

If you find it useful and want to reward my hard work : I am always looking for Amiga/Amstrad CPC/C64 and such retro hardware to repair and hack, or software licenses for these. Other than that, please give to charities and reduce your carbon footprint.

# Acknowledgements
The board and its firmware are inspired by the original PiStorm : https://github.com/captain-amygdala/pistorm.
I would like to thank Claude Schwarz for designing and open sourcing the PiStorm and for letting other projects like this one use the name and get inspired by the source code.
Thank you also to EDU_ARANA for letting me use his PiStorm logo with some modifications on the PCB silkscreen.
It is not supported by the PiStorm developers, please don't bother them with issues you might have with it.

# PiStorm'X 500
The original PiStorm'X project for the Amiga 500 was shared in February 2022. In November 2022, I published the PiStorm'X-68k, a modification to the original project that allow keeping and using the original 68000 by deactivating the PiStorm when needed using a long reset.

This PiStorm'X 500 is an updated board for the Amiga 500 :
- including the PiStorm'X-68k modifications,
- moving the Pi away from the 68000, over the A500 ROM, in order to improve thermal repartition,
- adding 2MB of Fast RAM, which is useful especially during 68000 operation when the Pi is disabled : there was enough room on the two sided board and I believe it is a nice addition to the stock Amiga 500.

/!\ This 1.0 revision board need a patch wire between pin 15 of the 68k header to the pad marked OVR /!\ Do not connect anything else to this pad and check that the BGACK solder jumper is not shorted to the BGACK pin. /!\

The development of this board has been painful. I killed the 7805 Super Fat Agnus of my Rev8a in the development process, because of a dodgy home designed and printed ZIF64 socket that doesn't lock correctly, and an idiot operator that touched the pins without ESD protection. I am looking for an affordable replacement. Then I fought a timing problem caused by the slow transition on the 7MHz clock, because I thought it was a good idea to route it to a global clock pin of the CPLD. It was not - see https://support.xilinx.com/s/article/3226, on the Rev6 with Agnus 8372 318069-02 they are about 25ns, compared to 10ns on my A600 Rev1.5 with Agnus 8375 318069-10 - and this is the reason for the patch wire.

This board is actually working on my A500 Rev6.

# PiStorm'X 600
The PiStorm'X 600 brings the same features as the PiStorm'X 500 to the Amiga 600 : maintain reset during 6 seconds or more to use the 68000, and benefit of 2MB of Fast RAM.

This board is actually working on my A600.

# PiStorm'X 1K2
I have heard about the PiStorm32 for the Amiga 1200 and I wanted to make my own in the Pistorm'X way.

This is not yet finished and untested.

- There are two board layouts : the first board steals the component placement form the PiStorm32-lite ; the second "alt" one offers a more "traditional" design to access the Pi in the trapdoor. Both boards share the same logic but have different CPLD pinout and so will require different bitstreams. With the latter if you don't mind leaving the trapdoor open you may install a standard pin header for the Pi GPIO, leaving the A1200 edge connector as the only special part.
- Since it needs to cope with 32 bits operation with misaligned addresses and dynamic bus sizing, it requires a larger XC95288 CPLD, both in pin count and macrocells.
- This added logic must still be full of bugs and may never work.
- I reused the Pi pinouts from the Pistorm32-lite and since it does not have room for the jtag anymore, the device needs to be programmed externally.
- Even with the same Pi pinouts, it will need updated emulators that does not try to program a FPGA at power up : I hope this will be possible to deactivate it in future upstream releases.
- Like the original PiStorm'X that is not limited by external buffers, it might also be possible to use a faster protocol to speed up chip access a little bit. Or offload some complexity to the emulator to fit inside an even smaller/cheaper CPLD.

For sure this will need some more effort to first make it work !
