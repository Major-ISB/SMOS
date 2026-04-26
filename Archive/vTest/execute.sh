# Folders
ASM_DIR="/home/juliensierra/Documents/x86/os_dev"
IMG="$ASM_DIR/floppy.img"

# .asm
BOOT="$ASM_DIR/boot.asm"
MAIN="$ASM_DIR/kernel.asm"

# .bin
BOOT_BIN="$ASM_DIR/boot"
MAIN_BIN="$ASM_DIR/kernel"

echo "[1] Assemble"
nasm "$BOOT"
nasm "$MAIN"

echo "[2] Floppy image 1.44MB"
dd if=/dev/zero of="$IMG" bs=1024 count=1440 status=none

echo "[3] Bootloader"
dd if="$BOOT_BIN" of="$IMG" bs=512 seek=0 count=1 conv=notrunc status=none

echo "[4] Kernel"
dd if="$MAIN_BIN" of="$IMG" bs=512 seek=1 conv=notrunc status=none

echo "[5] QEMU"
qemu-system-x86_64 -rtc base=localtime -drive file="$IMG",format=raw,if=floppy
