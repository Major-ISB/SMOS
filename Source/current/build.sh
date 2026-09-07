# !!! Build.sh reset for a future clearer hand-made version

#!/bin/bash

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

printf " ${RED}Done!\n"

printf "${NC}[2]: Creating floppy image..."

printf " ${RED}Done!\n"

printf "${NC}[3]: Launching qemu..."

if command -v qemu-system-x86_64 &> /dev/null; then
    printf " ${RED}Launched!\n"
else
    printf " ${RED}/!\ Cannot find qemu, aborting...!\n"
fi

trap 'sleep infinity' EXIT
