# Build SGDK based binary

# specify SGDK root dir
SGDK?=/opt/sgdk

LIB_SRC= $(SGDK)/src
LIB_RES= $(SGDK)/res
LIB_INC= $(SGDK)/inc

# project source directories
SRC_DIR=src
RES_DIR=res
INC_DIR=inc

# m68k toolset
CC:=m68k-elf-gcc
OBJCPY:=m68k-elf-objcopy
NM:=m68k-elf-nm
LD:=m68k-elf-ld

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

OBJS:=$(addprefix out/, $(OBJ))

LST= $(SRC_C:.c=.lst)
LSTS= $(addprefix out/, $(LST))

# setup includes
INC:=-I$(INC_DIR) -I$(SRC_DIR) -I$(RES_DIR) -I$(LIB_INC) -I$(LIB_RES)

# default flags
DEF_FLAGS_M68K:=-m68000 -Wall -fno-builtin $(INC)
DEF_FLAGS_Z80:=-i$(SRC_DIR) -i$(INC_DIR) -i$(RES_DIR) -i$(LIB_SRC) -i$(LIB_INC)

release: FLAGS:=$(DEF_FLAGS_M68K) -O3 -fuse-linker-plugin -fno-web -fno-gcse -fno-unit-at-a-time -fomit-frame-pointer -flto
release: LIB_MD:=$(SGDK)/lib/libmd.a
release: prebuild out/rom.bin

debug: FLAGS:=$(DEF_FLAGS_M68K) -O1 -ggdb -DDEBUG=1
debug: LIB_MD:=$(SGDK)/lib/libmd_debug.a
debug: prebuild out/rom.bin out/rom.out out/symbol.txt

asm: FLAGS:=$(DEF_FLAGS_M68K) -O3 -fuse-linker-plugin -fno-web -fno-gcse -fno-unit-at-a-time -fomit-frame-pointer -S
asm: prebuild $(LSTS)

all: release
default: release
Default: release
Release: release
Asm: asm

.PHONY: clean

cleanlst:
	rm -f $(LSTS)

cleanobj:
	rm -f $(OBJS) out/sega.o out/rom_head.bin out/rom_head.o out/rom.out

clean: cleanobj cleanlst
	rm -f out.lst out/cmd_ out/rom.nm out/rom.wch out/rom.bin

cleandebug: clean
	rm -f out/symbol.txt

cleanasm: cleanlst

cleandefault: clean
cleanDefault: clean

cleanRelease: cleanrelease
cleanDebug: cleandebug
cleanAsm: cleanasm

prebuild:
	mkdir -p $(SRC_DIR)/boot
	mkdir -p out
	mkdir -p out/src
	mkdir -p out/res

out/rom.bin: out/rom.out
	$(OBJCPY) -O binary out/rom.out out/temp
	dd if=out/temp of=$@ bs=8K conv=sync status=none
	rm -f out/temp

out/symbol.txt: out/rom.out
	$(NM) -n out/rom.out > out/symbol.txt

# Please see readme file about linking libgcc in this section
out/rom.out: out/sega.o $(OBJS) $(LIB_MD)
	$(CC) -n -T $(SGDK)/md.ld -nostdlib out/sega.o $(OBJS) $(LIB_MD) $(SGDK)/lib/libgcc.a -o out/rom.out
# $(CC) -n -T $(SGDK)/md.ld -nostdlib out/sega.o $(OBJS) $(LIB_MD) -lgcc -o out/rom.out

out/sega.o: $(SRC_DIR)/boot/sega.s out/rom_head.bin
	$(CC) $(DEF_FLAGS_M68K) -c $(SRC_DIR)/boot/sega.s -o $@

out/rom_head.bin: out/rom_head.o
	$(LD) -T $(SGDK)/md.ld -nostdlib --oformat binary -o $@ $<

out/rom_head.o: $(SRC_DIR)/boot/rom_head.c
	$(CC) $(DEF_FLAGS_M68K) -c $< -o $@

$(SRC_DIR)/boot/sega.s: $(LIB_SRC)/boot/sega.s
	cp $< $@

$(SRC_DIR)/boot/rom_head.c: $(LIB_SRC)/boot/rom_head.c
	cp $< $@

out/%.lst: %.c
	$(CC) $(FLAGS) -c $< -o $@

out/%.o: %.c
	$(CC) $(FLAGS) -c $< -o $@

out/%.o: %.s
	$(CC) $(FLAGS) -c $< -o $@

%.s: %.res
	$(RESCOMP) $< $@

%.o80: %.s80
	$(ASM_Z80) $(DEF_FLAGS_Z80) $< $@ out.lst

%.s: %.o80
	$(BINTOS) $<
