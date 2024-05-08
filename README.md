# Pistorm'X
If you don't know about Pistorm, the MC68000 CPU replacement using a raspberry Pi, see here : https://github.com/captain-amygdala/pistorm

This PiStorm'X is a simplified CPU board, where all the logic is integrated inside a single CPLD with 5V compatible IOs.

The "Alpha" directory contains the PCB design and CPLD logic files for the first design of the Amiga 500 board and possible mods.

The "Beta" directory shares a second generation of boards for the Amiga 500, Amiga 600 and Amiga 1200. To enjoy both the speed of the PiStorm and the compatibility of the original hardware, they include the ability to disable the Pi and run the original 68k CPU, and the A500 and A600 ones also add 2MB of autoconfig Fast RAM.

Please read the README files there for more info.

# Experimental status
These boards are still experimental, not well tested, and might not work with all system revisions and Pi or 68k software nor provide the same performance or feature than the original. That it works for me does not mean that it will work for you. For this reason you are welcome to assemble your own and share test reports in the discord channel named "beta-testing-pistormx". And for this same reason this board or derivatives must not be sold to end users : do not sell it and do not buy it yet.

- I am an end user, where can I buy it? Buy one of the original PiStorm CPU boards.
- I am a builder, can I sell it? For now, please test it and report your test results.
- I am a maker, can I build derivatives? For now, please test it and report your test results.

# Acknowledgements
The board and its firmware are inspired by the original Pistorm : https://github.com/captain-amygdala/pistorm.
I would like to thank Claude Schwarz for designing and open sourcing the Pistorm and for letting other projects like this one use the name and get inspired by the source code.
Thank you also to EDU_ARANA for letting me use his Pistorm logo with some modifications on the PCB silkscreen.
It is not supported by the PiStorm developers, please don't bother them with issues you might have with it.

# Disclaimer
This is a hobbyist project, it comes with no warranty and no support. Also remember that the Amiga machines are about 30 years old and may fail because of such hardware expansions. Use with caution it could burn your Pi, your Amiga, your house.

I publish my work under the CC-BY-NC-SA license. You may build a board for you or your friend but will not sell or buy it commercially because it is experimental. You must keep the original author's name, source repository (https://github.com/f1ac0/PistormX) and licensing conditions even if you modify the product.

If you find it useful and want to reward my hard work : I am always looking for Amiga/Amstrad CPC and such retro hardware to repair and hack, or software licenses for these. Other than that, give to charities and reduce your carbon footprint.

