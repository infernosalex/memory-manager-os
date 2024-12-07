# Makefile to compile 151_Scanteie_AlexandruIoan_0.s into vector / CHATGPT ;)

# Compiler and flags
CC = gcc
CFLAGS = -g -m32

# Target and source file
TARGET = vector
SRC = 151_Scanteie_AlexandruIoan_0.s

# Default rule
all: $(TARGET)

# Build target
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $< -o $@

# Run target
run: $(TARGET)
	./$(TARGET)

# Input target
input: $(TARGET)
	./$(TARGET) < input.txt

# Clean rule
clean:
	rm -f $(TARGET)
