#! /bin/bash

today=`date '+%Y_%m_%d__%H_%M_%S'`;

### GCC 4.9.x

### Build kernel for G3

rm arch/arm/boot/*.dtb
rm arch/arm/boot/zImage-dtb
rm arch/arm/boot/dt.img
rm /media/dgod/kernel/kernel/output/boot.img
rm /media/dgod/kernel/kernel/output/boot_bumped.img
rm /media/dgod/kernel/kernel/output/ramdisk/dt.img
rm /media/dgod/kernel/kernel/output/ramdisk/zImage-dtb
rm /media/dgod/kernel/kernel/output/package/boot.img
rm /media/dgod/kernel/kernel/output/package/kernel.zip

### cleaning
echo ""
echo "cleaning"
echo ""
make clean mrproper

### generate build name
echo ""
echo "changing the build name"
echo ""
./build_name_gen.sh

### get defconfig
echo ""
echo "generating defconfig"
echo ""
make ARCH=arm CROSS_COMPILE=/media/dgod/kernel/kernel/architoolchain-4.9-arm/bin/arm-architoolchain-linux-gnueabi- g3-global_com-perf_defconfig

### make changes
echo ""
echo "entering nconfig"
echo ""
make ARCH=arm CROSS_COMPILE=/media/dgod/kernel/kernel/architoolchain-4.9-arm/bin/arm-architoolchain-linux-gnueabi- nconfig

### compile kernel
echo ""
echo "compiling kernel"
echo ""
make ARCH=arm CROSS_COMPILE=/media/dgod/kernel/kernel/architoolchain-4.9-arm/bin/arm-architoolchain-linux-gnueabi- zImage-dtb modules -j4

echo "checking for compiled kernel..."
if [ -f arch/arm/boot/zImage-dtb ]
then

echo ""
echo "generating device tree..."
echo ""
./dtbTool -o /media/dgod/kernel/GABRIEL/3.4.108-proj/GABRIEL_LP/arch/arm/boot/dt.img -s 2048 -p /media/dgod/kernel/GABRIEL/3.4.108-proj/GABRIEL_LP/scripts/dtc/ /media/dgod/kernel/GABRIEL/3.4.108-proj/GABRIEL_LP/arch/arm/boot/

### copy zImage
echo ""
echo "copy zImage-dtb and dt.img"
echo ""
\cp arch/arm/boot/zImage-dtb /media/dgod/kernel/kernel/output/ramdisk/
\cp arch/arm/boot/dt.img /media/dgod/kernel/kernel/output/ramdisk/

### create boot.img
echo ""
echo "creating boot.img"
echo ""
./mkboot /media/dgod/kernel/kernel/output/ramdisk/ /media/dgod/kernel/kernel/output/boot.img

###bump boot.img
echo ""
echo "bumping"
echo ""
python open_bump.py /media/dgod/kernel/kernel/output/boot.img

### copy bumped image
echo ""
echo "copy bumped image"
echo ""
\cp /media/dgod/kernel/kernel/output/boot_bumped.img /media/dgod/kernel/kernel/output/package/boot.img
find . -name '*ko' -exec \cp '{}' /media/dgod/kernel/kernel/output/package/system/lib/modules/ \;

### create flashable zip
echo ""
echo "create flashable zip"
echo ""
cd /media/dgod/kernel/kernel/output/package/
zip kernel.zip -r *

### final flashable zip
echo ""
echo "copy flashable zip to output>flashable"
echo ""
cp /media/dgod/kernel/kernel/output/package/kernel.zip /media/dgod/kernel/kernel/output/flashable/Gabriel-3.4.108-$(date +"[%d-%m]")-D855.zip

echo "DONE"

### THANKS GOD


fi
