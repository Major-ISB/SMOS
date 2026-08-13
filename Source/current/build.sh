#!/bin/bash

#sudo rm -R ./build
mkdir -p ./build

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE} SSSSS   M     M    OOO    SSSSS ${NC}"
echo -e "${BLUE} S       MM   MM   O   O   S     ${NC}"
echo -e "${BLUE} SSSSS   M M M M   O   O   SSSSS ${NC}"
echo -e "${BLUE}     S   M  M  M   O   O       S ${NC}"
echo -e "${BLUE} SSSSS   M     M    OOO    SSSSS ${NC}"

echo ""
echo ""

printf "${NC}[1]: Compiling source files..."
nasm -f bin ./boot/boot.asm -o ./build/boot.bin

# Kernel entry
nasm -f elf32 ./kernel/kernel_entry.asm -I kernel/ -o ./build/kernel_entry.o

# C in 32-bit
gcc -m32 -ffreestanding -fno-pie -fno-stack-protector -nostdlib -c ./kernel/kernel.c -o ./build/kernel.o
gcc -m32 -ffreestanding -fno-pie -fno-stack-protector -nostdlib -c ./kernel/libs/strlib/strlib.c -o ./build/strlib.o

# Linker
ld -m elf_i386 -T link.ld -o ./build/kernel.bin \
    ./build/kernel_entry.o ./build/kernel.o ./build/strlib.o
    
printf " ${RED}Done!\n"

printf "${NC}[2]: Creating floppy image..."
cat ./build/boot.bin ./build/kernel.bin > ./build/smos-x86.img
truncate -s 1440k ./build/smos-x86.img
printf " ${RED}Done!\n"

printf "${NC}[3]: Launching qemu..."

if command -v qemu-system-x86_64 &> /dev/null; then
    printf " ${RED}Launched!\n"
    qemu-system-x86_64 -kernel ./build/kernel.bin
else
    printf " ${RED}/!\ Cannot find qemu, aborting...!\n"
fi

trap 'sleep infinity' EXIT
