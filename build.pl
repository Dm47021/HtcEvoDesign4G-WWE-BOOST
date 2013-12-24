#!/usr/bin/perl -W
use strict;
use Cwd;

my $dir = getcwd;

print "\ncleaning kernel source\n";


print "\nremoving old boot.img\n";
system ("rm boot.img");
system ("rm $dir/zpack/zcwmfiles/boot.img");

print "\nremoving old Evodesign.zip\n";
system ("rm $dir/Evodesign.zip");

print "\ncreating ramdisk from Evodesign folder\n";
chdir ("$dir/zpack");

 unless (-d "$dir/zpack/Evodesign/data") {
 system ("mkdir Evodesign | tar -C /$dir/zpack/Evodesign/ -xvf Evodesign.tar");
 }

chdir ("$dir/zpack/Evodesign");
system ("find . | cpio -o -H newc | gzip > $dir/ramdisk-repack.gz");


print "\nbuilding zImage from source\n";
chdir ("$dir");
system ("cp defconfig $dir/.config");
system ("make -j8");

print "\ncreating boot.img\n";
chdir $dir or die "/zpack/Evodesign $!";;
system ("$dir/zpack/mkbootimg --cmdline '' --kernel $dir/arch/arm/boot/zImage --ramdisk ramdisk-repack.gz -o boot.img --base 0x05000000 --pagesize 4096");

unlink("ramdisk-repack.gz") or die $!;

print "\ncreating flashable zip file\n";
system ("cp arch/arm/common/cpaccess.ko $dir/zpack/zcwmfiles/system/lib/modules/");
system ("cp arch/arm/mach-msm/reset_modem.ko $dir/zpack/zcwmfiles/system/lib/modules/");
system ("cp drivers/crypto/msm/qce.ko $dir/zpack/zcwmfiles/system/lib/modules/");
system ("cp drivers/crypto/msm/qcedev.ko $dir/zpack/zcwmfiles/system/lib/modules/");
system ("cp drivers/crypto/msm/qcrypto.ko $dir/zpack/zcwmfiles/system/lib/modules/");
system ("cp drivers/net/wireless/bcm4329_248/bcm4329.ko $dir/zpack/zcwmfiles/system/lib/modules/");
system ("cp drivers/net/wimax/SQN/sequans_sdio.ko $dir/zpack/zcwmfiles/system/lib/modules/");
system ("cp drivers/net/wireless/libra/librasdioif.ko $dir/zpack/zcwmfiles/system/lib/modules/");
system ("cp boot.img $dir/zpack/zcwmfiles/");
chdir ("$dir/zpack/zcwmfiles");
system ("zip -9 -r $dir/Evodesign.zip *");
print "\nceated Evodesign.zip\n";

print "\nremoving Evodesign.zip from sdcard\n";
system ("adb shell rm /sdcard/Evodesign.zip");

print "\npushing new Evodesign.zip to sdcard\n";
system ("adb push $dir/a200.zip /sdcard/Evodesign.zip");
print "\ndone\n";
