SGDK?=/opt/sgdk

SIZEBND_SRC:=$(SGDK)/tools/sizebnd
SRC_DIR:=$(SIZEBND_SRC)/src
INC_DIR:=$(SIZEBND_SRC)/inc
OUT_DIR:=$(SIZEBND_SRC)/out

SRCEXT:=c
SRC:=$(wildcard $(SRC_DIR)/*.c)

CC:=gcc
CFLAGS:=-fexpensive-optimizations -Os -s

TARGET:=$(OUT_DIR)/sizebnd

$(TARGET): $(SRC)
	@mkdir -p $(OUT_DIR)
	$(CC) $(CFLAGS) -I$(INC_DIR) -o $@ $^ -lm

clean:
	@rm -r $(TARGET)

install:
	@cp -f $(TARGET) $(SGDK)/bin
	@echo "Copied $(TARGET) to $(SGDK)/bin"