#!/bin/bash

# Create directory
mkdir -p concrete
cd concrete

# Create 50 files
for i in {0..49}
do
    # Generate random content (1-100KB)
    size=$((RANDOM % 100 + 1))
    dd if=/dev/urandom of=file$i.txt bs=1K count=$size 2>/dev/null
    
    # Print absolute path
    # echo "$(pwd)/file$i.txt"
done
echo "$(pwd)"