#!/usr/bin/env bash
# fancy colors cause we're fancy
CLEAR='\033[0m'
BOLD='\033[1m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'

source .env

function fail() {
	echo -e "${RED}${1}${CLEAR}"
	exit -1
}

function cmdcheck() {
	echo -n "$1 ... "
	command -v $1 >/dev/null || fail "not found!" && echo -e "${GREEN}found!${CLEAR}"
}

[[ -z "${SGDK}" ]] && SGDK='/opt/toolchains/genesis/sgdk2'
[[ -z "${M68K_PREFIX}" ]] && M68K_PREFIX='m68k-elf-'
echo -e "${BOLD}SGDK for *nix - Initial Setup${CLEAR}"
read -ep "Please specify SGDK directory: " -i ${SGDK} SGDK
[[ -d "${SGDK}" ]] || fail "SGDK directory not found!"
SGDK_BIN=${SGDK}/bin
read -ep "Please specify M68k toolchain prefix: " -i ${M68K_PREFIX} M68K_PREFIX

echo
echo -e "${YELLOW}Checking for necessary tools...${CLEAR}"
cmdcheck gcc
cmdcheck unzip
cmdcheck java
cmdcheck sjasmplus

cmdcheck ${M68K_PREFIX}gcc
cmdcheck ${M68K_PREFIX}objcopy
cmdcheck ${M68K_PREFIX}nm
cmdcheck ${M68K_PREFIX}ld

echo
echo -ne "${YELLOW}Updating project and library makefiles...${CLEAR} "
sed -i -E "s@SGDK\?=[A-Za-z0-9_./-]{1,}@SGDK?=${SGDK}@; s@M68K_PREFIX\?=[A-Za-z0-9_./-]{1,}@M68K_PREFIX?=${M68K_PREFIX}@" makefile_lib
[[ $? != 0 ]] && fail "Failed to update SGDK library makefile"
sed -i -E "s@SGDK\?=[A-Za-z0-9_./-]{1,}@SGDK?=${SGDK}@; s@M68K_PREFIX\?=[A-Za-z0-9_./-]{1,}@M68K_PREFIX?=${M68K_PREFIX}@" makefile
[[ $? != 0 ]] && fail "Failed to update project makefile"
echo -e "${GREEN}done!${CLEAR}"

echo
echo -e "${YELLOW}Building appack...${CLEAR}"
[[ ! -f "sgdk_tools/appack/example/appack.c" || ! -f "sgdk_tools/appack/lib/elf64/aplib.a" ]] && unzip -q -x sgdk_tools/appack/aPLib-1.1.1.zip -d sgdk_tools/appack
(export SGDK=${SGDK}; cd sgdk_tools/appack && make && make install && make clean)
[[ $? != 0 ]] && fail "Failed to build appack"
[[ -x ${SGDK_BIN}/appack ]] || fail "Failed to install appack"
echo -e "${GREEN}Success!${CLEAR}"

echo
echo -e "${YELLOW}Building xgmtool...${CLEAR}"
(export SGDK=${SGDK}; cd sgdk_tools/xgmtool && make && make install && make clean)
[[ $? != 0 ]] && fail "Failed to build xgmtool"
[[ -x ${SGDK_BIN}/xgmtool ]] || fail "Failed to install xgmtool"
echo -e "${GREEN}Success!${CLEAR}"

echo
echo -e "${YELLOW}Building bintos...${CLEAR}"
(export SGDK=${SGDK}; cd sgdk_tools/bintos && make && make install && make clean)
[[ $? != 0 ]] && fail "Failed to build bintos"
[[ -x ${SGDK_BIN}/bintos ]] || fail "Failed to install bintos"
echo -e "${GREEN}Success!${CLEAR}"

echo
echo -e "${YELLOW}Building SGDK library...${CLEAR}"
(export SGDK=${SGDK}; make -f makefile_lib && make -f makefile_lib cleanobj)
[[ $? != 0 ]] && fail "Failed to build SGDK library"
[[ -f ${SGDK}/lib/libmd.a ]] || fail "Failed to build SGDK library"
echo -e "${GREEN}Success!${CLEAR}"

echo
echo -e "${YELLOW}Building SGDK debug library...${CLEAR}"
(export SGDK=${SGDK}; make -f makefile_lib debug && make -f makefile_lib cleanobj)
[[ $? != 0 ]] && fail "Failed to build SGDK library"
[[ -f ${SGDK}/lib/libmd_debug.a ]] || fail "Failed to build SGDK debug library"
echo -e "${GREEN}Success!${CLEAR}"

echo
while true; do
	read -p "Do you wish to remove the Windows specific binaries from the SGDK directory? " winrm
	case $winrm in
		[Yy]* ) rm -f ${SGDK_BIN}/*.exe ${SGDK_BIN}/*.dll; break;;
		[Nn]* ) break;;
		* ) echo "Please type Y or N";;
	esac; done

echo
echo -e "${GREEN}Setup complete!${CLEAR}"
echo "You should be good to go. Copy 'makefile' into the root of your project directory and modify the settings inside at the top."
echo "You do NOT need to run this setup again for a new project. Just copy makefile into as many projects as you like."
