SGDK?=/opt/sgdk

CC:=gcc
CFLAGS:=-Wall -O

TARGET:=maccer

$(TARGET): main.c
	$(CC) $(CFLAGS) -o $@ $^ -lm

clean:
	@rm -r $(TARGET)

install:
	@cp -f $(TARGET) $(SGDK)/bin
	@echo "Copied $(TARGET) to $(SGDK)/bin"
