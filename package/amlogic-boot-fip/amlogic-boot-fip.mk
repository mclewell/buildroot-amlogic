################################################################################
#
# amlogic-boot-fip
#
################################################################################

AMLOGIC_BOOT_FIP_VERSION = 26fe4a5ce68d99c7f86ef4f2c5aa6320bc65632f
AMLOGIC_BOOT_FIP_SITE = $(call github,LibreELEC,amlogic-boot-fip,$(AMLOGIC_BOOT_FIP_VERSION))
AMLOGIC_BOOT_FIP_DEPENDENCIES = $(BR2_MAKE_HOST_DEPENDENCY) uboot

define HOST_AMLOGIC_BOOT_FIP_BUILD_CMDS
	$(@D)/build-fip.sh odroid-hc4 $(BINARIES_DIR)/u-boot.bin $(@D)
	dd if=$(@D)/u-boot.bin.sd.bin of=$(@D)/boot0.bin conv=fsync,notrunc bs=512 skip=1 seek=1
endef

define HOST_AMLOGIC_BOOT_FIP_INSTALL_CMDS
	$(INSTALL) -m 0755 -D $(@D)/boot0.bin $(BINARIES_DIR)/boot0.bin
endef

$(eval $(host-generic-package))
