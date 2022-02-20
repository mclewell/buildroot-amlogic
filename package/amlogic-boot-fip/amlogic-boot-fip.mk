################################################################################
#
# amlogic-boot-fip
#
################################################################################

AMLOGIC_BOOT_FIP_VERSION = 26fe4a5ce68d99c7f86ef4f2c5aa6320bc65632f
AMLOGIC_BOOT_FIP_SITE = $(call github,LibreELEC,amlogic-boot-fip,$(AMLOGIC_BOOT_FIP_VERSION))

AMLOGIC_BOOT_FIP_TARGETS_$(BR2_PACKAGE_HOST_AMLOGIC_BOOT_FIP_ODROIDHC4) += odroid-hc4
AMLOGIC_BOOT_FIP_TARGETS_$(BR2_PACKAGE_HOST_AMLOGIC_BOOT_FIP_ODROIDN2) += odroid-n2
AMLOGIC_BOOT_FIP_TARGETS_$(BR2_PACKAGE_HOST_AMLOGIC_BOOT_FIP_ODROIDN2PLUS) += odroid-n2-plus

define HOST_AMLOGIC_BOOT_FIP_INSTALL_CMDS
	mkdir -p $(HOST_DIR)/share/fip
	$(foreach t,$(AMLOGIC_BOOT_FIP_TARGETS_y), \
		cp -r $(@D)/$(t) $(HOST_DIR)/share/fip/
	)
endef

$(eval $(host-generic-package))
