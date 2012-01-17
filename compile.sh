#!/bin/bash

DATE=`date +%Y%m%d`

function fsetenv {
	echo -n "Setting ARM environment..."
	export CFLAGS="-O2 -Os -floop-interchange -floop-strip-mine -floop-block"
	echo " done."

	echo -n "Setting other environment variables..."
	# the number of CPUs to use when compiling the kernel (auto detect all available)
	export CPUS=`grep -c processor /proc/cpuinfo`
	# grab the localversion so we can append it to the boot image
	let RELVER=`cat .version`+1
	echo " done."
}

function fmkinitramfs {
	echo "Zipping ramdisk..."
	release/mkbootfs release/boot.img-ramdisk | gzip > release/boot.img-ramdisk.gz
}

function fmkbootimg {
	echo "Creating boot.img..."
#	mkbootimg --base 0x00200000 --pagesize 4096 --cmdline 'mem=211M console=ttyMSM2,115200n8 androidboot.hardware=c8500' --kernel arch/arm/boot/zImage --ramdisk release/boot.img-ramdisk.gz -o release/c8500_boot.img || exit 1
	mkbootimg --base 0x00200000 --pagesize 4096 --cmdline 'mem=211M no_console_suspend=1 console=null androidboot.hardware=c8500' --kernel arch/arm/boot/zImage --ramdisk release/boot.img-ramdisk.gz -o release/c8500_boot.img || exit 1
	echo "Smells like bacon... release/c8500_boot.img is ready!"
}

function fcopy2cm7 {
	echo "Copy kernel and modules to cm7 directory ... "
	cp arch/arm/boot/zImage  	  		/river/cm7/device/huawei/c8500/prebuilt/kernel
	cp release/boot.img-ramdisk/init.c8500.rc   	/river/cm7/device/huawei/c8500/prebuilt/init.c8500.rc
#	cp drivers/staging/zram/zram.ko   		/river/cm7/device/huawei/c8500/prebuilt/lib/modules/zram.ko
	echo "done."
}

function fcopy2img {
	echo "Copy boot.img to recovery image... "
	cp release/c8500_boot.img 			/river/rom/river/boot.img
	cp release/c8500_boot.img 			/river/rom/boot.img
	cp release/c8500_boot.img 			/river/rom/
#	cp drivers/staging/zram/zram.ko   		/river/rom/river/system/lib/modules/
	echo "done."
}

#fcopy2cm7
fmkinitramfs && fmkbootimg || exit
fcopy2img

