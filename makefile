###################################################
# This is the SGDK PROJECT makefile
# Put this file in the root of your project
# directory and build with the 'make' command
###################################################

# specify SGDK root dir
SGDK?=/opt/sgdk

# specify your M68k GNU toolchain prefix
M68K_PREFIX?=m68k-elf-

# project source code & resources directories
# C source code
SRC_DIR:=src
# C headers
INC_DIR:=inc
# Resources (images, music, etc)
RES_DIR:=res
# Output directory (build files, final ROM, etc)
OUT_DIR:=out

# The name of your final ROM binary
BIN=rom.bin

###################################################
# You shouldn't need to configure anything further
# for your project below this line
###################################################

# fancy colors cause we're fancy
CLEAR=\033[0m
RED=\033[1;31m
YELLOW=\033[1;33m
GREEN=\033[1;32m

# references to SGDK library souce
LIB_SRC:=$(SGDK)/src
LIB_RES:=$(SGDK)/res
LIB_INC:=$(SGDK)/inc

# NOTE: we assume all commands appear somewhere in PATH.
# If you've manually configured/built some of these
# tools and their directories are not listed in PATH
# you will need to specify the full path of each command

# m68k toolset
CC:=$(M68K_PREFIX)gcc
OBJCPY:=$(M68K_PREFIX)objcopy
NM:=$(M68K_PREFIX)nm
LD:=$(M68K_PREFIX)ld

# z80 toolset
ASM_Z80=sjasmplus

# SGDK toolset
RESCOMP:=java -jar $(SGDK)/bin/rescomp.jar
BINTOS:=$(SGDK)/bin/bintos

# gather code & resources
SRC_C:=$(wildcard $(SRC_DIR)/*.c)
SRC_C+=$(wildcard *.c)
SRC_S:=$(wildcard $(SRC_DIR)/*.s)
SRC_S+=$(wildcard *.s)
SRC_S80:=$(wildcard $(SRC_DIR)/*.s80)
SRC_S80+=$(wildcard *.s80)
RES:=$(wildcard $(RES_DIR)/*.res)
RES+=$(wildcard *.res)

# setup output objects
OBJ:=$(RES:.res=.o)
OBJ+=$(SRC_S80:.s80=.o)
OBJ+=$(SRC_S:.s=.o)
OBJ+=$(SRC_C:.c=.o)

OBJS:=$(addprefix $(OUT_DIR)/, $(OBJ))

LST:=$(SRC_C:.c=.lst)
LSTS:=$(addprefix $(OUT_DIR)/, $(LST))

# setup includes
INC:=-I$(INC_DIR) -I$(SRC_DIR) -I$(RES_DIR) -I$(LIB_INC) -I$(LIB_RES)

# default flags
ARCH_FLAG:=-m68000
DEF_FLAGS_M68K:=$(ARCH_FLAG) -Wall -fno-builtin -fno-pie -no-pie -fno-stack-protector -fno-lto $(INC)
DEF_FLAGS_Z80:=-i$(SRC_DIR) -i$(INC_DIR) -i$(RES_DIR) -i$(LIB_SRC) -i$(LIB_INC)

release: FLAGS:=$(DEF_FLAGS_M68K) -O3 -fuse-linker-plugin -fno-web -fno-gcse -fno-unit-at-a-time -fomit-frame-pointer -flto
release: LIB_MD:=$(SGDK)/lib/libmd.a
release: BUILDTYPE=release
release: envcheck prebuild $(OUT_DIR)/$(BIN) postbuild

debug: FLAGS:=$(DEF_FLAGS_M68K) -O1 -ggdb -DDEBUG=1
debug: LIB_MD:=$(SGDK)/lib/libmd_debug.a
debug: BUILDTYPE=debug
debug: envcheck prebuild $(OUT_DIR)/$(BIN) $(OUT_DIR)/rom.out $(OUT_DIR)/symbols.txt postbuild

asm: FLAGS:=$(DEF_FLAGS_M68K) -O3 -fuse-linker-plugin -fno-web -fno-gcse -fno-unit-at-a-time -fomit-frame-pointer -S
asm: BUILDTYPE:=asm
asm: envcheck prebuild $(LSTS) postbuild

all: release
default: release
Default: release
Release: release
Asm: asm

.PHONY: clean

envcheck:
	@if [ ! -d $(SGDK) ]; then echo -e "${RED}*** SGDK directory not found!${CLEAR}"; exit -1; fi

cleanlst:
	@rm -f $(LSTS)

cleanobj:
	@rm -f $(OBJS) $(OUT_DIR)/sega.o $(OUT_DIR)/rom_head.bin $(OUT_DIR)/rom_head.o $(OUT_DIR)/rom.out

clean: cleanobj cleanlst
	@rm -f out.lst $(OUT_DIR)/cmd_ $(OUT_DIR)/rom.nm $(OUT_DIR)/rom.wch $(OUT_DIR)/$(BIN)

cleandebug: clean
	@rm -f $(OUT_DIR)/symbols.txt

cleanasm: cleanlst

cleandefault: clean
cleanDefault: clean

cleanRelease: cleanrelease
cleanDebug: cleandebug
cleanAsm: cleanasm

prebuild:
	@mkdir -p $(SRC_DIR)/boot
	@mkdir -p $(OUT_DIR)
	@mkdir -p $(OUT_DIR)/$(SRC_DIR)
	@mkdir -p $(OUT_DIR)/$(RES_DIR)
	@echo -e "${YELLOW}Beginning $(BUILDTYPE) project build...${CLEAR}"

postbuild:
	@echo -e "${GREEN}Build complete!${CLEAR}"

$(OUT_DIR)/$(BIN): $(OUT_DIR)/rom.out
	@$(OBJCPY) -O binary $(OUT_DIR)/rom.out $(OUT_DIR)/temp
	@dd if=out/temp of=$@ bs=8K conv=sync status=none
	@rm -f out/temp

$(OUT_DIR)/symbols.txt: $(OUT_DIR)/rom.out
	$(NM) -n $(OUT_DIR)/rom.out > $(OUT_DIR)/symbols.txt

# Please see readme file about linking libgcc in this section
$(OUT_DIR)/rom.out: $(OUT_DIR)/sega.o $(OBJS) $(LIB_MD)
	$(CC) $(ARCH_FLAG) -n -Wl,--build-id=none -T $(SGDK)/md.ld -nostdlib $(OUT_DIR)/sega.o $(OBJS) $(LIB_MD) $(SGDK)/lib/libgcc.a -o $(OUT_DIR)/rom.out
# $(CC) $(ARCH_FLAG) -n -Wl,--build-id=none -T $(SGDK)/md.ld -nostdlib $(OUT_DIR)/sega.o $(OBJS) $(LIB_MD) -lgcc -o $(OUT_DIR)/rom.out

$(OUT_DIR)/sega.o: $(SRC_DIR)/boot/sega.s $(OUT_DIR)/rom_head.bin
	$(CC) $(DEF_FLAGS_M68K) -c $(SRC_DIR)/boot/sega.s -o $@

$(OUT_DIR)/rom_head.bin: $(OUT_DIR)/rom_head.o
	$(LD) -T $(SGDK)/md.ld -nostdlib --oformat binary -o $@ $<

$(OUT_DIR)/rom_head.o: $(SRC_DIR)/boot/rom_head.c
	$(CC) $(DEF_FLAGS_M68K) -c $< -o $@

$(SRC_DIR)/boot/sega.s: $(LIB_SRC)/boot/sega.s
	@cp $< $@

$(SRC_DIR)/boot/rom_head.c: $(LIB_SRC)/boot/rom_head.c
	@cp $< $@

$(OUT_DIR)/%.lst: %.c
	$(CC) $(FLAGS) -c $< -o $@

$(OUT_DIR)/%.o: %.c
	$(CC) $(FLAGS) -c $< -o $@

$(OUT_DIR)/%.o: %.s
	$(CC) $(FLAGS) -c $< -o $@

%.s: %.res
	@$(RESCOMP) $< $@

%.o80: %.s80
	@$(ASM_Z80) $(DEF_FLAGS_Z80) $< $@ out.lst

%.s: %.o80
	@$(BINTOS) $<
