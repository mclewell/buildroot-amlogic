#!/bin/bash

BOARD_DIR="$(dirname $0)"

BOARD=odroid-hc4
FIP_DIR=${HOST_DIR}/share/fip/${BOARD}
BL33=${BINARIES_DIR}/u-boot.bin
TMP=$(mktemp -d)

echo "Step1"
${FIP_DIR}/blx_fix.sh \
	${FIP_DIR}/bl30.bin \
	${TMP}/zero_tmp \
	${TMP}/bl30_zero.bin \
	${FIP_DIR}/bl301.bin \
	${TMP}bl301_zero.bin \
	${TMP}/bl30_new.bin \
	bl30

echo "Step2"
${FIP_DIR}/blx_fix.sh \
	${FIP_DIR}/bl2.bin \
	${TMP}/zero_tmp \
	${TMP}/bl2_zero.bin \
	${FIP_DIR}/acs.bin \
	${TMP}/bl21_zero.bin \
	${TMP}/bl2_new.bin \
	bl2

echo "Step3"
${FIP_DIR}/aml_encrypt_g12a --bl30sig \
	--input ${TMP}/bl30_new.bin \
    	--output ${TMP}/bl30_new.bin.g12a.enc \
        --level v3
	
echo "Step4"
${FIP_DIR}/aml_encrypt_g12a --bl3sig \
	--input ${TMP}/bl30_new.bin.g12a.enc \
        --output ${TMP}/bl30_new.bin.enc \
        --level v3 --type bl30

echo "Step5"
${FIP_DIR}/aml_encrypt_g12a --bl3sig \
	--input ${FIP_DIR}/bl31.img \
	--output ${TMP}/bl31.img.enc \
	--level v3 --type bl31

echo "Step6"
${FIP_DIR}/aml_encrypt_g12a --bl3sig \
	--input ${BL33} --compress lz4 \
	--output ${TMP}/bl33.bin.enc \
	--level v3 --type bl33 --compress lz4

echo "Step7"
${FIP_DIR}/aml_encrypt_g12a --bl2sig \
	--input ${TMP}/bl2_new.bin \
	--output ${TMP}/bl2.n.bin.sig

echo "Step8"
${FIP_DIR}/aml_encrypt_g12a --bootmk \
	--output ${TMP}/u-boot.bin \
	--bl2 ${TMP}/bl2.n.bin.sig \
	--bl30 ${TMP}/bl30_new.bin.enc \
	--bl31 ${TMP}/bl31.img.enc \
	--bl33 ${TMP}/bl33.bin.enc \
	--ddrfw1 ${FIP_DIR}/ddr4_1d.fw \
	--ddrfw2 ${FIP_DIR}/ddr4_2d.fw \
	--ddrfw3 ${FIP_DIR}/ddr3_1d.fw \
	--ddrfw4 ${FIP_DIR}/piei.fw \
	--ddrfw5 ${FIP_DIR}/lpddr4_1d.fw \
	--ddrfw6 ${FIP_DIR}/lpddr4_2d.fw \
	--ddrfw7 ${FIP_DIR}/diag_lpddr4.fw \
	--ddrfw8 ${FIP_DIR}/aml_ddr.fw \
	--ddrfw9 ${FIP_DIR}/lpddr3_1d.fw \
	--level v3

dd if=${TMP}/u-boot.bin.sd.bin of=${BINARIES_DIR}/boot0.bin conv=fsync,notrunc bs=512 skip=1 seek=1

echo "Creating SD-Card image..."
#cd ~-
support/scripts/genimage.sh -c ${BOARD_DIR}/genimage.cfg
