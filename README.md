# Buildroot for Amlogic Boards
This repo contains Buildroot configurations for various single board computers
with Amlogic CPUs.

## Usage
Clone this repo and initialize submoudles:
```
git clone https://github.com/mclewell/buildroot-amlogic.git
git submodule update --init
```
Create output directory and build SD-Card image for the board:
```
cd buildroot
mkdir output-odroidhc4
cd output-odroidhc4
make -C ../ O=$(pwd) BR2_EXTERNAL=$PWD/../../ odroidhc4_defconfig
```

The resulting image will be located in the ```images``` directory. 
Write the image to an SD-Card:
```
dd if=images/sdcard.img of=/dev/sdX bs=1M status=progress && sync
```

## Currently Supported/Tested Boards:
- Odroid-HC4 - Tested, working
- Odroid-N2+ - In-work

## Firmware Image Package (FIP):
Amlogic CPUs require signed first-stage boot images. The various boot components,
called the Firmware Image Package (FIP), can be built from 
[Hardkernel's U-boot source](https://github.com/hardkernel/u-boot). The LibreELEC
project has extracted these binaries and made them available in one of their
[repos](https://github.com/LibreELEC/amlogic-boot-fip). Refer to that repo
for the list of boards supported by the Amlogic FIP.

This repo contains a Buildroot pacakge called ```amlogic-boot-fip``` that 
downloads the LibreELEC repo and places the FIP directories in the 
```${HOST_DIR}/share/fip``` directory. The boards that are copied are 
controlled by the options selected by the ```BR2_PACKAGE_HOST_AMLOGIC_BOOT_FIP_xxx```
config options. These options can be enabled in ```menuconfig``` from 
```External options-->host Firmware Image Package for Amlogic```.

The ```post-image.sh``` script then assembles the binary blobs into the boot
image required for the specific board.

## Adding Support for Additional Boards:
1. Refer to the board directories in the LibreELEC FIP repo
2. Edit ```package/amlogic-boot-fip/amlogic-boot-fip.mk``` and add a new 
```AMLOGIC_BOOT_FIP_TARGETS_...``` line. 
(e.g. ```AMLOGIC_BOOT_FIP_TARGETS_$(BR2_PACKAGE_HOST_AMLOGIC_BOOT_FIP_NEWBOARD```)
3. Edit ```package/amlogic-boot-fip/Config.in.host``` and add the corresponding
config option.
E.g.:
```
config BR2_PACKAGE_HOST_AMLOGIC_BOOT_FIP_NEWBOARD
	bool "New Board"
```
4. Update your Buildroot defconfig either manually or through menuconfig.

