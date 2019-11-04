SGDK?=/opt/sgdk
BINTOS_SRC:=$(SGDK)/tools/bintos

CC:=gcc
CFLAGS:=-Wall

SRC_DIR:=$(BINTOS_SRC)/src
OUT_DIR:=$(BINTOS_SRC)/out

SRCEXT:=c
SRC:=$(wildcard $(SRC_DIR)/*.c)

TARGET:=$(OUT_DIR)/bintos

$(TARGET): $(SRC)
	@mkdir -p $(OUT_DIR)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	@rm -r $(TARGET)

install:
	@cp -f $(TARGET) $(SGDK)/bin
	@echo "Copied $(TARGET) to $(SGDK)/bin"
