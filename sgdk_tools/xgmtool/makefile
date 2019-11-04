SGDK?=/opt/sgdk

XGMTOOL_SRC:=$(SGDK)/tools/xgmtool
SRC_DIR:=$(XGMTOOL_SRC)/src
INC_DIR:=$(XGMTOOL_SRC)/inc
OUT_DIR:=$(XGMTOOL_SRC)/out

SRCEXT:=c
SRC:=$(wildcard $(SRC_DIR)/*.c)

CC:=gcc
CFLAGS:=-fexpensive-optimizations -Os -s -lm

TARGET:=$(OUT_DIR)/xgmtool

$(TARGET): $(SRC)
	@mkdir -p $(OUT_DIR)
	$(CC) $(CFLAGS) -I$(INC_DIR) -o $@ $^

clean:
	@rm -r $(TARGET)

install:
	@cp -f $(TARGET) $(SGDK)/bin
	@echo "Copied $(TARGET) to $(SGDK)/bin"
