# ciaa_lpcopen_bare

Bare Metal, LPCOpen projects for EDU-CIAA-NXP

![CIAA logo](https://avatars0.githubusercontent.com/u/6998305?v=3&s=128)

## Dependencies

 - arm-none-eabi from https://launchpad.net/gcc-arm-embedded
 - make and fileutils (rm, sed, echo, etc) from your system (linux,unix,cygwin,mingw)
 - openocd with ftdi driver support

## Usage

 - Edit `Makefile` file and uncomment required `APP=...` (one of all)
 - From command line type `make all` or simply `make`
 - with the board connected, type `make download`. This write program into board and run
 - For erase chip, type `make erase`
 - For debuggin, in another console, type `make openocd`. This start openocd and listen for gdb connection
 - In the main console type `make debug`. This start gdb and connect with openocd, download the code to flash and start execution

## Status

This is work in progress. Some projects not work.

An actualized status of complied pograms can see in [the last recent build log](logs/test_build_all.log)

**WARNING**: If a project pass the compilation, not necessarily work in board

To actualize build log, type `make test_build_all` into main directory
