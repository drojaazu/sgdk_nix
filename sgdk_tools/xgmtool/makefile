SGDK?=/opt/sgdk
CC:=gcc
CFLAGS:=-fexpensive-optimizations -Os -s -lm

SRC_DIR:=src
BIN_DIR:=out

TARGET:=$(BIN_DIR)/xgmtool
INC:=-Iinc

SRCEXT:=c
SRC:=$(wildcard $(SRC_DIR)/*.c)

$(TARGET): $(SRC)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) $(INC) -o $@ $^

clean:
	rm -r $(TARGET)

install:
	cp -f $(TARGET) $(SGDK)/bin