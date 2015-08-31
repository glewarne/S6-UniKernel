#!/bin/bash +x

# This build script by g.lewarne (xda)
# For S6 custom kernel

clear
echo
echo

######################################## SETUP #########################################

# set variables
FIT=custom_defconfig
DTS=arch/arm64/boot/dts
IMG=arch/arm64/boot
DC=arch/arm64/configs
BK=build_kernel
OUT=../output
DT=G92X_universal.dtb

# Cleanup old files from build environment
echo -n "Cleanup build environment.........................."
cd .. #move to source directory
rm -rf $BK/ramdisk.cpio.gz
rm -rf $BK/Image*
rm -rf $BK/boot*.img
rm -rf $BK/dt*.img
rm -rf $IMG/Image
rm -rf $DTS/.*.tmp
rm -rf $DTS/.*.cmd
rm -rf $DTS/*.dtb
rm -rf $OUT/skrn/*.img
rm -rf $OUT/*.zip
rm -rf $OUT/*.tar
rm -rf .config
echo "Done"

# Set build environment variables
echo -n "Set build variables................................"
export ARCH=arm64
export SUBARCH=arm64
export ccache=ccache
export USE_SEC_FIPS_MODE=true
export KCONFIG_NOTIMESTAMP=true
echo "Done"
echo

#################################### DEFCONFIG CHECKS #####################################

echo -n "Checking for defconfig............................."
if [ -f "$DC/$FIT" ]; then
	echo "Found"
else
	echo "Not Found - Reset"
	cp $BK/$FIT $DC/$FIT
fi

# Ask if we want to xconfig or just compile
echo
read -p "Do you want to xconfig or just compile? (x/c)  > " xc
if [ "$xc" = "X" -o "$xc" = "x" ]; then
	echo
	# Make and xconfig our defconfig
	echo -n "Loading xconfig ..................................."
	cp $DC/$FIT .config
	xterm -e make ARCH=arm64 xconfig
	echo "Done"
	mv .config $DC/$FIT
fi
echo

#################################### IMAGE COMPILATION #####################################

echo -n "Compiling Kernel .................................."
cp $DC/$FIT .config
xterm -e make ARCH=arm64 -j4
if [ -f "arch/arm64/boot/Image" ]; then
	echo "Done"
	# Copy the compiled image to the build_kernel directory
	mv $IMG/Image $BK/Image
else
	clear
	echo
	echo "Compilation failed on kernel !"
	echo
	while true; do
    		read -p "Do you want to run a Make command to check the error?  (y/n) > " yn
    		case $yn in
        		[Yy]* ) make; echo ; exit;;
        		[Nn]* ) echo; exit;;
        	 	* ) echo "Please answer yes or no.";;
    		esac
	done
fi

###################################### DT.IMG GENERATION #####################################

echo -n "Build dt.img......................................."

./tools/dtbtool -o $BK/dt.img -s 2048 -p ./scripts/dtc/ $DTS/ | sleep 1
# get rid of the temps in dts directory
rm -rf $DTS/.*.tmp
rm -rf $DTS/.*.cmd
rm -rf $DTS/*.dtb

# Calculate DTS size for all images and display on terminal output
du -k "$BK/dt.img" | cut -f1 >sizT
sizT=$(head -n 1 sizT)
rm -rf sizT
echo "$sizT Kb"

###################################### RAMDISK GENERATION #####################################

echo -n "Make Ramdisk archive..............................."
cd $BK/ramdisk
find .| cpio -o -H newc | lzma -9 > ../ramdisk.cpio.gz

##################################### BOOT.IMG GENERATION #####################################

echo -n "Make boot.img......................................"
cd ..
./mkbootimg --base 0x10000000 --kernel Image --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --pagesize 2048 --ramdisk ramdisk.cpio.gz --dt dt.img -o boot.img
# copy the final boot.img's to output directory ready for zipping
cp boot*.img ../$OUT/skrn/
echo "Done"

######################################## ZIP GENERATION #######################################

echo -n "Creating flashable zip............................."
cd ../$OUT #move to output directory
xterm -e zip -r TWRP_kernel.zip *
echo "Done"
echo -n "Creating ODIN tar.................................."
cd skrn
xterm -e tar -H ustar -cvf ODIN_kernel.tar boot.img
md5sum -t ODIN_kernel.tar >> ODIN_kernel.tar
cd ..
mv skrn/ODIN_kernel.tar ODIN_kernel.tar
echo "Done"

###################################### OPTIONAL SOURCE CLEAN ###################################

echo
cd ../ksource
read -p "Do you want to Clean the source? (y/n) > " mc
if [ "$mc" = "Y" -o "$mc" = "y" ]; then
	xterm -e make clean
	xterm -e make mrproper
fi

############################################# CLEANUP ##########################################

cd ../ksource/$BK
rm -rf ramdisk.cpio.gz
rm -rf Image*
rm -rf boot*.img
rm -rf dt*.img
rm -rf ../fmp_hmac.bin
rm -rf ../fips_fmp_utils
rm -rf ../arch/arm64/boot/Image.gz-dtb

echo
echo "Build completed"
echo
#build script ends


