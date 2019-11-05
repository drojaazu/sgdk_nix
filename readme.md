# SGDK for Linux
This is a set of makefiles and source code for building Sega Megadrive/Genesis software using the SGDK framework.

## Intended Audience
SGDK is intended for use on Windows, though its C/ASM library can, of course, be used on any platform. The tools here are for leveraging that library and some of its build tools for easy use in a *nix environment.

This has already been attempted with [Gendev](https://github.com/kubilus1/gendev). However, Gendev builds its own M68k toolchain, which is entirely unnecessary for those who already have their own toolchain set up. Gendev also comes with a lot of extra "stuff" which isn't entirely necessary. Therefore, this project is aimed at those who have an existing M68k toolchain, or who want to keep their toolchain seperate and properly maintained.

*This is an early version and has not had extensive testing yet.* Bug fixes via pull requests are certainly welcome.

## Prerequisites
This was developed on Arch Linux, but I have done my best to make it compatible with any Linux distribution. I have tested on Debian and Ubuntu, so I will provide package names for those distros as well as Arch.

### Intermediate Linux proficiency
This project is meant for those who already have a working knowledge of *nix systems. If you're not comfortable or familiar with the console, look into [Gendev](https://github.com/kubilus1/gendev), which is an alternative Linux implementation of SGDK that is a bit more beginner friendly.

### SGDK
Clone the project from [the SGDK github repo](https://github.com/Stephane-D/SGDK). You're free to put these files whereever you'd like; /opt/sgdk is a good choice, and is the default location in the makefiles. However, you may want to put it in your home dir temporarily while you work through the initial setup so you're not fighting with permissions/environment var issues, and then move it to opt when you're done. Be sure to `export` SGDK accordingly.

### System development tools
- Arch: `base-devel`
- Deb/Ubuntu: `build-essential`

You probably already have this installed, but just in case: you will need the standard set of GNU build tools - g++, make, etc.

### M68000 toolchain
- Arch AUR: `m68k-elf-binutils` and `m68k-elf-bootstrap`
- Deb/Ubuntu: `gcc-m68k-linux-gnu` and `binutils-m68k-linux-gnu`

You will need cross-architecture tools for compiling/assembling/linking/etc code for the Megadrive's M68000 CPU.

If your distro does not have a package, you will, of coutse, have to build from source manually. There are a number of guides online to help with this, but the biggest key here is to use `--target=m68k-elf` when running the configure script for each package. (Please also see the note below about libgcc.)

Your M68k tools will have a different filename prefix to differentiate them from the build tools for your native architecture. Debian and Ubuntu use `m68k-linux-gnu-` while Arch (and tools built with `--target=m68k-elf`) use `m68k-elf-`. The tool prefix is important, as you'll need to specify it when you run the setup script.

### Java
- Arch: `jdk8-openjdk` (or newer, such as `jdk11-openjdk`)
- Deb/Ubuntu: `openjdk-8-jre` (or newer, such as `openjdk-11-jre`)

Java is used by rescomp for pulling resources (graphics, sounds, data blobs) into the code/binary. 

Note that the code was originally written for Java 8. However, newer versions of Java should be backwards compatible. I have done some basic testing with OpenJDK 11 and found no issues, though this was not a thorough test. Also note that as of Debian 10, only JRE 11 is present in the default repos. Though this should be fine, you may have to go searching for 8 if you need it.

### sjasmplus
Used for assembling Z80 code. We use sjasmplus instead of vanilla sjasm since newer versions of sjasm complain about the SGDK music driver source.

You're going to need to build this from source, so [pull from github](https://github.com/z00m128/sjasmplus)  then `make && sudo make install`.

(Also note that there is an sjasmplus package on the Arch AUR; however, that build seems to be bugged, as there have been a few users (myself included) reporting that it always crashes. Just build it from source.)

## Initial Setup
Run `setup.sh` in the root directory. This will check that you have the above mentioned tools installed and will compile the SGDK specific tools for your system, as well as some other helper tasks.

## Making a Project
Setting up a new Megadrive project is as simple as copying `makefile` into your project directory. Once copied, you will probably want to tweak the settings that appear at the top to match your project layout. To build your project run `make` from the project root.

## SGDK tools
There are a number of tools included with SGDK that will need to be recompiled. **Building these tools individually should not be necessary if you used the setup script**, but in case you need to tweak anything yourself, you will find makefiles to build/install the tools inside the `sgdk_tools` subdirectory. 

### appack
This tool is used to compress binary data inside the ROM. SGDK includes the source for this in the tools directory... however, it is missing the prebuilt elf binaries, for some reason. So we can't use the source with SGDK. I've included the full aplib source with this project as a zip (since its license requires all files be distributed together). You can extract the files in the same directory as the zip, then run the makefile from the root.

### xgmtool
This is used to convert VGM music to the XGM format for use with the SGDK drivers. The source is included in the SGDK tools directory. Drop the makefile inside the xgmtool directory and build.

### bintos
This takes binary blobs (in this case, compiled Z80 objects) and references them as M68k assembly for inclusion in the final ROM. The bintos source is included in the SGDK tools directory. Drop the makefile inside the bintos directory and build.

TODO: Per this [old gendev thread](https://gendev.spritesmind.net/forum/viewtopic.php?p=17275#p17275), this should be do-able with objcopy, which removes the need for bintos completely. Will look into this later.

### SGDK library (libmd.a)
SGDK comes with a precompiled library inside the lib directory. However, this seems to be compiled off a pretty old version of gcc, as using it complains about the LTO version not matching. We'll need to build our own from scratch. Use `makefile_lib` to do this.

## Other notes
### Optional libgcc
SGDK includes a prebuilt libgcc archive inside its lib subdirectory, which is used when building a project ROM. Linking with this prebuilt binary should not pose any significant problems, and so it is the default option in the project makefile for ease of use. However, if you're like me and you're picky about doing things "properly," you'll want to build with the libgcc library that matches your gcc version.

To do this, you'll first need to ensure there is a libgcc present for your M68k cross compiler. When compiling gcc, be sure to run the `all-target-libgcc` and `install-target-libgcc` targets as well:
```
make all-target-libgcc
sudo make install-target-libgcc
```

If you're using the m68k-elf-* tools from the Arch Linux AUR, note that they do NOT run these targets by default! You will have to run them manually. After `pkgbuild` for m68k-elf-bootstreap has completed the installation, cd to `src/gcc-build` in the package tree and run the two commands above. This should build/install libgcc for your M68k toolchain.

Next, modify your project makefile. Search for '-lgcc' and you'll find a line that is commented out. Uncomment it (and comment out the similar line above it!) to use the system libgcc instead. (*Be sure that to keep `-lgcc` at the end of the object list* or else you'll get undefined reference errors, for [reasons explained here](http://c-faq.com/lib/libsearch.html).)
