SGDK?=/opt/sgdk

CC:=gcc
CFLAGS:=-Wall -O2 -s

SRC_DIR:=example
BIN_DIR:=out
INC_DIR:=lib/elf64

TARGET:=$(BIN_DIR)/appack
INC:=-I$(INC_DIR)

SRCEXT:=c
SRC:=$(wildcard $(SRC_DIR)/*.c)

$(TARGET): $(SRC)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) $(INC) -o $@ $^ $(INC_DIR)/aplib.a

clean:
	@rm -r $(TARGET)

install:
	@cp -f $(TARGET) $(SGDK)/bin
	@echo "Copied $(TARGET) to $(SGDK)/bin"
