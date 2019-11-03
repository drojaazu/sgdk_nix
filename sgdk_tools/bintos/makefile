SGDK?=/opt/sgdk
CC:=gcc
CFLAGS:=-Wall

SRC_DIR:=src
BIN_DIR:=out

TARGET:=$(BIN_DIR)/bintos

SRCEXT:=c
SRC:=$(wildcard $(SRC_DIR)/*.c)

$(TARGET): $(SRC)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -r $(TARGET)

install:
	cp -f $(TARGET) $(SGDK)/bin