#
# Linux makefile
# Use with make 
#

.SUFFIXES:
.SUFFIXES: .o .asm .cpp .c

AS=nasm
ASFLAGS= -f elf
CFLAGS= 
CC=gcc
CXX=g++
CXXFLAGS=

.asm.o:
	$(AS) $(ASFLAGS) $*.asm

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $*.cpp

.c.o:
	$(CC) -c $(CFLAGS) $*.c

all: Saulo_TrabalhoPratico asm_io.o

Saulo_TrabalhoPratico: driver.o Saulo_TrabalhoPratico.o asm_io.o
	$(CC) $(CFLAGS) -o Saulo_TrabalhoPratico driver.o Saulo_TrabalhoPratico.o asm_io.o

asm_io.o : asm_io.asm
	$(AS) $(ASFLAGS) -d ELF_TYPE asm_io.asm

driver.o : driver.c

clean :
	rm *.o
