OBJ    = main.o serial.o inbound.o outbound.o

COURSE   = /home/TDDI11/sw
LDSCRIPT = $(COURSE)/lib/link.cmd
BOOTSECT = $(COURSE)/lib/bootload.bin
LIBS = $(COURSE)/lib/elf/mtc.a
INCLUDES = -I "$(COURSE)/include" -I "$(COURSE)/include/djgpp" $(EXTRA_INCLUDES)
CC       = /sw/i386-elf-gcc-4.9.0/bin/i386-elf-gcc-4.9.0
CFLAGS  += -Wall -g $(INCLUDES)
LD       = /sw/i386-elf-gcc-4.9.0/bin/i386-elf-ld
LDFLAGS  = -T$(LDSCRIPT) -static -ustart -Map link.map
AS       = nasm
ASFLAGS  = -f elf32

embedded.bin: $(OBJ)
	$(LD) $(OBJ) $(LIBS) $(LDFLAGS)
%.o: %.c
	$(CC) $(CFLAGS) -c $<
%.o: %.asm
	$(AS) $(ASFLAGS) $<
clean:
	\rm -f embedded.bin *~ *.o link.map
