# RavensRover

## Project setup
NOTE: On Windows longpaths in git may need to be enabled `git config --system core.longpaths true` and enabling [Win32 longpaths](https://www.thewindowsclub.com/how-to-enable-or-disable-win32-long-paths-in-windows-11-10).

Fetch thirdparty dependencies through git submodules
```shell
git submodule update --init --recursive
```
Open the RavensRover.gpr file using GNAT Studio and code

## Flashing

> [!WARNING]
> Note: After having flashed anything other than Ada, especially if it contains the nRF Softdevice do a mass erase, otherwise things wont run as expected!
> `pyocd erase --mass --t nrf52833`

After building either do `pyocd load -t nrf52833 --format elf obj/main` or launch through VSCode by pressing F5 and get a debugger, or through build/flash using GNAT Studio

## VSCode

Guide to set up Ada in VSCode:
- Install the recommended extensions for the workspace
- At the moment `microbit_v2_full.gpr` sets some variables that causes the AdaCore language server to fail, it can easily be fixed by commenting out two lines:
    - Go to `thirdparty/Ada_Drivers_Library/boards/MicroBit_v2/microbit_v2_full.gpr`
    - Comment out `for Target use "arm-eabi";` and `for Runtime ("Ada") use "ravenscar-full-nrf52833";` by adding `--` in front. It should be around line 60.
- Re-open VSCode, Ada should now work with the Ada Language Server by AdaCore :magic_wand:
