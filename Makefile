# Makefile to compile and run vector and matrix programs with input from file

# Compiler and flags
CC = gcc
CFLAGS = -g -m32

# Source and target files
VECTOR_SRC = 151_Scanteie_AlexandruIoan_0.s
VECTOR_TARGET = vector

MATRIX_SRC = 151_Scanteie_AlexandruIoan_1.s
MATRIX_TARGET = matrix

# Default rule (does nothing)
all:
	@echo "Specify a target: vector or matrix"

# Build targets
vector: $(VECTOR_TARGET)

$(VECTOR_TARGET): $(VECTOR_SRC)
	$(CC) $(CFLAGS) $< -o $@

matrix: $(MATRIX_TARGET)

$(MATRIX_TARGET): $(MATRIX_SRC)
	$(CC) $(CFLAGS) $< -o $@

# Combined run and input rule
input: $(VECTOR_TARGET) $(MATRIX_TARGET)
ifeq ($(MAKECMDGOALS),vector input)
	@./$(VECTOR_TARGET) < input.txt
else ifeq ($(MAKECMDGOALS),matrix input)
	@./$(MATRIX_TARGET) < input.txt
else
	@echo "Invalid target for input. Use 'make vector input' or 'make matrix input'."
endif

# Clean rule
clean:
	rm -f $(VECTOR_TARGET) $(MATRIX_TARGET)
