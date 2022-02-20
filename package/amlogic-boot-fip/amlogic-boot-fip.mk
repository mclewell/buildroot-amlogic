################################################################################
#
# amlogic-boot-fip
#
################################################################################

AMLOGIC_BOOT_FIP_VERSION = 26fe4a5ce68d99c7f86ef4f2c5aa6320bc65632f
AMLOGIC_BOOT_FIP_SITE = $(call github,LibreELEC,amlogic-boot-fip,$(AMLOGIC_BOOT_FIP_VERSION))
AMLOGIC_BOOT_FIP_DEPENDENCIES = $(BR2_MAKE_HOST_DEPENDENCY) uboot

define HOST_AMLOGIC_BOOT_FIP_CONFIGURE_CMDS
	mkdir $(@D)/output-odroidhc4
	cp $(BINARIES_DIR)/u-boot.bin $(@D)/odroid-hc4/bl33.bin
endef

define HOST_AMLOGIC_BOOT_FIP_BUILD_CMDS
	echo ""

	bash $(@D)/odroid-hc4/blx_fix.sh \
		$(@D)/odroid-hc4/bl30.bin \
		$(@D)/odroid-hc4/zero_tmp \
		$(@D)/odroid-hc4/bl30_zero.bin \
		$(@D)/odroid-hc4/bl301.bin \
		$(@D)/odroid-hc4/bl301_zero.bin \
		$(@D)/odroid-hc4/bl30_new.bin \
		bl30

	echo ""

	bash $(@D)/odroid-hc4/blx_fix.sh \
		$(@D)/odroid-hc4/bl2.bin \
		$(@D)/odroid-hc4/zero_tmp \
		$(@D)/odroid-hc4/bl2_zero.bin \
		$(@D)/odroid-hc4/acs.bin \
		$(@D)/odroid-hc4/bl21_zero.bin \
		$(@D)/odroid-hc4/bl2_new.bin \
		bl2

	echo ""

	$(@D)/odroid-hc4/aml_encrypt_g12a --bl30sig \
		--input $(@D)/odroid-hc4/bl30_new.bin \
    	--output $(@D)/odroid-hc4/bl30_new.bin.g12a.enc \
        --level v3
	
	echo ""

	$(@D)/odroid-hc4/aml_encrypt_g12a --bl3sig \
		--input $(@D)/odroid-hc4/bl30_new.bin.g12a.enc \
        --output $(@D)/odroid-hc4/bl30_new.bin.enc \
        --level v3 --type bl30

	echo ""

	$(@D)/odroid-hc4/aml_encrypt_g12a --bl3sig \
		--input $(@D)/odroid-hc4/bl31.img \
		--output $(@D)/odroid-hc4/bl31.img.enc \
		--level v3 --type bl31

	echo ""

	$(@D)/odroid-hc4/aml_encrypt_g12a --bl3sig \
		--input $(@D)/odroid-hc4/bl33.bin --compress lz4 \
		--output $(@D)/odroid-hc4/bl33.bin.enc \
		--level v3 --type bl33 --compress lz4

	echo ""

	$(@D)/odroid-hc4/aml_encrypt_g12a --bl2sig \
		--input $(@D)/odroid-hc4/bl2_new.bin \
		--output $(@D)/odroid-hc4/bl2.n.bin.sig

	echo ""

	$(@D)/odroid-hc4/aml_encrypt_g12a --bootmk \
		--output $(@D)/odroid-hc4/u-boot.bin \
		--bl2 $(@D)/odroid-hc4/bl2.n.bin.sig \
		--bl30 $(@D)/odroid-hc4/bl30_new.bin.enc \
		--bl31 $(@D)/odroid-hc4/bl31.img.enc \
		--bl33 $(@D)/odroid-hc4/bl33.bin.enc \
		--ddrfw1 $(@D)/odroid-hc4/ddr4_1d.fw \
		--ddrfw2 $(@D)/odroid-hc4/ddr4_2d.fw \
		--ddrfw3 $(@D)/odroid-hc4/ddr3_1d.fw \
		--ddrfw4 $(@D)/odroid-hc4/piei.fw \
		--ddrfw5 $(@D)/odroid-hc4/lpddr4_1d.fw \
		--ddrfw6 $(@D)/odroid-hc4/lpddr4_2d.fw \
		--ddrfw7 $(@D)/odroid-hc4/diag_lpddr4.fw \
		--ddrfw8 $(@D)/odroid-hc4/aml_ddr.fw \
		--ddrfw9 $(@D)/odroid-hc4/lpddr3_1d.fw \
		--level v3

endef

define HOST_AMLOGIC_BOOT_FIP_INSTALL_CMDS
	dd if=$(@D)/odroid-hc4/u-boot.bin.sd.bin of=$(@D)/odroid-hc4/boot0.bin conv=fsync,notrunc bs=512 skip=1 seek=1
	$(INSTALL) -m 0755 -D $(@D)/odroid-hc4/boot0.bin $(BINARIES_DIR)/boot0.bin
endef

$(eval $(host-generic-package))
