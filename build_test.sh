#! /bin/bash

clear
# build machine V 1.1
# this one only for test build, Gabriel_Kernel_D855
# TNX Dorimanx
# TNX Androplus
# -----------------------------------
# define variables

today=`date '+%Y_%m_%d__%H_%M_%S'`;
KD=$(readlink -f .);
TCA493=(/media/dgod/kernel/kernel/architoolchain-4.9/bin/arm-architoolchain-linux-gnueabi-);
TCA510=(/media/dgod/kernel/kernel/architoolchain-5.1/bin/arm-architoolchain-linux-gnueabihf-);
TCUB511=(/media/dgod/kernel/kernel/android-UBERTC-5.1/bin/arm-eabi-);
TCLN494=(/media/dgod/kernel/kernel/linaro-4.9.4-dorimanx/bin/arm-LG-linux-gnueabi-);
TS=(TOOLSET);
WD=(WORKING_DIR);
RK=(READY_KERNEL);
DESK=(/home/dgod/Desktop/KERNEL_TEST);
BOOT=(arch/arm/boot);
DTC=(scripts/dtc);
DCONF=(arch/arm/configs);
D855=(gabriel_d855_defconfig);
NAME=(Gabriel-3.4.108);
MODEL=(D855);
FILENAME=($NAME-$(date +"[%d-%m]")-$MODEL);

ZIPFILE=$FILENAME
if [[ -e $RK/$ZIPFILE.zip ]] ; then
    i=0
    while [[ -e $RK/$ZIPFILE-$i.zip ]] ; do
        let i++
    done
    FILENAME=$ZIPFILE-$i
fi

export PATH=$PATH:tools/lz4demo

REBUILD()
{
clear
echo -e "\e[41mREBUILD\e[m"
sleep 3
### cleanup files creted previously

	for i in $(find "$KD"/ -name "*.ko"); do
		rm -fv "$i";
	done;
	for i in $(find "$KD"/ -name "boot.img"); do
		rm -fv "$i";
	done;
	for i in $(find "$KD"/ -name "dt.img"); do
		rm -fv "$i";
	done;
	for i in $(find "$KD"/ -name "*.zip" -not -path "*$RK/*"); do
		rm -fv "$i";
	done;
	for i in $(find "$KD"/ -name "zImage-dtb"); do
		rm -fv "$i";
	done;
	for i in $(find "$KD"/ -name "kernel_config_view_only"); do
		rm -fv "$i";
	done;
	for i in $(find "$KD"/ -name "TC-*"); do
		rm -fv "$i";
	done;

	# Idea by savoca
	NR_CPUS=$(grep -c ^processor /proc/cpuinfo)

	if [ "$NR_CPUS" -le "2" ]; then
		NR_CPUS=4;
		echo "Building kernel with 4 CPU threads";
		echo ""
	else
		echo -e "\e[1;44mBuilding kernel with $NR_CPUS CPU threads\e[m"
		echo ""
	fi;

	CLEANUP;

#cp $KD/$DCONF/$D855 $KD/.config

time make ARCH=arm CROSS_COMPILE=$TC g3-global_com-perf_defconfig
time make ARCH=arm CROSS_COMPILE=$TC nconfig
start=$(date +%s.%N)
time make ARCH=arm CROSS_COMPILE=$TC zImage-dtb  -j ${NR_CPUS}
time make ARCH=arm CROSS_COMPILE=$TC modules -j ${NR_CPUS}
clear

POST_BUILD;
}

CONTINUE_BUILD()
{
clear
echo -e "\e[41mCONTINUE_BUILD\e[m"
sleep 3
time make ARCH=arm CROSS_COMPILE=$TC zImage-dtb modules -j ${NR_CPUS}
clear

POST_BUILD;
}

POST_BUILD()
{
echo "checking for compiled kernel..."
if [ -f arch/arm/boot/zImage-dtb ]
then

echo "copy modules"
find . -name '*ko' -exec \cp '{}' $WD/package/system/lib/modules/ \;

echo "generating device tree..."
./dtbTool -o $BOOT/dt.img -s 2048 -p $DTC/ $BOOT/

echo "copy zImage-dtb and dt.img"
\cp $BOOT/zImage-dtb $WD/ramdisk/
\cp $BOOT/dt.img $WD/ramdisk/

echo "creating boot.img"
./mkboot $WD/ramdisk $WD/boot.img

echo "bumping"
python open_bump.py $WD/boot.img

echo "copy bumped image"
\cp $WD/boot_bumped.img $WD/package/boot.img

echo "copy .config"
\cp .config $WD/package/kernel_config_view_only

echo "create flashable zip"
cd $WD/package
zip kernel.zip -r *

echo "copy flashable zip to output > flashable"
cd ..
cd ..
cp $WD/package/kernel.zip $RK/$FILENAME.zip

clear
echo ""
echo -e "\e[1;44mWELL DONE ;)\e[m"
echo ""
echo ""
end=$(date +%s.%N)    
runtime=$(python -c "print(${end} - ${start})")
echo -e "\e[1;44mRuntime was $runtime\e[m"
echo ""
echo ""
### THANKS GOD

fi
}

CLEANUP()
{
	make ARCH=arm mrproper;
	make clean;
}

echo "Select Toolchain ... ";
select CHOICE in ARCHI-4.9.3 ARCHI-5.1.0 UBER-5.1.1 LINARO-4.9.4 LAST_ONE CLEANUP; do
	case "$CHOICE" in
		"ARCHI-4.9.3")
			TC=$TCA493;
			touch $WD/package/TC-architoolchain-4.9.3
			break;;
		"ARCHI-5.1.0")
			TC=$TCA510;
			touch $WD/package/TC-architoolchain-5.1.0
			break;;
		"UBER-5.1.1")
			TC=$TCUB511;
			touch $WD/package/TC-ubertc-5.1.1
			break;;
		"LINARO-4.9.4")
			TC=$TCLN494;
			touch $WD/package/TC-linaro-4.9.4
			break;;
		"LAST_ONE")
			TC=$TC;
			break;;
		"CLEANUP")
			CLEANUP;
			break;;
	esac;
done;
echo ""
echo "What to do what not to do ?! =D";
select CHOICE in REBUILD CONTINUE_BUILD CLEANUP; do
	case "$CHOICE" in
		"REBUILD")
			REBUILD;
			break;;
		"CONTINUE_BUILD")
			CONTINUE_BUILD;
			break;;
		"CLEANUP")
			CLEANUP;
			break;;
	esac;
done;
