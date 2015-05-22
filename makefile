EXEC=os
KERNEL=kernel

SRCDIR=./src
BINDIR=./bin
ISODIR=./iso

RM=/usr/bin/rm -f
CP=/usr/bin/cp
MKDIR=/usr/bin/mkdir -p
ISO=/usr/bin/genisoimage
VM=/usr/bin/qemu-system-i386

AS=/usr/bin/nasm
LD=/usr/bin/ld
CC=/usr/bin/gcc

ASFLAGS=-f elf
LDFLAGS=-T $(SRCDIR)/link.ld -melf_i386
CCFLAGS=-m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
        -fno-asynchronous-unwind-tables -nostartfiles -nodefaultlibs \
        -Wall -Wextra -Werror

OBJECTS=$(SRCDIR)/loader.o $(SRCDIR)/framebuffer.o $(SRCDIR)/function.o
ISOFLAGS=-R                           \
         -b boot/grub/stage2_eltorito \
         -no-emul-boot                \
         -boot-load-size 4            \
         -A os                        \
         -input-charset utf8          \
         -quiet                       \
         -boot-info-table             \
         -o $(BINDIR)/$(EXEC).iso $(ISODIR)

all: $(EXEC)

$(EXEC): $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $(BINDIR)/$(KERNEL).elf

%.o: %.c
	$(CC) $(CCFLAGS) $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

iso: $(EXEC)
	$(CP) $(BINDIR)/$(KERNEL).elf $(ISODIR)/boot
	$(ISO) $(ISOFLAGS)

run: iso
	$(VM) -monitor stdio -cdrom $(BINDIR)/$(EXEC).iso

clean:
	$(RM) $(BINDIR)/$(KERNEL).elf
	$(RM) $(ISODIR)/boot/$(KERNEL).elf
	$(RM) $(SRCDIR)/*.o
	$(RM) $(BINDIR)/$(EXEC).iso

mkdir:
	@$(MKDIR) $(BINDIR)
